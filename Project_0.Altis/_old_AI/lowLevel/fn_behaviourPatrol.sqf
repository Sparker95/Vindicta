/*
Patrol script. Moves AIs between waypoints.
This script self-terminates right after start.
*/

params ["_scriptObject", "_groups", "_waypoints", ["_isAnybodyWatching", true]];

//Register this script if it will be terminated
[_scriptObject, _thisScript, _groups, "AI_fnc_deleteAllWaypoints"] call AI_fnc_registerScriptHandle;

private _group = grpNull;
private _wp = [];
private _i = 0;
private _c = 0;
private _index = 0;
private _indexStart = 0;
private _direction = 0;
{
	_i = 0;
	_c = count _waypoints;
	_group = _x;
	
	//Delete previous waypoints
	while {(count (waypoints _x)) > 0} do
	{
		deleteWaypoint [_x, ((waypoints _x) select 0) select 1];
	};
	
	_direction = selectrandom [false, true]; //Clockwise or counter-clockwise direction
	_indexStart = floor (random _c); //The starting waypoint for each group is random
	_index = _indexStart;
	_wpIDs = []; //IDs of added waypoints
	diag_log format ["Start waypoint: %1, direction: %2", _indexStart, _direction];
	(units _group) commandFollow (leader _group); //All: return to formation!
	while {_i < _c} do
	{
		_wp = _group addWaypoint [_waypoints select _index, 0]; //10];
		_wp setWaypointType "MOVE";
		_wp setWaypointBehaviour "SAFE"; //"AWARE"; //"SAFE";
		//_wp setWaypointForceBehaviour true; //"AWARE"; //"SAFE";
		_wp setWaypointSpeed "LIMITED"; //"FULL"; //"LIMITED";
		_wp setWaypointFormation "WEDGE";
		_wpIDs pushback (_wp select 1);

		//Test put an arrow at waypoint position
		//"Sign_Arrow_Large_Pink_F" createVehicle (_waypoints select _i);
		//

		if(_direction) then //Clockwise
		{
			_index = _index + 1;
			if(_index == _c) then{_index = 0;};
		}
		else //Counterclockwise
		{
			_index = _index - 1;
			if(_index  < 0) then {_index = _c-1;};
		};
		_i = _i + 1;
	};
	_wp = _group addWaypoint [_waypoints select _indexStart, 0]; //Cycle the waypoints
	_wp setWaypointType "CYCLE";
	_wp setWaypointBehaviour "SAFE";
	//_wp setWaypointForceBehaviour true;
	_wp setWaypointSpeed "LIMITED";
	_wp setWaypointFormation "WEDGE";
	//If units have just been spawned, teleport them to their patrol locations
	if(!_isAnybodyWatching) then
	{
		{
			_x setPos ((_waypoints select _indexStart) vectorAdd [-4+random 8, -4+random 8, 0]);
		}forEach (units _group);
	}
	else //Set the closest waypoint as active
	{
		//Find the closest waypoint
		private _closestWPID = 0;
		private _minDist = 666666;
		{
			private _dist = (leader _group) distance (waypointPosition [_group, _x]);
			if(_dist < _minDist) then
			{
				_closestWPID = _x;
				_minDist = _dist;
			};
		}forEach _wpIDs;
		//Set the closest WP as current
		_group setCurrentWaypoint [_group, _closestWPID];
	};
}forEach _groups;
