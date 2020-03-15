@echo off
cd /d "%~dp0"
if exist editing.Altis (copy /Y Vindicta.Altis\mission.sqm mission.Altis.sqm & del editing.Altis)
if exist editing.Enoch (copy /Y Vindicta.Enoch\mission.sqm mission.Enoch.sqm & del editing.Enoch)
if exist editing.Malden (copy /Y Vindicta.Malden\mission.sqm mission.Malden.sqm & del editing.Malden)
if exist editing.Staszow (copy /Y Vindicta.Staszow\mission.sqm mission.Staszow.sqm & del editing.Staszow)
if exist editing.Beketov (copy /Y Vindicta.Beketov\mission.sqm mission.Beketov.sqm & del editing.Beketov)
if exist editing.gm_weferlingen_summer (copy /Y Vindicta.gm_weferlingen_summer\mission.sqm mission.gm_weferlingen_summer.sqm & del editing.gm_weferlingen_summer)