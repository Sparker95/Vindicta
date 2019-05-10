@echo off

rem Check that https://nodejs.org/en/download/ exists before continuing
where /q node
if ERRORLEVEL 1 (
    echo node is missing. Ensure it is installed. It can be downloaded from:
    echo https://nodejs.org/en/download/
    timeout 30
    exit /b
)

rem CD into build tool directory
cd /d "%~dp0buildtool"

rem Clean first, never want to do iterative build, it makes no sense
call npx gulp clean
rem Build missions
call npx gulp

cd ..

echo.

pause
exit /b
