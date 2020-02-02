REM This kill arma process and launch another one directly into the EDEN editor with mission launched
REM Remember to change the paths
REM this use a dev.cfg config at root of arma to set the resolution and width of the window

@echo off

title Vindicta.Client.dev Restarter
cls

E:
CD "E:\Program Files (x86)\Steam\steamapps\common\Arma 3"

:reboot
echo Killing Arma3_x64.exe
taskkill /F /IM Arma3_x64.exe /T

echo(%time%) start arma
start Arma3_x64.exe -name=dev -window -cfg=dev.cfg -mod="E:\Program Files (x86)\Steam\steamapps\common\Arma 3\!Workshop\@CBA_A3;E:\Program Files (x86)\Steam\steamapps\common\Arma 3\!Workshop\@ace;E:\Program Files (x86)\Steam\steamapps\common\Arma 3\!Workshop\@Intercept Minimal Dev;E:\Program Files (x86)\Steam\steamapps\common\Arma 3\@Arma-ofstream;" -world=empty -noSplash -skipIntro -exThreads=7 -enableHT -hugePages -noPause "C:\Users\sentepu\Documents\Arma 3 - Other Profiles\dev\mpmissions\Vindicta\Vindicta.Altis\mission.sqm"

Echo Waiting for server kill

pause

goto reboot
