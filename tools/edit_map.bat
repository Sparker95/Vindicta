rem @echo off
cd /d "%~dp0.."
if exist editing.Altis (copy /Y Vindicta.Altis\mission.sqm mission.Altis.sqm & del editing.Altis)
if exist editing.Enoch (copy /Y Vindicta.Enoch\mission.sqm mission.Enoch.sqm & del editing.Enoch)
if exist editing.Malden (copy /Y Vindicta.Malden\mission.sqm mission.Malden.sqm & del editing.Malden)

copy /Y mission.%1.sqm Vindicta.%1\mission.sqm
echo editing.%1 >editing.%1