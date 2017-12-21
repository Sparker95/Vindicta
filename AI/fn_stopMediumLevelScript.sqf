/*
This function stops a medium level AI script for specified garrison.
*/

params ["_scriptObject"];

//Terminate the medium level script
/*
if(!(scriptDone _scriptHandle)) then
{
	terminate _scriptHandle;
};
*/

//Terminate all low level scripts
private _scripts = _scriptObject getVariable ["AI_hScripts", []];

/*
{
	_hS = _x getVariable ["AI_hScript", nil];
	//Find low level script of every group
	if(!(isNil "_hS")) then
	{
		_scripts pushback _hS;
	};
	//Find scripts of individual units
	{
		_hS = _x getVariable ["AI_hScript", nil];
		if(!(isNil "_hS")) then
		{
			_scripts pushback _hS;
		};
	} forEach (units _x);
} forEach _hGs;
*/

//Terminate all scripts
{
	terminate _x;
}forEach _scripts;

if(canSuspend) then //If this is called in scheduled environment
{
	private _c = count _scripts;
	if(_c != 0) then
	{
		waitUntil //Wait until all the scripts are terminated
		{
			({scriptDone _x} count _scripts) == _c
		};
	};
};

//Delete the object
deleteVehicle _scriptObject;