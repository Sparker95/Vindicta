#include "common.hpp"

/*
Class: ActionGroup.ActionGroupRelax
*/

#define pr private

#define THIS_ACTION_NAME "MyAction"

CLASS("ActionGroupRelax", "ActionGroup")
	
	// ------------ N E W ------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]] ];

	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];		
		
		// Set behaviour
		pr _AI = T_GETV("AI");
		pr _hG = GETV(_thisObject, "hG");
		_hG setBehaviour "SAFE";
		{_x doFollow (leader _hG)} forEach (units _hG);
		_hG setFormation "DIAMOND";
		
		// Find some random position at the location and go there
		pr _group = GETV(T_GETV("AI"), "agent");
		pr _type = CALLM0(_group, "getType");
		pr _gar = CALLM0(_group, "getGarrison");
		pr _loc = CALLM0(_gar, "getLocation");
		pr _useDefaultRandomPos = true;
		pr _pos = [];
		pr _radius = 10;
		if (_type == GROUP_TYPE_VEH_NON_STATIC) then {
			// Crew of vehicle groups stays aroudn their vehicle
			pr _vehUnits = CALLM0(_group, "getUnits") select {
				CALLM0(_x, "isVehicle")
			};
			if (count _vehUnits > 0) then {
				pr _vehUnit = selectRandom _vehUnits;
				pr _hO = CALLM0(_vehUnit, "getObjectHandle");
				_pos = getPos _hO;
				_radius = 10 + random 10;
				if (! (_pos isEqualTo [0, 0, 0])) then { // Better to be safe here, we don't want to be in the sea
					_useDefaultRandomPos = false;
				};
			};
		};

		// Standard code for default random position
		if (_useDefaultRandomPos) then {
			// Non-vehicle group infantry units just walk around the location randomly
			if (!IS_NULL_OBJECT(_loc)) then {
				_pos = CALLM0(_loc, "getRandomPos");
				_radius = (100 max GETV(_loc, "boundingRadius")) * 1.25
			} else {
				pr _lp = getPos leader _hG;
				_pos = [(_lp select 0) - 30 + random 60, (_lp select 1) - 30 + random 60, 0];
				_radius = 200 + random 150 ;
			};
		};
		
		// Delete all waypoints
		while {(count (waypoints _hG)) > 0} do {
			deleteWaypoint [_hG, ((waypoints _hG) select 0) select 1];
		};

		if (random 10 < 5) then {
			// Give waipoints to the group
			pr _i = 0;
			pr _waypoints = []; // Array with waypoint IDs
			pr _angleStart = random 360;
			while {_i < 5} do {
				pr _wp = _hG addWaypoint [_pos getPos [_radius, _angleStart + _i*2*360/5], 0];
				_wp setWaypointType "MOVE";
				_wp setWaypointBehaviour "SAFE"; //"AWARE"; //"SAFE";
				//_wp setWaypointForceBehaviour true; //"AWARE"; //"SAFE";
				_wp setWaypointSpeed "LIMITED"; //"FULL"; //"LIMITED";
				_wp setWaypointFormation "WEDGE";
				_waypoints pushback _wp;

				_i = _i + 1;
			};
			
			// Add cycle waypoint
			pr _wp = _hG addWaypoint [_pos getPos [_radius, _angleStart + _i*2*360/5], 0]; //Cycle the waypoints
			_wp setWaypointType "CYCLE";
			_wp setWaypointBehaviour "SAFE";
			_wp setWaypointSpeed "LIMITED";
			_wp setWaypointFormation "WEDGE";

			// Set current waypoint
			_hG setCurrentWaypoint (_waypoints select 0);
		} else {

			// Add a move waypoint
			pr _wp = _hG addWaypoint [_pos, 20, 0];
			_wp setWaypointType "MOVE";
			_wp setWaypointFormation "DIAMOND";
			_wp setWaypointBehaviour "SAFE";
			_hG setCurrentWaypoint _wp;
		};



		// Give a goal to units
		pr _units = CALLM0(_group, "getInfantryUnits");
		{
			pr _unitAI = CALLM0(_x, "getAI");
			CALLM4(_unitAI, "addExternalGoal", "GoalUnitDismountCurrentVehicle", 0, [], _AI);
		} forEach _units;
		
		// Set state
		SETV(_thisObject, "state", ACTION_STATE_ACTIVE);
		
		// Return ACTIVE state
		ACTION_STATE_ACTIVE
		
	} ENDMETHOD;
	
	// logic to run each update-step
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
		
		// Delete the goal to dismount vehicles
		pr _group = GETV(T_GETV("AI"), "agent");
		pr _units = CALLM0(_group, "getInfantryUnits");
		{
			pr _unitAI = CALLM0(_x, "getAI");
			CALLM2(_unitAI, "deleteExternalGoal", "GoalUnitDismountCurrentVehicle", "");
		} forEach _units;
	} ENDMETHOD;

ENDCLASS;