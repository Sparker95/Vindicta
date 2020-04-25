@echo off
cd /d "%~dp0.."

if not exist Vindicta.Altis\mission.sqm goto :clean

ren Vindicta.Altis\mission.sqm mission.sqm.tmp
if errorlevel 1 (
    echo mission.sqm file is locked, close the editor before running this
    exit /b 0
)
ren Vindicta.Altis\mission.sqm.tmp mission.sqm
if exist editing.Altis (copy /Y Vindicta.Altis\mission.sqm mission.Altis.sqm & del editing.Altis)
if exist editing.Enoch (copy /Y Vindicta.Altis\mission.sqm mission.Enoch.sqm & del editing.Enoch)
if exist editing.Malden (copy /Y Vindicta.Altis\mission.sqm mission.Malden.sqm & del editing.Malden)
if exist editing.Staszow (copy /Y Vindicta.Altis\mission.sqm mission.Staszow.sqm & del editing.Staszow)
if exist editing.Beketov (copy /Y Vindicta.Altis\mission.sqm mission.Beketov.sqm & del editing.Beketov)
if exist editing.gm_weferlingen_summer (copy /Y Vindicta.Altis\mission.sqm mission.gm_weferlingen_summer.sqm & del editing.gm_weferlingen_summer)
goto :edit

:clean
if exist editing.Altis del editing.Altis
if exist editing.Enoch del editing.Enoch
if exist editing.Malden del editing.Malden
if exist editing.Staszow del editing.Staszow
if exist editing.Beketov del editing.Beketov
if exist editing.gm_weferlingen_summer del editing.gm_weferlingen_summer

:edit
copy /Y mission.%1.sqm Vindicta.%1\mission.sqm
echo editing.%1 >editing.%1