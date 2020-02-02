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
rem call npx gulp clean
rem Build missions
call npx gulp

rem Increase build ID
cd %~dp0
set /P _id=<..\configs\buildVersion.hpp
echo "This build ID is:"
echo %_id%
set /a _id=%_id%+1
break>..\configs\buildVersion.hpp
echo %_id%>>..\configs\buildVersion.hpp
rem pause