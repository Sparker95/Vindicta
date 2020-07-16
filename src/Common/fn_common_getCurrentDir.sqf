/*
Made by [Utopia] Amoury
Returns path to current directory

Example:
[__FILE__] call vin_fnc_common_getCurrentDir;
Returns: string "folderName\" if called from folderName\file.sqf
*/

params ["_fullPath"]; 

_fullPath = toLower _fullPath; 
_completeMissionName = toLower format [".%1",worldName]; 

_missionDir = _fullPath select [(_fullPath find _completeMissionName) + count _completeMissionName]; 
_allDirs = _missionDir splitString "\"; 
if (count _allDirs <= 1) exitWith { 
    ""
}; 
_allDirs deleteAt (count _allDirs - 1); 
(_allDirs joinString "\") + "\"; 
