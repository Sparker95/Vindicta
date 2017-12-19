/*
Terminates the behaviour script started with fn_startBehaviourScript. ALso terminates the sub-threads created inside the behaviour script itself.
*/

params ["_groups"];

private _scripts = [];
private _units = [];
private _hBS = scriptNull; //Handle to the Behaviour Script
{
	_hBS = _x getVariable ["AI_hBS", nil];
	//Find behaviour scripts of this group
	if(!(isNil "_hBS")) then
	{
		_scripts pushback _hBS;
	};
	//Find behaviour scripts of units of this group
	{
		_hBS = _x getVariable ["AI_hBS", nil];
		if(!(isNil "_hBS")) then
		{
			_scripts pushback _hBS;
		};
	} forEach (units _x);
}forEach _groups;

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