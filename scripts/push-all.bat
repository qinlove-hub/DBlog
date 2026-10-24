@echo off
setlocal
cd /d "%~dp0.."
title Push to GitHub + CodeArts

set "GH_OK=0"
set "CA_OK=0"
set "CA_TRIED=0"
set "BRANCH="
set "CA_URL="

for /f "delims=" %%B in ('git rev-parse --abbrev-ref HEAD') do set "BRANCH=%%B"
for /f "delims=" %%R in ('git config --get remote.codearts.url 2^>nul') do set "CA_URL=%%R"

echo ============================================================
echo   Push branch "%BRANCH%" to all remotes
echo   Project: %cd%
echo ------------------------------------------------------------
echo   GitHub   : through Clash proxy 127.0.0.1:7897
echo   CodeArts : direct (no proxy), domestic host
echo ============================================================
echo.

echo [1/2] GitHub ...
git -c http.proxy=http://127.0.0.1:7897 -c https.proxy=http://127.0.0.1:7897 push origin HEAD
if errorlevel 1 echo       [FAILED] GitHub push failed.
if not errorlevel 1 set "GH_OK=1"
echo.

if not defined CA_URL goto ca_skip

echo [2/2] CodeArts ...
set "CA_TRIED=1"
git -c http.proxy= -c https.proxy= push codearts HEAD
if errorlevel 1 echo       [FAILED] CodeArts push failed.
if not errorlevel 1 set "CA_OK=1"
goto summary

:ca_skip
echo [2/2] Remote "codearts" not configured, skipped.
echo       Add it once with:
echo       git remote add codearts ^<CodeArts HTTPS clone url^>

:summary
echo.
echo ============================================================
echo   SUMMARY    GitHub: %GH_OK%    CodeArts: %CA_OK%    (1 = ok)
echo ------------------------------------------------------------
if "%GH_OK%"=="0" echo   GitHub failed - check Clash 7897 and its node. Retry: git push origin %BRANCH%
if "%CA_TRIED%%CA_OK%"=="10" echo   CodeArts failed - check the token. Username is always: private-token
if "%GH_OK%%CA_OK%"=="11" echo   Both remotes are in sync.
if "%GH_OK%%CA_OK%"=="00" echo   Nothing was pushed.
echo ------------------------------------------------------------
echo   Verify:
echo     git -c http.proxy= ls-remote codearts
echo     git -c http.proxy=http://127.0.0.1:7897 ls-remote origin
echo ============================================================
pause
exit /b 0
