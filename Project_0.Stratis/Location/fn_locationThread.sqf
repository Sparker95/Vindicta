/*
The main Location thread.
*/
params ["_loc", ["_debug", true]];

//diag_log "Hello from location thread!";

private _alertState = _loc getVariable ["l_alertState", LOC_AS_safe];

private _distanceSpawn = 1300;
private _distanceDespawn = _distanceSpawn + 100;
private _sleepInterval = 0.5;

private _name = _loc getVariable ["l_name", "_"];
private _spawned = false;
sleep (random _sleepInterval);

private _gar = [_loc] call loc_fnc_getMainGarrison;
private _side = [_gar] call gar_fnc_getSide;

private _forceSpawnTimer = _loc getVariable ["l_forceSpawnTimer", 0];

private _oEnemiesScript = objNull;

while {true} do
{
	sleep _sleepInterval;
	_forceSpawnTimer = _loc getVariable ["l_forceSpawnTimer", 0];
	_forceSpawnTimer = _forceSpawnTimer - _sleepInterval;
	_loc setVariable ["l_forceSpawnTimer", _forceSpawnTimer, false];
	
	//diag_log format ["fn_locationThread.sqf: location: %1, simulation: %2", _name, simulationEnabled _loc];
	if(_spawned) then
	{
		if({_x distance _loc < _distanceSpawn && (side _x != _side || (isPlayer _x))} count allUnits == 0 &&
			_forceSpawnTimer <= 0) then //If garrison must be despawned
		{
			[_loc] call loc_fnc_stopAlertStateScript;
			[globalEnemyMonitor, _oEnemiesScript] call sense_fnc_enemyMonitor_removeScript;
			[_loc] call loc_fnc_stopEnemiesScript;
			_oEnemiesScript = objNull;
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
		if({_x distance _loc < _distanceSpawn && ((side _x != _side) || (isPlayer _x))} count allUnits > 0 ||
			_forceSpawnTimer > 0) then //If garrison needs to be spawned
		{
			//[_loc] call loc_fnc_spawnAllGarrisons;
			waitUntil //Wait until the garrison has spawned
			{
				sleep _sleepInterval;
				[_gar] call gar_fnc_isSpawned
			};
			//Start enemies management script
			_oEnemiesScript = [_loc] call loc_fnc_restartEnemiesScript;
			[globalEnemyMonitor, _oEnemiesScript] call sense_fnc_enemyMonitor_addScript;
			//Start alert state script
			[_loc] call loc_fnc_restartAlertStateScript;
			_spawned = true;
		};
	};
	
	//Check alert state
	//Internal alert state
	private _ASInt = if(_spawned) then
	{_oEnemiesScript call AI_fnc_getRequestedAlertState;}
	else
	{LOC_AS_safe};
	private _ASSound = _loc getVariable ["l_alertStateSound", LOC_AS_safe];
	_loc setVariable ["l_alertStateSound", LOC_AS_safe, false];
	//External alert state
	private _ASExt = LOC_AS_safe; //todo also request alert state from the headquarters
	//Required new alert state
	private _ASReq = selectMax [_ASInt, _ASExt, _ASSound]; //Required new alert state. Just max of them for now.
	//Switch to new alert state if needed
	if(_ASReq != _alertState) then
	{
		private _changeAS = false;
		if(_ASReq < _alertState) then
		{
			private _t = _loc getVariable ["l_alertStateTimer", 0];
			_t = _t - _sleepInterval;
			_loc setVariable ["l_alertStateTimer", _t, 0];
			if (_t < 0) then
			{
				_changeAS = true;
			};
		}
		else
		{
			_changeAS = true;
		};
		
		if(_changeAS) then
		{
			_alertState = _ASReq;
			_loc setVariable ["l_alertState", _ASReq];
			if(_spawned) then //If spawned, start a new AI alert state script
			{
				private _txt = format ["Location: %1 switching to new alert state: %2", _name, _ASReq];
				diag_log _txt;
				systemChat _txt;
				[_loc] call loc_fnc_restartAlertStateScript;
			};
			//Update the map
			//todo redo the map update system
			[_loc] call loc_fnc_updateMarker;
		};
	};
};