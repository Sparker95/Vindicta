/*
This script handles execution of a move task assigned to a garrison of only infantry units
*/

#define DEBUG
#define SLEEP_RESOLUTION 0.01
#define SLEEP_TIME 2

params ["_to"];

private _hScript = [_to] spawn 
{
	params ["_to"];
	
	//Read task variables
	private _taskParams = _to getVariable "AI_taskParams";
	_taskParams params ["_dest", "_compRadius"];
	private _destPos = _dest;
	if (_destPos isEqualType objNull) then { _destPos = getPos _dest; };
	private _gar = _to getVariable "AI_garrison";
	
	//Find all groups and units
	private _hgs = [_gar, -1] call gar_fnc_findGroupHandles;
	//private _hus = [];
	//{ _hus append (units _x); } forEach _hgs;
	
	//Create waypoints
	_hgs call AI_fnc_deleteAllWaypoints;
	for "_i" from 0 to ((count _hgs) - 1) do {
		private _g = _hgs select _i;
		private _wp0 = _g addWaypoint [_destPos, 10];
		_wp0 setWaypointType "MOVE";
		_wp0 setWaypointCombatMode "AWARE";
		_wp0 setWaypointCombatmode "GREEN";
	};
	
	private _run = true;
	private _t = time;
	while {_run} do {
		//Update the array with groups
		_hgs = _hgs select {{alive _x} count (units _x) > 0};
		
		//Check if everything is destroyed
		if (count _hgs == 0) exitWith { //If the amount of alive groups is zero
			_to setVariable ["AI_taskState", "FAILURE"];
			_to setVariable ["AI_failReason", "DESTROYED"];
		};
		
		//Check if we have arrived
		private _arrived = false;
		if ({(leader _x) distance _dest < _compRadius} count _hgs == count _hgs) then {
			_to setVariable ["AI_taskState", "SUCCESS", false];
			_run = false;
		};
		
		if (_run) then
		{
			//Update time variable
			_t = time + SLEEP_TIME;
			//SLeep and check if it's ordered to stop the thread
			waitUntil
			{
				sleep SLEEP_RESOLUTION;
				(time > _t) || (!(_to getVariable "so_run"))
			};
		};
	};
};

_hScript