// Bridge between job files in this folder and Roblox Studio's own MCP server (StudioMCP, stdio).
// It ONLY forwards tool calls to Roblox Studio. Jobs: queue/<name>.json -> result in done/<name>.json
//   { "name": "<tool>", "arguments": {...}, "save": "caps/x.png" }          one tool call
//   { "batch": [ {name, arguments, save?}, ... ] }                           several calls, in order
//   { "render": { "tool": "...", "code_arg": "code", "template": "...{{F}}...", "frames": [a, b], "frameIndices"?: [...], "capture": {name, arguments}, "out": "frames/s001" } }
// Upgraded: auto-reconnects StudioMCP (even after Studio updates), per-frame retries, auto-restores hidden Studio window on blank captures.
// Stop it: close this Terminal window (or Ctrl+C).
import { spawn, spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const log = (...a) => {
  const s = new Date().toTimeString().slice(0, 8) + " " + a.join(" ");
  console.log(s);
  fs.appendFileSync(path.join(HERE, "bridge.log"), s + "\n");
};

function findStudioMcp() {
  if (process.env.ROBLOX_MCP_BIN) return process.env.ROBLOX_MCP_BIN;
  if (process.platform === "win32") {
    const localApp = process.env.LOCALAPPDATA || path.join(process.env.USERPROFILE || "", "AppData", "Local");
    const searchRoots = [
      path.join(localApp, "Roblox", "Versions"),
      "C:\\Program Files\\Roblox\\Versions",
      "C:\\Program Files (x86)\\Roblox\\Versions",
    ];
    const candidates = [];
    for (const versionsDir of searchRoots) {
      if (!fs.existsSync(versionsDir)) continue;
      for (const entry of fs.readdirSync(versionsDir, { withFileTypes: true })) {
        if (!entry.isDirectory()) continue;
        const exe = path.join(versionsDir, entry.name, "StudioMCP.exe");
        if (fs.existsSync(exe)) {
          candidates.push({ exe, mtime: fs.statSync(exe).mtimeMs });
        }
      }
    }
    if (candidates.length) {
      candidates.sort((a, b) => b.mtime - a.mtime);
      return candidates[0].exe;
    }
    const bat = path.join(localApp, "Roblox", "mcp.bat");
    if (fs.existsSync(bat)) return bat;
    return path.join(localApp, "Roblox", "Versions", "version-<hash>", "StudioMCP.exe");
  }
  return "/Applications/RobloxStudio.app/Contents/MacOS/StudioMCP";
}

function tryFixStudioWindow() {
  if (process.platform !== "win32") return false;
  try {
    const res = spawnSync("python", [path.join(HERE, "preflight.py"), "--window-only", "--fix"], {
      cwd: HERE,
      timeout: 8000,
      encoding: "utf8",
      windowsHide: true,
    });
    if (res.status === 0) {
      log("auto-healed Studio window:", (res.stdout || "").trim());
      return true;
    }
    log("window auto-heal failed:", (res.stdout || res.stderr || "").trim().slice(0, 200));
  } catch (e) {
    log("window auto-heal error:", String(e));
  }
  return false;
}

fs.writeFileSync(path.join(HERE, "bridge.log"), "");
for (const dir of ["queue", "done", "caps"]) {
  fs.mkdirSync(path.join(HERE, dir), { recursive: true });
}
log("bridge starting, folder:", HERE);

let p = null;
let mcpReady = false;
let reconnecting = null;
let buf = "", id = 0;
const wait = new Map();

const out = (f, o) => {
  fs.mkdirSync(path.dirname(path.join(HERE, f)), { recursive: true });
  fs.writeFileSync(path.join(HERE, f), JSON.stringify(o, null, 1));
};

function rejectAllPending(reason) {
  for (const [k, resolve] of wait.entries()) {
    resolve({ error: { message: reason } });
    wait.delete(k);
  }
}

async function connectMcp() {
  if (reconnecting) return reconnecting;
  reconnecting = (async () => {
    mcpReady = false;
    let attempt = 0;
    while (!mcpReady) {
      attempt++;
      const BIN = findStudioMcp();
      if (!fs.existsSync(BIN)) {
        log(`StudioMCP not found at ${BIN} (attempt ${attempt}), retrying in 5s...`);
        await sleep(5000);
        continue;
      }
      log(`connecting to StudioMCP (attempt ${attempt}):`, BIN);
      buf = "";
      const child = BIN.toLowerCase().endsWith(".bat")
        ? spawn("cmd.exe", ["/c", BIN], { stdio: ["pipe", "pipe", "pipe"], windowsHide: true })
        : spawn(BIN, [], { stdio: ["pipe", "pipe", "pipe"] });
      p = child;

      child.stdout.on("data", (d) => {
        buf += d;
        let i;
        while ((i = buf.indexOf("\n")) >= 0) {
          const line = buf.slice(0, i).trim();
          buf = buf.slice(i + 1);
          if (!line) continue;
          try {
            const m = JSON.parse(line);
            if (m.id != null && wait.has(m.id)) {
              wait.get(m.id)(m);
              wait.delete(m.id);
            }
          } catch {
            log("non-json from StudioMCP:", line.slice(0, 200));
          }
        }
      });
      child.stderr.on("data", (d) => fs.appendFileSync(path.join(HERE, "bridge_stderr.log"), d));
      child.on("exit", (c) => {
        if (p === child) {
          mcpReady = false;
          p = null;
          rejectAllPending("StudioMCP exited with code " + c);
          log("StudioMCP exited with code", c, "- will auto-reconnect on next call");
        }
      });

      const init = await rawCall("initialize", {
        protocolVersion: "2024-11-05",
        capabilities: {},
        clientInfo: { name: "roblox-bridge", version: "2.0" },
      }, 30000);

      if (init && !init.error) {
        try {
          child.stdin.write(JSON.stringify({ jsonrpc: "2.0", method: "notifications/initialized" }) + "\n");
          const tools = await rawCall("tools/list", {}, 30000);
          out("tools.json", { init, tools });
          mcpReady = true;
          log("connected to StudioMCP:", JSON.stringify(init?.result?.serverInfo || {}));
          break;
        } catch (e) {
          log("MCP handshake error:", String(e));
        }
      } else {
        log("MCP init failed:", JSON.stringify(init?.error || {}), "- retrying...");
      }
      try { child.kill(); } catch {}
      await sleep(Math.min(10000, 2000 * attempt));
    }
    reconnecting = null;
  })();
  return reconnecting;
}

const rawCall = (method, params, ms = 180000) => new Promise((ok) => {
  if (!p || !p.stdin || p.killed) {
    ok({ error: { message: "StudioMCP not connected" } });
    return;
  }
  const i = ++id;
  const t = setTimeout(() => {
    wait.delete(i);
    ok({ error: { message: "timeout after " + ms + " ms" } });
  }, ms);
  wait.set(i, (m) => { clearTimeout(t); ok(m); });
  try {
    p.stdin.write(JSON.stringify({ jsonrpc: "2.0", id: i, method, params }) + "\n");
  } catch (e) {
    clearTimeout(t);
    wait.delete(i);
    ok({ error: { message: "stdin write failed: " + String(e) } });
  }
});

const call = async (method, params, ms = 180000) => {
  if (!mcpReady || !p || p.killed) await connectMcp();
  let r = await rawCall(method, params, ms);
  if (r?.error?.message && (r.error.message.includes("not connected") || r.error.message.includes("exited") || r.error.message.includes("stdin write failed"))) {
    log("MCP connection lost during call, reconnecting and retrying once...");
    await connectMcp();
    r = await rawCall(method, params, ms);
  }
  return r;
};

const saveImages = (r, save, tag) => {
  const c = r?.result?.content;
  if (!Array.isArray(c)) return r;
  let n = 0;
  for (const item of c) {
    if (item.type === "image" && item.data) {
      const ext = (item.mimeType || "image/png").split("/")[1].replace("jpeg", "jpg");
      const f = save ? (n ? save.replace(/(\.\w+)?$/, `_${n}$1`) : save) : `caps/${tag}_${n}.${ext}`;
      const full = path.resolve(HERE, f);
      fs.mkdirSync(path.dirname(full), { recursive: true });
      const tmp = full + ".tmp";
      fs.writeFileSync(tmp, Buffer.from(item.data, "base64"));
      fs.renameSync(tmp, full);
      item.data = "(saved to " + f + ")";
      item.bytes = fs.statSync(full).size;
      n++;
    }
  }
  return r;
};

const one = async (j, tag) => saveImages(await call("tools/call", { name: j.name, arguments: j.arguments || {} }, j.timeout || 180000), j.save, tag);

await connectMcp();

const Q = path.join(HERE, "queue");
for (;;) {
  const jobs = fs.readdirSync(Q).filter((f) => f.endsWith(".json")).sort();
  if (!jobs.length) {
    fs.writeFileSync(path.join(HERE, "bridge_alive.txt"), String(Date.now()));
    await sleep(300);
    continue;
  }
  const f = jobs[0], tag = f.replace(/\.json$/, "");
  let j;
  try {
    j = JSON.parse(fs.readFileSync(path.join(Q, f), "utf8"));
  } catch (e) {
    fs.renameSync(path.join(Q, f), path.join(Q, f + ".bad"));
    log("bad job", f, String(e));
    continue;
  }
  fs.rmSync(path.join(Q, f));
  const t0 = Date.now();
  let res;
  try {
    if (j.batch) {
      res = [];
      for (const [k, b] of j.batch.entries()) res.push(await one(b, tag + "_" + k));
    } else if (j.render) {
      const R = j.render;
      res = { frames: 0, skipped: 0, retried: 0, errors: [] };
      const frameList = Array.isArray(R.frameIndices)
        ? R.frameIndices
        : Array.from({ length: R.frames[1] - R.frames[0] + 1 }, (_, i) => R.frames[0] + i);
      const minBytes = R.minBytes || 14000;
      const maxRetries = R.retries ?? 3;
      let blanks = [];
      let doneCount = 0;
      const total = frameList.length;

      for (let idx = 0; idx < total; idx++) {
        const fr = frameList[idx];
        const fn = path.resolve(HERE, R.out, String(fr).padStart(5, "0") + ".png");
        if (fs.existsSync(fn) && !R.force) {
          res.frames++;
          res.skipped++;
          doneCount++;
          continue;
        }

        let capturedOk = false;
        let lastErr = null;
        let windowHealedThisFrame = false;

        for (let attempt = 1; attempt <= maxRetries; attempt++) {
          const e = await call("tools/call", {
            name: R.tool,
            arguments: { ...(R.args || {}), [R.code_arg]: R.template.replaceAll("{{F}}", String(fr)) },
          }, 60000);

          if (e.error || e?.result?.isError) {
            lastErr = { fr, e: JSON.stringify(e).slice(0, 300) };
            if (attempt < maxRetries) {
              res.retried++;
              log(`frame ${fr} lua error (attempt ${attempt}/${maxRetries}), retrying...`);
              await sleep(1200 * attempt);
              continue;
            }
            break;
          }

          const c = saveImages(await call("tools/call", R.capture, 60000), fn, tag);
          if (c.error || c?.result?.isError) {
            lastErr = { fr, c: JSON.stringify(c).slice(0, 300) };
            if (attempt < maxRetries) {
              res.retried++;
              log(`frame ${fr} capture error (attempt ${attempt}/${maxRetries}), retrying...`);
              await sleep(1200 * attempt);
              continue;
            }
            break;
          }

          const bytes = (c?.result?.content || []).find((x) => x.bytes)?.bytes || 0;
          if (bytes && bytes < minBytes) {
            if (!windowHealedThisFrame && attempt < maxRetries) {
              windowHealedThisFrame = true;
              res.retried++;
              log(`frame ${fr} blank (${bytes}B) - attempting to restore/focus Studio window...`);
              tryFixStudioWindow();
              await sleep(1000);
              continue;
            }
            blanks.push(fn);
            capturedOk = true; // saved but blank; tracked below
            break;
          } else {
            blanks = [];
            capturedOk = true;
            break;
          }
        }

        if (!capturedOk) {
          res.errors.push(lastErr || { fr, e: "unknown error" });
          if (res.errors.length > 5) {
            res.stopped = "6 frames failed after retries (Play mode? Studio closed?)";
            break;
          }
          continue;
        }

        if (blanks.length >= 3) {
          res.stopped = "3 blank captures in a row even after auto-heal (Studio window hidden/minimised)";
          break;
        }

        res.frames++;
        doneCount++;
        if (doneCount % 10 === 0 || doneCount === total) {
          const elapsedSec = (Date.now() - t0) / 1000;
          const rendered = res.frames - res.skipped;
          const spf = rendered > 0 ? elapsedSec / rendered : 0;
          const etaMin = spf > 0 ? ((total - doneCount) * spf / 60).toFixed(1) : "?";
          fs.writeFileSync(
            path.join(HERE, "render_progress.txt"),
            `${tag} ${doneCount}/${total} (${spf.toFixed(2)}s/cap, ETA ${etaMin}m)`
          );
        }
      }

      if (res.stopped) {
        for (const bp of blanks) { try { fs.rmSync(bp); } catch {} }
        const H = path.join(HERE, "queue_hold");
        fs.mkdirSync(H, { recursive: true });
        // Re-park the interrupted job itself so --resume finishes it cleanly!
        fs.writeFileSync(path.join(H, f), JSON.stringify(j));
        const rest = fs.readdirSync(Q).filter((x) => x.endsWith(".json"));
        for (const x of rest) fs.renameSync(path.join(Q, x), path.join(H, x));
        fs.writeFileSync(
          path.join(HERE, "render_stopped.txt"),
          `${new Date().toISOString()} ${tag}: ${res.stopped}; ${rest.length + 1} job(s) parked in queue_hold/\n`
        );
        log("RENDER STOPPED:", tag, res.stopped, "-", rest.length + 1, "job(s) parked in queue_hold/. Fix Studio, then run: python render.py --resume");
      }
    } else {
      res = await one(j, tag);
    }
  } catch (e) {
    res = { error: String(e) };
  }
  out("done/" + f, { ms: Date.now() - t0, res });
  log("job", f, "done in", Date.now() - t0, "ms");
}
