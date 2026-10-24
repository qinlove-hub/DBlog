@echo off
chcp 65001 >nul
setlocal
title OneBlog 本地一键启动（前台 8443 / 后台 8085）

cd /d "%~dp0.."
set "ROOT=%cd%"
echo ============================================================
echo   OneBlog(DBlog) 本地启动脚本
echo   项目目录: %ROOT%
echo ============================================================
echo.

REM ---------- 1. 检查 Redis ----------
echo [1/4] 检查 Redis(127.0.0.1:6379) ...
set "REDIS_DIR=D:\Redis"
if exist "%REDIS_DIR%\redis-cli.exe" (
    "%REDIS_DIR%\redis-cli.exe" ping >nul 2>&1
    if errorlevel 1 (
        echo       Redis 未运行，正在启动 ...
        start "Redis-Server" /min "%REDIS_DIR%\redis-server.exe" "%REDIS_DIR%\redis.windows.conf"
        timeout /t 2 >nul
    )
    "%REDIS_DIR%\redis-cli.exe" ping
) else (
    echo       [警告] 未找到 %REDIS_DIR%\redis-cli.exe，请先安装 Redis，否则应用启动会失败。
)
echo.

REM ---------- 2. 检查 jar ----------
if not exist "blog-web\target\blog-web.jar" goto :nojar
if not exist "blog-admin\target\blog-admin.jar" goto :nojar
echo [2/4] 已找到打包产物 blog-web.jar / blog-admin.jar
goto :pass

:nojar
echo [2/4] [错误] 未找到 jar，请先执行: mvn clean package -Dmaven.test.skip=true
pause
exit /b 1

:pass
echo.

REM ---------- 3. 数据库密码 ----------
echo [3/4] 数据库密码（本地 MySQL 的 root 密码，不回显、不落盘）
if "%ONEBLOG_DATASOURCE_PASSWORD%"=="" (
    set /p ONEBLOG_DATASOURCE_PASSWORD=      请输入 root 密码: 
) else (
    echo       已从环境变量读取 ONEBLOG_DATASOURCE_PASSWORD
)
echo.

REM ---------- 4. 启动两个应用 ----------
echo [4/4] 启动应用 ...
echo       前台: http://127.0.0.1:8443
echo       后台: http://127.0.0.1:8085/passport/login
echo.
echo 注意: 本机若存在 SERVER__PORT 环境变量会覆盖端口，故此处显式指定。
start "blog-web:8443" cmd /c "set SERVER__PORT=8443&& set ONEBLOG_DATASOURCE_PASSWORD=%ONEBLOG_DATASOURCE_PASSWORD%&& java -jar blog-web\target\blog-web.jar"
timeout /t 8 >nul
start "blog-admin:8085" cmd /c "set SERVER__PORT=8085&& set ONEBLOG_DATASOURCE_PASSWORD=%ONEBLOG_DATASOURCE_PASSWORD%&& java -jar blog-admin\target\blog-admin.jar"

echo.
echo 已在新窗口启动，首次启动约 20-40 秒。
echo 关闭本窗口不影响运行；如需停止，请执行 scripts\dev-stop.bat
pause
endlocal
