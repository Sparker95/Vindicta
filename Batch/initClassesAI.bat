@echo off 

REM Parameters: %1 - path to the folder relative to the mission folder for which the initClasses.sqf will be generated

REM Change current folder
set CDPrev=%CD%
cd /d "%~dp0..\%1\%2"

REM cache some parameters
set missionFolder=%1
set funcPath=%2

REM delete the old initClasses.sqf
del "initClasses.sqf"

REM loop through all .sqf files and add them to initClasses.sqf
@echo // Auto generated file>> initClasses.sqf
for %%f in (AI*.sqf) do call :printLine %%f
for %%f in (_Action*.sqf) do call :printLine %%f
for %%f in (Action*.sqf) do call :printLine %%f
for %%f in (Goal*.sqf) do call :printLine %%f
for %%f in (_Sensor*.sqf) do call :printLine %%f
for %%f in (Sensor*.sqf) do call :printLine %%f
for %%f in (initDatabase.sqf) do call :printLine %%f

REM Change current folder to the one we had when the file was called
echo Finished generating file for %1
echo CDPrev is %CDPrev%
cd "%CDPrev%"
goto:eof

:printLine
set filePathRelMission="%funcPath%%1"
@echo call compile preprocessFileLineNumbers %filePathRelMission%;>> initClasses.sqf
goto:eof