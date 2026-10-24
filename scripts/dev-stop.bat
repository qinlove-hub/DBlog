@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title 停止 OneBlog 本地服务（8443 / 8085）

echo 正在查找占用 8443 / 8085 的进程 ...
set "FOUND=0"
for %%P in (8443 8085) do (
    for /f "tokens=5" %%A in ('netstat -ano ^| findstr ":%%P" ^| findstr "LISTENING"') do (
        echo   - 端口 %%P 被 PID %%A 占用，正在停止 ...
        taskkill /PID %%A /F >nul 2>&1
        set "FOUND=1"
    )
)
if "%FOUND%"=="0" (echo   没有发现监听 8443/8085 的进程。) else (echo   已停止。)

echo.
echo Redis 仍在运行（如需停止：D:\Redis\redis-cli.exe shutdown）
pause
endlocal
