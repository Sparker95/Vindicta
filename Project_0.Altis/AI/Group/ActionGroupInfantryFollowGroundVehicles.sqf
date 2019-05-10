#include "common.hpp"

/*
Group will follow the last vehicle in the first vehicle group.


Authors: Sen, Sparker
*/

#define pr private

CLASS("ActionGroupInfantryFollowGroundVehicles", "ActionGroup")

	VARIABLE("waypointUpdateTime");

	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_parameters", [], [[]]] ];
		
		T_SETV("waypointUpdateTime", time);

	} ENDMETHOD;

	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];

	 	// Set behaviour
		private _hG = GETV(_thisObject, "hG");
		_hG setBehaviour "AWARE";
		{_x doFollow (leader _hG)} forEach (units _hG);
		_hG setFormation "COLUMN";

		// Delete all waypoints
		while {(count (waypoints _hG)) > 0} do {
			deleteWaypoint [_hG, ((waypoints _hG) select 0) select 1];
		};
		
		// Give goals to units to regroup
		pr _AI = T_GETV("AI");
		pr _group = GETV(_AI, "agent");
		pr _inf = CALLM0(_group, "getInfantryUnits");
		{
			pr _unitAI = CALLM0(_x, "getAI");
			CALLM4(_unitAI, "addExternalGoal", "GoalUnitInfantryRegroup", 0, [], _AI);
		} forEach _inf;

		T_SETV("waypointUpdateTime", time);

		// Set state
		T_SETV("state", ACTION_STATE_ACTIVE);

		// Return ACTIVE state
		ACTION_STATE_ACTIVE

	} ENDMETHOD;

	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];

		CALLM0(_thisObject, "failIfEmpty");

		private _state = CALLM0(_thisObject, "activateIfInactive");

		if (_state == ACTION_STATE_ACTIVE) then {
			// Give a new waypoint periodycally
			if ((time - T_GETV("waypointUpdateTime")) > 17) then {
				pr _group = T_GETV("group");
				pr _gar = CALLM0(_group, "getGarrison");
				pr _vehGroups = CALLM(_gar, "findGroupsByType", [GROUP_TYPE_VEH_NON_STATIC]);
				if (count _vehGroups >= 1) then {	
					// Find the vehicle furthest from the leader
					pr _vehGroup = _vehGroups select 0;
					pr _vehUnits = CALLM0(_vehGroup, "getVehicleUnits");
					pr _vehGroupLeader = CALLM0(_vehGroup, "getLeader");
					pr _hLeader = CALLM0(_vehGroupLeader, "getObjectHandle");
					pr _hVehicles = _vehUnits apply {
						pr _hO = CALLM0(_x, "getObjectHandle");
						[_hO distance2D _hLeader, _hO]
					};
					_hVehicles sort false; // Descending

					// Object handle of the last vehicle
					pr _hOVeh = _hVehicles select 0 select 1;

					pr _hG = T_GETV("hG");
					if (((leader _hG) distance _hOVeh) > 30) then {
						// Delete all old waypoints and add a new one
						while {(count (waypoints _hG)) > 0} do {
							deleteWaypoint [_hG, ((waypoints _hG) select 0) select 1];
						};

						// Find pos to the left of the last vehicle to make them stay on the left side of the road
						// Infantry loves to move on the left side for some reason
						pr _pos = _hOVeh getPos [9, (getDir _hOVeh) - 90];

						private _wp = _hG addWaypoint [_pos, 4, 0];
						_wp setWaypointType "MOVE";
						_wp setWaypointFormation "COLUMN";
						_wp setWaypointBehaviour "AWARE";
						_wp setWaypointSpeed "FULL";
						_hG setCurrentWaypoint _wp;

						T_SETV("waypointUpdateTime", time);
					};
				};
			};
		};

		T_SETV("state", _state);
		_state
	} ENDMETHOD;

	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];

		// Delete given goals
		pr _AI = T_GETV("AI");
		pr _group = GETV(_AI, "agent");
		pr _inf = CALLM0(_group, "getInfantryUnits");
		{
			pr _unitAI = CALLM0(_x, "getAI");
			CALLM2(_unitAI, "deleteExternalGoal", "GoalUnitInfantryRegroup", "");
		} forEach _inf;

	} ENDMETHOD;

ENDCLASS;
