@echo off
cd /d "%~dp0.."
echo %cd%
For /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%a-%%b)
For /f "tokens=1-3 delims=/:/ " %%a in ('time /t') do (set mytime=%%a-%%b-%%c)
set mytime=%mytime: =%

move /Y "Project_0.Altis\mission.sqm" "Project_0.Altis\mission.sqm.backup.at.%mydate%-%mytime%"

echo Current mission.sqm renamed to mission.sqm.backup.at.%mydate%-%mytime%
copy /Y "mission.Altis.sqm" "Project_0.Altis\mission.sqm"
