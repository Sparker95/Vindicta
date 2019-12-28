REM This kill arma and server processes and re launch arma server and a client connecting to it with LAN
REM Remember to change the paths
REM You need PBO manager for this one

@echo off
set PBOManager="C:\Program Files\PBO Manager v.1.4 beta\PBOConsole.exe"

title Vindicta MP Restarter
cls

E:
CD "E:\Program Files (x86)\Steam\steamapps\common\Arma 3"

:reboot
echo Killing arma3server_x64.exe
taskkill /F /IM arma3server_x64.exe /T
echo Killing arma3battleye.exe
taskkill /F /IM arma3battleye.exe /T
echo Killing arma3_x64.exe
taskkill /F /IM arma3_x64.exe /T
timeout /t 2

echo PBO the mod
%PBOManager% -pack "C:\Users\sen\Documents\Arma 3 - Other Profiles\dev\mpmissions\Vindicta.Stratis\Vindicta.Altis" "E:\Program Files (x86)\Steam\steamapps\common\Arma 3\MPMissions\Vindicta.Altis.pbo"

echo (%time%) Vindicta Server Starting
start arma3server_x64.exe -name=server -server -mod="E:\Program Files (x86)\Steam\steamapps\common\Arma 3\!Workshop\@CBA_A3;E:\Program Files (x86)\Steam\steamapps\common\Arma 3\!Workshop\@ace;E:\Program Files (x86)\Steam\steamapps\common\Arma 3\!Workshop\@Intercept Minimal Dev;E:\Program Files (x86)\Steam\steamapps\common\Arma 3\@Arma-ofstream;" -config=server.cfg -cfg=config.cfg -profiles="C:\Users\sen\Documents\Arma 3 - Other Profiles\serverDev" -nosound -nosplash

timeout /t 2

echo(%time%) Start arma client
start arma3_x64.exe -name=dev -mod="E:\Program Files (x86)\Steam\steamapps\common\Arma 3\!Workshop\@CBA_A3;E:\Program Files (x86)\Steam\steamapps\common\Arma 3\!Workshop\@ace;E:\Program Files (x86)\Steam\steamapps\common\Arma 3\!Workshop\@Intercept Minimal Dev;E:\Program Files (x86)\Steam\steamapps\common\Arma 3\@Arma-ofstream;" -world=empty -noSplash -skipIntro -exThreads=7 -enableHT -hugePages -noPause -connect=127.0.0.1

Echo Waiting for server kill

pause

goto reboot
