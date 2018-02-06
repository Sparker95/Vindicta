/*
Script object is an object associated with a running script which provides an interface between the spawned thread and external scripts.
*/

scriptObject_fnc_create =
{
	params ["_scriptName", "_extraParams", ["_name", "Noname scriptObject"]];
	//private _so = groupLogic createUnit ["LOGIC", [12, 12, 12], [], 0, "NONE"]; //logic object
	private _so = "Sign_Arrow_Large_Pink_F" createVehicle [12, 12, 12];
	hideObjectGlobal _so;
	_so setVariable ["so_scriptName", _scriptName, false];
	_so setVariable ["so_name", _name, false];
	_so setVariable ["so_extraParams", _extraParams, false];
	_so setVariable ["so_scriptHandle", scriptNull, false];
	_so setVariable ["so_run", false, false]; //This will be used to terminate the thread
	
	//Return value
	_so
};

scriptObject_fnc_delete =
{
	/*
	Deletes the script object.
	
	_stopScript - if true, the function will wait until the script has terminated.
		Must be FALSE to delete the script object from the scriptObject's thread.
	*/
	params ["_so", ["_stopScript", true]];
	if (isNull _so) exitWith {};
	if (_stopScript) then {
		_so call scriptObject_fnc_stop;
	};
	deleteVehicle _so;
};

scriptObject_fnc_start =
{
	params ["_so"];
	if (isNull _so) exitWith {};
	//Ensure that we don't create two threads
	private _hScript = _so getVariable "so_scriptHandle";
	_so setVariable ["so_run", false, false]; //Notify the script that it must terminate
	if(!scriptDone _hScript) then
	{
		if(canSuspend) then
		{ //Wait until the script self-terminates
			waitUntil {scriptDone _hScript};
		};
	};
	//Start a new thread
	private _extraParams = _so getVariable "so_extraParams";
	private _scriptName = _so getVariable "so_scriptName";
	_so setVariable ["so_run", true, false];
	private _hScript = [_so, _extraParams] call (call compile _scriptName); //The called script must return a script handle
	if (isNil "_hScript" || isNull _hScript) then {
		diag_log format ["ERROR: scriptObject: %1, can't start script: %2, script handle: %3", _so getVariable "so_name", _scriptName, _hScript];
	}
	else {
		_so setVariable ["so_scriptHandle", _hScript];
	};
};

scriptObject_fnc_stop =
{
	params ["_so"];
	if (isNull _so) exitWith {};
	//Terminate the script in case it wasn't terminated
	private _hScript = _so getVariable "so_scriptHandle";
	_so setVariable ["so_scriptHandle", scriptNull, false];
	_so setVariable ["so_run", false, false]; //Notify the script that it must terminate
	if(!scriptDone _hScript) then
	{
		if(canSuspend) then
		{ //Wait until the script self-terminates
			waitUntil {scriptDone _hScript};
		};
	};
};

scriptObject_fnc_isRunning =
{
	params ["_so"];
	private _hScript = _so getVariable "so_scriptHandle";
	private _return = !(scriptDone _hScript);
	_return
};