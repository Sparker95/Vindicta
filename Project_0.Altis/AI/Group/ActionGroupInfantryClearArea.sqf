#include "common.hpp"

/*
Class: ActionGroup.ActionGroupInfantryClearArea
The whole group regroups and gets some waypoints to clear the area
*/

#define pr private


CLASS("ActionGroupInfantryClearArea", "ActionGroup")
	
	VARIABLE("pos");
	VARIABLE("radius");
	VARIABLE("inCombat");
	
	// ------------ N E W ------------
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_parameters", [], [[]]] ];

		pr _pos = CALLSM2("Action", "getParameterValue", _parameters, TAG_POS);
		pr _radius = CALLSM2("Action", "getParameterValue", _parameters, TAG_RADIUS);
		T_SETV("pos", _pos);
		T_SETV("radius", _radius);
		T_SETV("inCombat", false);

	} ENDMETHOD;

	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_to", "", [""]]];		
		
		pr _pos = T_GETV("pos");
		pr _radius = T_GETV("radius");
		
		// Set behaviour
		pr _hG = GETV(_thisObject, "hG");
		_hG setBehaviour "AWARE";
		_hG setSpeedMode "NORMAL";
		_hG setCombatMode "RED";
		{_x doFollow (leader _hG)} forEach (units _hG);
		
		// Set state
		SETV(_thisObject, "state", ACTION_STATE_ACTIVE);
		
		// Add goals to units
		pr _AI = T_GETV("AI");
		pr _group = GETV(_AI, "agent");
		pr _inf = CALLM0(_group, "getInfantryUnits");
		{
			pr _unitAI = CALLM0(_x, "getAI");
			CALLM4(_unitAI, "addExternalGoal", "GoalUnitInfantryRegroup", 0, [], _AI);
		} forEach _inf;
		
		// Give some waypoints
		// Delete previous waypoints
		while {(count (waypoints _hG)) > 0} do { deleteWaypoint [_hG, ((waypoints _hG) select 0) select 1];	};
		private _wp0 = _hG addWaypoint [_pos, _radius];
		_wp0 setWaypointCompletionRadius 20;
		_wp0 setWaypointType "SAD";
		_wp0 setWaypointFormation "WEDGE";
		for "_i" from 0 to 8 do {
			private _wp = _hG addWaypoint [_pos, _radius];
			_wp setWaypointCompletionRadius 20;
			_wp setWaypointType "SAD";
			_wp setWaypointFormation "WEDGE";
		};
		_hG setCurrentWaypoint _wp0;
		
		// Create a cycle waypoint
		pr _wpCycle = _hG addWaypoint [waypointPosition _wp0, 0];
		_wpCycle setWaypointType "CYCLE";
		
		
		// Return ACTIVE state
		T_SETV("state", ACTION_STATE_ACTIVE);
		ACTION_STATE_ACTIVE
		
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		CALLM0(_thisObject, "failIfEmpty");
		
		CALLM0(_thisObject, "activateIfInactive");
		
		// This action is terminal because it's never over right now
		
		// Delete all waypoints when we know about some enemies
		T_PRVAR(hG);
		if ((behaviour (leader _hG)) == "COMBAT") then {
			if (!T_GETV("inCombat")) then {
				// Delete waypoints once, let them chose what to do on their own
				while {(count (waypoints _hG)) > 0} do { deleteWaypoint [_hG, ((waypoints _hG) select 0) select 1];	};
				OOP_INFO_0("Deleted waypoints");
				T_SETV("inCombat", true);
			};
		};
		
		// Return the current state
		ACTION_STATE_ACTIVE
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