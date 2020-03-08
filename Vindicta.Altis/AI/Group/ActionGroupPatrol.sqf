#include "common.hpp"

/*
Class: ActionGroup.ActionGroupPatrol
*/

#define pr private

CLASS("ActionGroupPatrol", "ActionGroup")
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];
		
		pr _hG = GETV(_thisObject, "hG");
		
		// Regroup
		(units _hG) commandFollow (leader _hG);
		
		// Set behaviour
		_hG setBehaviour "SAFE";
		
		// Set combat mode
		_hG setCombatMode "RED"; // Open fire, engage at will
		
		// Assign patrol waypoints
		pr _AI = GETV(_thisObject, "AI");
		pr _group = GETV(_AI, "agent");
		pr _type = CALLM0(_group, "getType");
		OOP_INFO_1("Started for AI: %1", _AI);
		pr _gar = CALLM0(_group, "getGarrison");
		pr _loc = CALLM0(_gar, "getLocation");
		
		pr _useDefaultPatrolWaypoints = true;
		pr _pos = [];
		pr _radius = 10;
		pr _waypoints = [];
		// Override behaviour for non-static vehicle groups
		// They must walk around their vehicles
		if (_type == GROUP_TYPE_VEH_NON_STATIC) then {
			// Crew of vehicle groups stays around their vehicle
			pr _vehUnits = CALLM0(_group, "getUnits") select {
				CALLM0(_x, "isVehicle")
			};
			if (count _vehUnits > 0) then {
				pr _vehUnit = selectRandom _vehUnits;
				pr _hO = CALLM0(_vehUnit, "getObjectHandle");
				_pos = getPos _hO;

				_radius = 10 + random 10;
				if (! (_pos isEqualTo [0, 0, 0])) then { // Better to be safe here, we don't want to be in the sea
					//for "_i" from 0 to 3 do {
						_waypoints pushBack [_pos#0 + random 13 - 6, _pos#1 + random 13 - 6, 0];
					//};
					_useDefaultPatrolWaypoints = false;
				};
			};
		};

		// Default waypoints
		// If at a location, takes waypoints from location border
		// If in field, adds some circular waypoints
		// Check if there is a location
		if (_useDefaultPatrolWaypoints) then {
			if (_loc != "") then {
				_waypoints = CALLM0(_loc, "getPatrolWaypoints");
			} else {
				// Generate some random patrol waypoints
				pr _angle = 0;
				while {_angle < 360} do {
					pr _newPos = (leader _hG) getPos [100 + random 40, _angle];
					_waypoints pushBack _newPos;
					_angle = _angle + 30;
				};
			};
		};
		
		// Remove assigned waypoints first
		while {(count (waypoints _hG)) > 0} do { deleteWaypoint ((waypoints _hG) select 0); };
		// Give waipoints to the group
		pr _direction = selectRandom [false, true];
		pr _count = count _waypoints;
		pr _indexStart = floor (random _count);
		pr _index = _indexStart;
		pr _i = 0;
		pr _wpIDs = []; // Array with waypoint IDs
		private _closestWPID = 0;
		private _minDist = 666666;
		while {_i < _count} do {
			private _wayPointPos = POS_TO_ATL(_waypoints select _index);
			pr _wp = _hG addWaypoint [_wayPointPos, 0];
			_wp setWaypointType "MOVE";
			_wp setWaypointBehaviour "SAFE"; //"AWARE"; //"SAFE";
			//_wp setWaypointForceBehaviour true; //"AWARE"; //"SAFE";
			_wp setWaypointSpeed "LIMITED"; //"FULL"; //"LIMITED";
			_wp setWaypointFormation "WEDGE";
			_wpIDs pushback (_wp select 1);
			
			// Also find the closest waypoint
			private _dist = leader _hG distance2D _wayPointPos;
			if(_dist < _minDist) then {
				_closestWPID = (_wp select 1);
				_minDist = _dist;
			};
			
			if(_direction) then	{ // Clockwise
				_index = _index + 1;
				if(_index == _count) then{_index = 0;};
			} else { //Counterclockwise
				_index = _index - 1;
				if(_index  < 0) then {_index = _count-1;};
			};
			_i = _i + 1;
		};
		
		// Add cycle waypoint
		if (count _waypoints > 1) then {
			pr _wp = _hG addWaypoint [POS_TO_ATL(_waypoints select _indexStart), 0]; //Cycle the waypoints
			_wp setWaypointType "CYCLE";
			_wp setWaypointBehaviour "SAFE";
			_wp setWaypointSpeed "LIMITED";
			_wp setWaypointFormation "WEDGE";
		};
		
		//Set the closest WP as current
		_hG setCurrentWaypoint [_hG, _closestWPID];
		
		// Give a goal to units
		pr _units = CALLM0(_group, "getInfantryUnits");
		{
			pr _unitAI = CALLM0(_x, "getAI");
			CALLM4(_unitAI, "addExternalGoal", "GoalUnitInfantryRegroup", 0, [], _AI);
		} forEach _units;

		// Set state
		SETV(_thisObject, "state", ACTION_STATE_ACTIVE);
		
		// Return ACTIVE state
		ACTION_STATE_ACTIVE
		
	} ENDMETHOD;
	
	// Logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		CALLM0(_thisObject, "failIfEmpty");
		
		CALLM0(_thisObject, "activateIfInactive");
		
		// Return the current state
		ACTION_STATE_ACTIVE
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		
		pr _hG = GETV(_thisObject, "hG");
		
		// Delete all waypoints
		while {(count (waypoints _hG)) > 0} do { deleteWaypoint ((waypoints _hG) select 0); };

				
		// Delete given goals
		pr _AI = T_GETV("AI");
		pr _group = GETV(_AI, "agent");
		pr _units = CALLM0(_group, "getUnits");
		{
			pr _unitAI = CALLM0(_x, "getAI");
			CALLM2(_unitAI, "deleteExternalGoal", "GoalUnitInfantryRegroup", "");
		} forEach _units;
		
	} ENDMETHOD;

ENDCLASS;