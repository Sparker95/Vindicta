/*
_params: [_loc, _isAnybodyWatching]
*/

params ["_scriptObject", "_params"];

private _hScript = [_scriptObject, _params] spawn
{
	params ["_scriptObject", "_params"];
	private _gars = _scriptObject getVariable ["AI_garrisons", objNull];

	private _loc = _params select 0;
	private _isAnybodyWatching = _params select 1;

	private _hGsCasual = [];
	private _hGsCasualCrew = [];
	private _hGsPatrol = [];
	private _hGsSentry = [];
	
	for "_i" from 0 to ((count _gars) - 1) do
	{
		private _gar = _gars select _i;
		//Groups with casual behaviour
		_hGsCasual append ([_gar, G_GT_idle] call gar_fnc_findGroupHandles);

		//Groups with casual crew behaviour
		_hGsCasualCrew append ([_gar, G_GT_veh_static] call gar_fnc_findGroupHandles);
		_hGsCasualCrew append ([_gar, G_GT_veh_non_static] call gar_fnc_findGroupHandles);

		//Groups with patrol behaviour
		_hGsPatrol append ([_gar, G_GT_patrol] call gar_fnc_findGroupHandles);

		//Sentries
		_hGsSentry append ([_gar, G_GT_building_sentry] call gar_fnc_findGroupHandles);
	};
	
	//Set behaviours
	{_x setBehaviour "SAFE";} forEach _hGsCasual;
	{_x setBehaviour "SAFE";} forEach _hGsCasualCrew;
	{_x setBehaviour "SAFE";} forEach _hGsPatrol;
	{_x setBehaviour "AWARE";} forEach _hGsSentry;

	//Start behaviour scripts for groups
	private _patrolWaypoints = [_loc] call loc_fnc_getPatrolWaypoints; //Array with positions for patrol waypoints
	//Call AI functions
	//diag_log format ["Casual groups: %1", _hGsCasual];
	//diag_log format ["Patrol groups: %1", _hGsPatrol];
	private _scriptHandle = [_scriptObject, _hGsCasual, _loc, 200, _isAnybodyWatching]
						spawn AI_fnc_behaviourCasual;
	[_scriptObject, _scriptHandle] call AI_fnc_registerScriptHandle;

	_scriptHandle = [_scriptObject, _hGsCasualCrew, _isAnybodyWatching]
						spawn AI_fnc_behaviourCasualCrew;
	[_scriptObject, _scriptHandle] call AI_fnc_registerScriptHandle;

	_scriptHandle = [_scriptObject, _hGsPatrol, _patrolWaypoints, _isAnybodyWatching]
						spawn AI_fnc_behaviourPatrol;
	[_scriptObject, _scriptHandle] call AI_fnc_registerScriptHandle;
};

_hScript