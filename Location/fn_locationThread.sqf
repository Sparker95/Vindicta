/*
The main Location thread.
*/
params ["_loc", ["_debug", true]];

//diag_log "Hello from location thread!";

private _alertState = _loc getVariable ["l_alertState", LOC_AS_safe];
private _alertStateScriptNames = [];
_alertStateScriptNames set [LOC_AS_none, "AI_fnc_alertStateSafe"];
_alertStateScriptNames set [LOC_AS_safe, "AI_fnc_alertStateSafe"];
_alertStateScriptNames set [LOC_AS_aware, "AI_fnc_alertStateAware"];
_alertStateScriptNames set [LOC_AS_combat, "AI_fnc_alertStateCombat"];

private _distanceSpawn = 300;
private _distanceDespawn = _distanceSpawn + 100;
private _sleepInterval = 0.5;

private _name = _loc getVariable ["l_name", "_"];
private _spawned = false;
sleep (random _sleepInterval);

private _gar = [_loc] call loc_fnc_getMainGarrison;
private _side = [_gar] call gar_fnc_getSide;

private _oEnemiesScript = scriptNull; //Handle to manage spotted enemies script
private _oAlertStateScript = scriptNull; //Handle to the alert state script

while {true} do
{
	sleep _sleepInterval;
	//diag_log format ["fn_locationThread.sqf: location: %1, simulation: %2", _name, simulationEnabled _loc];
	if(_spawned) then
	{
		if({_x distance _loc < _distanceSpawn && (side _x != _side || (isPlayer _x))} count allUnits == 0) then //If garrison must be despawned
		{
			[_oEnemiesScript] call AI_fnc_stopMediumLevelScript;
			[_oAlertStateScript] call AI_fnc_stopMediumLevelScript;
			[_loc] call loc_fnc_despawnAllGarrisons;
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
			_oEnemiesScript = [_gar, "AI_fnc_manageSpottedEnemies", [_loc, true]]
								call AI_fnc_startMediumLevelScript;
			//Start alert state script
			//_oAlertStateScript = [_gar, "AI_fnc_alertStateSafe", [_loc, false]]
			//					call AI_fnc_startMediumLevelScript;
			_oAlertStateScript = [_gar, _alertStateScriptNames select _alertState, [_loc, false]]
								call AI_fnc_startMediumLevelScript;
			_spawned = true;
		};
	};
	
	//Check alert state
	private _ASInt = _loc getVariable ["l_alertStateInternal", 0];
	private _ASExt = _loc getVariable ["l_alertStateExternal", 0];
	private _ASReq = selectMax [_ASInt, _ASExt]; //Required new alert state. Just max of them for now.
	if(_ASReq != _alertState) then //If it's needed to change the alert state
	{
		if(_spawned) then //If spawned, start a new script
		{
			diag_log format ["Location: %1 switching to new alert state: %2", _name, _ASReq];
			[_oAlertStateScript] call AI_fnc_stopMediumLevelScript;
			private _newScriptName = _alertStateScriptNames select _ASReq;
			_oAlertStateScript = [_gar, _newScriptName, [_loc, true]]
								call AI_fnc_startMediumLevelScript;
		};
		_alertState = _ASReq;
		_loc setVariable ["l_alertState", _ASReq];
		
		//Update the map
		//todo redo the map update system
		[_loc] call loc_fnc_updateMarker;
	};
};