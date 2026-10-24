@echo off
setlocal enabledelayedexpansion
title OneBlog dev stop (8443 / 8085)

echo Looking for processes listening on 8443 / 8085 ...
set "FOUND=0"
for %%P in (8443 8085) do (
    for /f "tokens=5" %%A in ('netstat -ano ^| findstr ":%%P" ^| findstr "LISTENING"') do (
        echo   - port %%P held by PID %%A, stopping ...
        taskkill /PID %%A /F >nul 2>&1
        set "FOUND=1"
    )
)
if "%FOUND%"=="0" (
    echo   Nothing listening on 8443 / 8085.
) else (
    echo   Stopped.
)
echo.
echo Redis is still running. To stop it: D:\Redis\redis-cli.exe shutdown
pause
endlocal
