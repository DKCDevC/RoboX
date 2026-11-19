@echo off
title Roblox Studio MCP Bridge
cd /d "%~dp0"
echo Starting Roblox Studio MCP Bridge in "%~dp0"...
echo Keep this window open while rendering or running rb.py / render*.py.
echo Press Ctrl+C to stop.
echo.
node "%~dp0bridge.mjs"
if errorlevel 1 (
    echo.
    echo Bridge exited with an error. Check bridge.log above.
    pause
)

