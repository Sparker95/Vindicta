/*
Used inside the thread to start an AI script for specified garrison.
*/

#include "garrison.hpp"

params ["_lo", "_scriptName"];

//Check if another script is already running
private _hScript = _lo getVariable ["g_AIThreadHandle"];
if (!isNull _hScript) then //If another script is already running, stop it
{
	//[_lo] call gar_fnc_t_stopAIThread;
	terminate _hScript;
};

_hScript = [_lo] spawn (compile _scriptName);
_lo setVariable ["g_AIThreadHandle", _scriptHandle, false];
