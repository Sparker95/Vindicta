/*
The main Location thread.
*/
params ["_loc", ["_debug", true]];

//diag_log "Hello from location thread!";

private _alertState = _loc getVariable ["l_alertState", LOC_AS_safe];

private _distanceSpawn = 300;
private _distanceDespawn = _distanceSpawn + 100;
private _sleepInterval = 0.5;

private _name = _loc getVariable ["l_name", "_"];
private _spawned = false;
sleep (random _sleepInterval);

private _gar = [_loc] call loc_fnc_getMainGarrison;
private _side = [_gar] call gar_fnc_getSide;

while {true} do
{
	sleep _sleepInterval;
	//diag_log format ["fn_locationThread.sqf: location: %1, simulation: %2", _name, simulationEnabled _loc];
	if(_spawned) then
	{
		if({_x distance _loc < _distanceSpawn && (side _x != _side || (isPlayer _x))} count allUnits == 0) then //If garrison must be despawned
		{
			[_loc] call loc_fnc_stopAlertStateScript;
			[_loc] call loc_fnc_stopEnemiesScript;
			[_loc] call loc_fnc_despawnAllGarrisons;
			waitUntil //Wait until the garrison has spawned
			{
				sleep _sleepInterval;
				!([_gar] call gar_fnc_isSpawned)
			};
			_spawned = false;
		};
	}
	else //If not spawned
	{
		if({_x distance _loc < _distanceSpawn && ((side _x != _side) || (isPlayer _x))} count allUnits > 0) then //If garrison needs to be spawned
		{
			[_loc] call loc_fnc_spawnAllGarrisons;
			waitUntil //Wait until the garrison has spawned
			{
				sleep _sleepInterval;
				[_gar] call gar_fnc_isSpawned
			};
			//Start enemies management script
			[_loc] call loc_fnc_restartEnemiesScript;
			//Start alert state script
			[_loc] call loc_fnc_restartAlertStateScript;
			_spawned = true;
		};
	};
	
	//Check alert state
	//todo Implement alert state cool-down
	private _ASInt = _loc getVariable ["l_alertStateInternal", 0];
	private _ASExt = _loc getVariable ["l_alertStateExternal", 0];
	private _ASReq = selectMax [_ASInt, _ASExt]; //Required new alert state. Just max of them for now.
	if(_ASReq != _alertState) then //If it's needed to change the alert state
	{
		_alertState = _ASReq;
		_loc setVariable ["l_alertState", _ASReq];
		if(_spawned) then //If spawned, start a new script
		{
			diag_log format ["Location: %1 switching to new alert state: %2", _name, _ASReq];
			[_loc] call loc_fnc_restartAlertStateScript;
		};
		
		//Update the map
		//todo redo the map update system
		[_loc] call loc_fnc_updateMarker;
	};
};