REM use CALL command to call multiple .bat files!
set missionFolder=Project_0.Altis

call initClassesAI.bat %missionFolder% AI\Commander\
echo generated commander classes!

call initClassesAI.bat %missionFolder% AI\Garrison\
echo Generated garrison classes!

call initClassesAI.bat %missionFolder% AI\Group\
echo generated group classes!

call initClassesAI.bat %missionFolder% AI\Unit\
echo generated unit classes!