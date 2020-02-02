@echo off 

cd /d "%~dp0"
REM use CALL command to call multiple .bat files!
set missionFolder=Vindicta.Altis

call initClassesAI.bat %missionFolder% AI\Garrison\
echo Generated garrison classes!

call initClassesAI.bat %missionFolder% AI\Group\
echo generated group classes!

call initClassesAI.bat %missionFolder% AI\Unit\
echo generated unit classes!