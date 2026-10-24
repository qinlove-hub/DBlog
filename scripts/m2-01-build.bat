@echo off
setlocal
cd /d "%~dp0.."
title M2-01 BUILD CHECK
echo ============================================================
echo   M2-01  Build verification: mvn clean package
echo   Project: %cd%
echo ------------------------------------------------------------
echo   NOTE: stop blog-web(8443) and blog-admin(8085) first,
echo         otherwise "mvn clean" cannot delete the running jar.
echo ============================================================
echo.
echo Building, please wait about 1 minute ...
echo.
call mvn clean package -Dmaven.test.skip=true
set "RC=%ERRORLEVEL%"
echo.
echo ============================================================
echo   Exit code: %RC%
if "%RC%"=="0" echo   Result: BUILD SUCCESS
if not "%RC%"=="0" echo   Result: BUILD FAILED - read the [ERROR] lines above
echo.
echo   Take a screenshot from "Reactor Summary" down to "Total time".
echo ============================================================
pause
