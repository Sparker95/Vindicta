/*
Functions used in fn_SAD.sqf
*/

AI_fnc_task_SAD_vehicleGroupFSM =
{
	/*
	FSM used to handle the state of a vehicle group and their vehicle.
	*/
	params ["_to", "_groupHandle", "_vehicle", "_stateArray"];
	diag_log format ["AI_fnc_task_SAD_vehicleGroupFSM: input args: %1", _this];
	_stateArray params ["_state", "_stateChanged"];
	
	private _units = (units _groupHandle) select {alive _x};
	
	switch (_state) do {
		case "INIT": {
			diag_log "AI_fnc_task_SAD_vehicleGroupFSM: INIT state recognized!";
			//Is everyone in the assigned vehicle?
			if (({(vehicle _x) isEqualTo _vehicle} count _units) == (count _units)) then {		
				_state = "FIGHT";
				_stateChanged = true;
			} else {
				_state = "MOUNT";
				_stateChanged = true;
			};
		};
		
		case "MOUNT": {
			_units orderGetIn true;
			//Is everyone in the assigned vehicle?
			if (({(vehicle _x) isEqualTo _vehicle} count _units) == (count _units)) then {		
				_state = "FIGHT";
				_stateChanged = true;
			};
		};
		
		case "FIGHT": {
			if (_stateChanged) then {
				//Create waypoints
				(_to getVariable "AI_taskParams") params ["_target", "_searchRadius", "_timeout"];
				private _targetPos = _target;
				if(_targetPos isEqualType objNull) then  { _targetPos = getPos _target; };
				_groupHandle call AI_fnc_deleteAllWaypoints;
				_groupHandle setCombatMode "RED";
				private _dirStart = _targetPos getDir (leader _groupHandle);
				//Add waypoints around the area
				for "_i" from 0 to 11 do
				{
					private _pos = _targetPos getPos [(12-_i)*(_searchRadius+100)/12, _dirStart + (_i*360/6)];
					private _wp = _groupHandle addWaypoint [_pos vectorAdd [0, 0, 1], 60];
					_wp setWaypointCompletionRadius (0.2*_searchRadius);
					_wp setWaypointType "MOVE";
				};
				_stateChanged = false;
			};
			
			//Check state transitions
			call {
				//Is everything destroyed?
				if ((count _units == 0) || !(canMove _vehicle)) exitWith {
					_state = "FAILURE";
					_stateChanged = true;
				};
				
				//Did someone dismount?
				if (({(vehicle _x) isEqualTo _vehicle} count _units) != (count _units)) exitWith {
					_state = "MOUNT";
					_stateChanged = true;
				};
			};
		};
		
		case "FAILURE": {
		};
	};
	
	//Return value
	[_state, _stateChanged]
};