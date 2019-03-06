@echo off 
cd /d "%~dp0sqf-vm"
sqfvm.exe -a --parse-only --load "./../../Project_0.Altis" -i "./../../%~1"
rem sqfvm.exe -a --load "./../../Project_0.Altis" -i "./../../%~1"
