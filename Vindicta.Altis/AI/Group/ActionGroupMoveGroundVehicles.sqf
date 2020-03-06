#include "common.hpp"

/*
Class: ActionGroup.ActionGroupMoveGroundVehicles
Handles moving of a group with multiple or single ground vehicles.

Tags:
TAG_POS
TAG_MOVE_RADIUS
TAG_MAX_SPEED_KMH
*/

#define pr private

// Needed vehicle separation in meters
#define SEPARATION 18
#define SPEED_MAX 25
#define SPEED_MIN 5

#ifndef RELEASE_BUILD
#define DEBUG_FORMATION
#endif

CLASS("ActionGroupMoveGroundVehicles", "ActionGroup")
	
	VARIABLE("pos");
	VARIABLE("radius"); // Completion radius
	VARIABLE("speedLimit"); // The current speed limit
	VARIABLE("maxSpeed"); // The maximum speed in this action, can be received as parameter
	VARIABLE("time");
	VARIABLE("route"); // Optional route to use, or just give one waypoint if no route was given
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_parameters", [], [[]]] ];
		
		pr _pos = CALLSM2("Action", "getParameterValue", _parameters, TAG_POS);
		T_SETV("pos", _pos);
		
		pr _radius = CALLSM2("Action", "getParameterValue", _parameters, TAG_MOVE_RADIUS);
		T_SETV("radius", _radius);

		pr _maxSpeedKmh = CALLSM2("Action", "getParameterValue", _parameters, TAG_MAX_SPEED_KMH);
		if (isNil "_maxSpeedKmh") then {
			_maxSpeedKmh = SPEED_MAX;
		};
		T_SETV("maxSpeed", _maxSpeedKmh);

		// Route can be optionally passed or not
		pr _route = CALLSM2("Action", "getParameterValue", _parameters, TAG_ROUTE);
		if (isNil "_route") then {
			_route = [];
		};
		T_SETV("route", _route);

		T_SETV("time", time);
		
		T_SETV("speedLimit", SPEED_MIN);
	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];
		
		pr _hG = T_GETV("hG");
		pr _AI = T_GETV("AI");
		pr _pos = T_GETV("pos");
		pr _group = GETV(T_GETV("AI"), "agent");
		pr _allVehicles = (CALLM0(_group, "getUnits") select {CALLM0(_x, "isVehicle")}) apply {CALLM0(_x, "getObjectHandle")};
		pr _vehLead = vehicle (leader (CALLM0(_group, "getGroupHandle")));
		
		// Regroup units by distance
		pr _leader = CALLM0(_group, "getLeader");
		if (_leader == "") exitWith {
			OOP_ERROR_1("Group has no leader: %1", _group);
			T_SETV("state", ACTION_STATE_FAILED);
			ACTION_STATE_FAILED
		};
		if (count _allVehicles > 1) then {
			pr _distAndUnits = (CALLM0(_group, "getUnits") - [_leader]) apply {
				pr _hO = CALLM0(_x, "getObjectHandle");
				[_hO distance _vehLead, _x];
			};
			_distAndUnits sort true; // Ascending
			CALLM2(_group, "postMethodAsync", "sort", [_distAndUnits apply {_x select 1}]); // Post message to sort the group
		};
		
		// Delete all previous waypoints
		while {(count (waypoints _hG)) > 0} do { deleteWaypoint ((waypoints _hG) select 0); };
		
		// Set group behaviour
		_hG setBehaviour "SAFE";
		_hG setFormation "COLUMNG";
		_hG setCombatMode "GREEN"; // Hold fire, defend only
		
		// Give a waypoint to move
		/*
		pr _wp = _hG addWaypoint [_pos, 0];
		_wp setWaypointType "MOVE";
		_wp setWaypointFormation "COLUMN";
		_wp setWaypointBehaviour "SAFE";
		_wp setWaypointCombatMode "GREEN";
		_hG setCurrentWaypoint _wp;
		*/
		{
			private _vehHandle = _x;
			_vehHandle limitSpeed 666666; //Set the speed of all vehicles to unlimited
			_vehHandle setConvoySeparation SEPARATION;
			//_vehHandle forceFollowRoad true;
		} forEach _allVehicles;
		(vehicle (leader _hG)) limitSpeed T_GETV("speedLimit");
		
		// Set time last called
		T_SETV("time", time);

		// Give goals to all drivers except the lead driver
		pr _leader = CALLM0(_group, "getLeader");
		if (_leader != "") then {
			if (CALLM0(_leader, "isAlive")) then {
				pr _groupUnits = CALLM0(_group, "getUnits");
				{
					if (CALLM0(_x, "isInfantry") && (_x != _leader)) then {
						pr _unitAI = CALLM0(_x, "getAI");
						if (CALLM0(_unitAI, "getAssignedVehicleRole") == "DRIVER") then {
							// Add goal
							CALLM4(_unitAI, "addExternalGoal", "GoalUnitFollowLeaderVehicle", 0, [], _AI);
						};
					};
				} forEach _groupUnits;
				
				// Lead vehicle gets a special goal
				pr _leaderAI = CALLM0(_leader, "getAI");
				pr _route = T_GETV("route");
				pr _parameters = [[TAG_POS, _pos], [TAG_ROUTE, _route]];
				CALLM4(_leaderAI, "addExternalGoal", "GoalUnitMoveLeaderVehicle", 0, _parameters, _AI);

				// Return ACTIVE state
				T_SETV("state", ACTION_STATE_ACTIVE);
				ACTION_STATE_ACTIVE
			} else {
				// Fail if leader is not alive
				T_SETV("state", ACTION_STATE_FAILED);
				ACTION_STATE_FAILED
			};
		} else {
			// leader is "", wtf
			OOP_ERROR_1("Group has no leader: %1", _group);
			T_SETV("state", ACTION_STATE_FAILED);
			ACTION_STATE_FAILED
		};

	} ENDMETHOD;
	
	// Logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		CALLM0(_thisObject, "failIfNoInfantry");
		
		pr _state = CALLM0(_thisObject, "activateIfInactive");

		if (_state == ACTION_STATE_ACTIVE) then {
			pr _hG = T_GETV("hG"); // Group handle
			pr _pos = T_GETV("pos");
			pr _radius = T_GETV("radius");
			
			pr _dt = time - T_GETV("time") + 0.001;
			T_SETV("time", time);
			
			//Check the separation of the convoy
			private _sCur = CALLM0(_thisObject, "getMaxSeparation"); //The current maximum separation between vehicles
			#ifdef DEBUG_FORMATION
			OOP_DEBUG_MSG(">>> Current separation: %1", [_sCur]);
			#endif
			if(_sCur > 3*SEPARATION) then
			{
				//We are driving too fast!
				pr _speedLimit = T_GETV("speedLimit");
				if(_speedLimit > SPEED_MIN) then
				{
					_speedLimit = (_speedLimit - _dt*2) max SPEED_MIN;
					T_SETV("speedLimit", _speedLimit);
					(vehicle (leader _hG)) limitSpeed _speedLimit;
					#ifdef DEBUG_FORMATION
					OOP_DEBUG_MSG(">>> Slowing down! New speed: %1", [_speedLimit]);
					#endif
				};
			}
			else
			{
				//We are driving too slow!
				pr _speedLimit = T_GETV("speedLimit");
				if(_speedLimit < SPEED_MAX) then
				{
					_speedLimit = (_speedLimit + _dt*4) min T_GETV("maxSpeed");
					T_SETV("speedLimit", _speedLimit);
					(vehicle (leader _hG)) limitSpeed _speedLimit;
					#ifdef DEBUG_FORMATION
					OOP_DEBUG_MSG(">>> Accelerating! New speed: %1", [_speedLimit]);
					#endif
				};
			};
			
			
			// Check if enough vehicles have arrived
			// For now just check if leader is there
			pr _radius = T_GETV("radius");
			if (( (vehicle leader _hG) distance _pos ) < _radius) then {
				OOP_INFO_0("Arrived at destionation");
				_state = ACTION_STATE_COMPLETED
			};
		};
		
		_state
	} ENDMETHOD;
	
	//Gets the maximum separation between vehicles in convoy
	METHOD("getMaxSeparation") {
		params [["_thisObject", "", [""]]];

		pr _group = GETV(T_GETV("AI"), "agent");
		pr _allVehicles = (CALLM0(_group, "getUnits") select {CALLM0(_x, "isVehicle")}) apply {CALLM0(_x, "getObjectHandle")};
		pr _vehLead = vehicle (leader (CALLM0(_group, "getGroupHandle")));
		
		//diag_log format ["All vehicles: %1", _allVehicles];
		//diag_log format ["Lead vehicle: %1", _vehLead];
		private _vehArraySort = _allVehicles apply {[_x distance _vehLead, _x]};


		//diag_log format ["Unsorted array: %1", _vehArraySort];
		_vehArraySort sort true; //Ascending
		//diag_log format ["Sorted array: %1", _vehArraySort];
		//Get the max separation
		private _dMax = 0;
		private _c = count _allVehicles;
		for "_i" from 0 to (_c - 2) do
		{
			_d = (_vehArraySort select _i select 1) distance (_vehArraySort select (_i + 1) select 1);
			if (_d > _dMax) then {_dMax = _d;};
		};
		_dMax
		
	} ENDMETHOD;
	
	METHOD("handleUnitsRemoved") {
		params [["_thisObject", "", [""]], ["_units", [], [[]]] ];
		
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		
		// Delete given goals
		pr _hG = T_GETV("hG");
		pr _AI = T_GETV("AI");
		pr _pos = T_GETV("pos");
		pr _group = GETV(T_GETV("AI"), "agent");
		
		// Stop the group
		// Delete waypoints
		while {(count (waypoints _hG)) > 0} do { deleteWaypoint ((waypoints _hG) select 0); };
		// Add a move waypoint at the current position of the leader
		pr _wp = _hG addWaypoint [getPos leader _hG, 0];
		_wp setWaypointType "MOVE";
		_hG setCurrentWaypoint _wp;
		doStop (leader _hG);
		
		// Delete given goals
		pr _groupUnits = CALLM0(_group, "getUnits");
		{
			pr _unitAI = CALLM0(_x, "getAI");
			CALLM2(_unitAI, "deleteExternalGoal", "GoalUnitFollowLeaderVehicle", _AI);
			CALLM2(_unitAI, "deleteExternalGoal", "GoalUnitMoveLeaderVehicle", _AI);
		} forEach _groupUnits;
		
	} ENDMETHOD;

ENDCLASS;