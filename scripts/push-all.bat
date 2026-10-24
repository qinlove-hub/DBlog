@echo off
setlocal
cd /d "%~dp0.."
title Push to GitHub + CodeArts

for /f "delims=" %%B in ('git rev-parse --abbrev-ref HEAD') do set "BRANCH=%%B"

echo ============================================================
echo   Push branch "%BRANCH%" to all remotes
echo   Project: %cd%
echo ============================================================
echo.

echo [1/2] GitHub (via Clash proxy 127.0.0.1:7897) ...
git -c http.proxy=http://127.0.0.1:7897 -c https.proxy=http://127.0.0.1:7897 push origin HEAD
if errorlevel 1 goto fail
echo.

git remote | findstr /x /c:"codearts" >nul
if errorlevel 1 (
    echo [2/2] Remote "codearts" not configured, skipped.
    echo       Add it once with:
    echo       git remote add codearts ^<CodeArts HTTPS clone url^>
    goto done
)

echo [2/2] CodeArts ...
git push codearts HEAD
if errorlevel 1 goto fail

:done
echo.
echo ============================================================
echo   All done. Verify both sides:
echo     git ls-remote origin
echo     git ls-remote codearts
echo   The refs/heads/ lines should show the same SHA.
echo ============================================================
pause
exit /b 0

:fail
echo.
echo ============================================================
echo   Push FAILED - read the messages above.
echo   Tip: make sure Clash is running on port 7897.
echo ============================================================
pause
exit /b 1
