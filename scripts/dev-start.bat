@echo off
setlocal
cd /d "%~dp0.."
title OneBlog dev start (web 8443 / admin 8085)

echo ============================================================
echo   OneBlog local start
echo   Project: %cd%
echo ============================================================
echo.

echo [1/4] Checking Redis on 127.0.0.1:6379 ...
set "REDIS_DIR=D:\Redis"
if not exist "%REDIS_DIR%\redis-cli.exe" goto nore
"%REDIS_DIR%\redis-cli.exe" ping >nul 2>&1
if errorlevel 1 (
    echo       Redis not running, starting it ...
    start "Redis-Server" /min "%REDIS_DIR%\redis-server.exe" "%REDIS_DIR%\redis.windows.conf"
    timeout /t 2 >nul
)
"%REDIS_DIR%\redis-cli.exe" ping
goto jars

:nore
echo       [WARN] %REDIS_DIR%\redis-cli.exe not found. Install Redis first.

:jars
echo.
if not exist "blog-web\target\blog-web.jar" goto nojar
if not exist "blog-admin\target\blog-admin.jar" goto nojar
echo [2/4] Found blog-web.jar and blog-admin.jar
goto pwd

:nojar
echo [2/4] [ERROR] jars missing. Run scripts\m2-01-build.bat first.
pause
exit /b 1

:pwd
echo.
echo [3/4] MySQL root password (not echoed, not written to disk)
if "%ONEBLOG_DATASOURCE_PASSWORD%"=="" (
    set /p ONEBLOG_DATASOURCE_PASSWORD=      Enter MySQL root password: 
) else (
    echo       Using ONEBLOG_DATASOURCE_PASSWORD from environment
)
echo.

echo [4/4] Starting applications ...
echo       Front: http://127.0.0.1:8443
echo       Admin: http://127.0.0.1:8085/passport/login/
echo.
start "blog-web-8443" cmd /c "set SERVER__PORT=8443&& set ONEBLOG_DATASOURCE_PASSWORD=%ONEBLOG_DATASOURCE_PASSWORD%&& java -jar blog-web\target\blog-web.jar"
timeout /t 8 >nul
start "blog-admin-8085" cmd /c "set SERVER__PORT=8085&& set ONEBLOG_DATASOURCE_PASSWORD=%ONEBLOG_DATASOURCE_PASSWORD%&& java -jar blog-admin\target\blog-admin.jar"

echo.
echo Started in new windows. First start takes 20-40 seconds.
echo To stop: run scripts\dev-stop.bat
pause
endlocal
