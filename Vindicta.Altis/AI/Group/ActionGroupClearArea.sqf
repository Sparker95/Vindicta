#include "common.hpp"

/*
Class: ActionGroup.ActionGroupClearArea
The whole group regroups and gets some waypoints to clear the area
*/

#define pr private


CLASS("ActionGroupClearArea", "ActionGroup")
	
	VARIABLE("pos");
	VARIABLE("radius");
	VARIABLE("inCombat");
	
	// ------------ N E W ------------
	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		pr _pos = CALLSM2("Action", "getParameterValue", _parameters, TAG_POS);
		_pos = ZERO_HEIGHT(_pos);
		T_SETV("pos", _pos);
		pr _radius = CALLSM2("Action", "getParameterValue", _parameters, TAG_CLEAR_RADIUS);
		T_SETV("radius", _radius);

		T_SETV("inCombat", false);

		// Force aware behaviour (overwriting anything that comes in via _parameters)
		// We and using Armas auto combat to determine when to stop patrolling to engage instead
		T_SETV("behaviour", "AWARE");
	} ENDMETHOD;

	// logic to run when the goal is activated
	METHOD("activate") {
		params [P_THISOBJECT];

		pr _AI = T_GETV("AI");
		pr _group = GETV(_AI, "agent");

		pr _groupType = CALLM0(_group, "getType");
		pr _isInf = _groupType in [GROUP_TYPE_IDLE, GROUP_TYPE_PATROL];

		pr _pos = T_GETV("pos");
		pr _radius = T_GETV("radius");		
		pr _isUrban = (CALLSM2("Location", "nearLocations", _pos, _radius) findIf {
			CALLM0(_x, "getType") == LOCATION_TYPE_CITY
		}) != NOT_FOUND;

		pr _formation = switch true do {
			case (_isInf && _isUrban): { "STAG COLUMN" };
			case (_isInf && !_isUrban): { "WEDGE" };
			default { "COLUMN" };
		};

		// Set behaviour
		T_CALLM4("applyGroupBehaviour", _formation, "AWARE", "RED", "NORMAL");
		T_CALLM0("regroup");

		// Set state
		T_SETV("state", ACTION_STATE_ACTIVE);

		// Add goals to units
		pr _inf = CALLM0(_group, "getInfantryUnits");

		if(_isInf) then {
			{
				pr _unitAI = CALLM0(_x, "getAI");
				CALLM4(_unitAI, "addExternalGoal", "GoalUnitInfantryRegroup", 0, [], _AI);
			} forEach _inf;
		} else {
			// Order get in vehicles
			(_inf apply { CALLM0(_x, "getObjectHandle") }) orderGetIn true;
		};

		// Give some waypoints
		// Delete previous waypoints
		T_CALLM0("clearWaypoints");

		T_PRVAR(hG);

		private _wp0 = _hG addWaypoint [_pos, _radius];
		_wp0 setWaypointCompletionRadius 20;
		_wp0 setWaypointType "SAD";
		for "_i" from 0 to 8 do {
			private _wp = _hG addWaypoint [_pos, _radius];
			_wp setWaypointCompletionRadius 20;
			_wp setWaypointType "SAD";
		};
		_hG setCurrentWaypoint _wp0;

		if(_isUrban || !_isInf) then {
			// Try and move all waypoints on to nearby roads
			{
				pr _pos = getWPPos _x;
				pr _nearestRoad = [_pos, 50] call BIS_fnc_nearestRoad;
				if(!isNull _nearestRoad) then {
					_x setWPPos position _nearestRoad;
				};
			} forEach (waypoints _hG);
		};

		// Create a cycle waypoint
		pr _wpCycle = _hG addWaypoint [waypointPosition _wp0, 0];
		_wpCycle setWaypointType "CYCLE";

		// Return ACTIVE state
		T_SETV("state", ACTION_STATE_ACTIVE);
		ACTION_STATE_ACTIVE

	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [P_THISOBJECT];
		
		T_CALLM0("failIfEmpty");
		
		T_CALLM0("activateIfInactive");
		
		// This action is terminal because it's never over right now
		
		// Delete all waypoints when we know about some enemies
		T_PRVAR(hG);
		if ((behaviour (leader _hG)) == "COMBAT") then {
			if (!T_GETV("inCombat")) then {
				// Delete waypoints once, let them chose what to do on their own
				T_CALLM0("clearWaypoints");
				OOP_INFO_0("Deleted waypoints");
				T_SETV("inCombat", true);
			};
		} else {
			if (T_GETV("inCombat") || count waypoints _hG <= 1) then {
				T_SETV("inCombat", false);
				// Force reactivation
				T_SETV("state", ACTION_STATE_INACTIVE);
			};
		};
		//ACTION_STATE_ACTIVE


		// Return the current state
		T_GETV("state")
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [P_THISOBJECT];

		// Clear the generated waypoints
		CALLM0("clearWaypoints");

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