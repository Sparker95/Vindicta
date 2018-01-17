/*
This function stops a medium level AI script for specified garrison.
*/

params ["_scriptObject"];

//Terminate all low level scripts
private _scripts = _scriptObject getVariable ["AI_hScripts", []]; //Array of [_scriptHandle, _params, _stopScriptName]
private _scriptHandles = [];

//Terminate all scripts
{
	private _scriptHandle = _x select 0;
	private _params = _x select 1;
	private _stopScriptName = _x select 2;
	//If there has been assigned a script to be called before script termination, call it
	if (_stopScriptName != "") then
	{
		//diag_log format ["       params: %1  script name: %2", _params, _stopScriptName];
		[_params] call (call compile _stopScriptName);
	};
	terminate _scriptHandle;
	_scriptHandles pushBack _scriptHandle;
}forEach _scripts;

if(canSuspend) then //If this is called in scheduled environment
{
	private _c = count _scriptHandles;
	if(_c != 0) then
	{
		waitUntil //Wait until all the scripts are terminated
		{
			({scriptDone _x} count _scriptHandles) == _c
		};
	};
};

//Delete the object
deleteVehicle _scriptObject;
