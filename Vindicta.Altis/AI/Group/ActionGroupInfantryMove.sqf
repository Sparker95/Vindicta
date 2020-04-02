#include "common.hpp"

/*
Group will move to specified place on foot. Units will regroup around their squad leader, dismounting their vehicles.

Parameter tags:
TAG_POS

Authors: Sen, Sparker
*/

#define pr private

CLASS("ActionGroupInfantryMove", "ActionGroup")

	VARIABLE("pos");

	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		
		pr _pos = CALLSM2("Action", "getParameterValue", _parameters, TAG_POS);
		T_SETV("pos", ZERO_HEIGHT(_pos));
		
	} ENDMETHOD;

	// logic to run when the goal is activated
	METHOD("activate") {
		params [P_THISOBJECT, P_BOOL("_instant")];
		private _pos = T_GETV("pos");


		T_CALLM2("applyGroupBehaviour", "DIAMOND", "AWARE");
		T_CALLM0("clearWaypoints");
		T_CALLM0("regroup");

		private _hG = T_GETV("hG");
		// Add a move waypoint
		private _wp = _hG addWaypoint [_pos, -1, 0];
		_wp setWaypointType "MOVE";
		_wp setWaypointFormation "DIAMOND";
		_wp setWaypointBehaviour "AWARE";
		_wp setWaypointSpeed "NORMAL";
		_wp setWaypointCompletionRadius 10;
		_hG setCurrentWaypoint _wp;
		
		// Give goals to units to regroup
		pr _AI = T_GETV("AI");
		pr _group = GETV(_AI, "agent");
		pr _inf = CALLM0(_group, "getInfantryUnits");
		{
			pr _unitAI = CALLM0(_x, "getAI");
			CALLM4(_unitAI, "addExternalGoal", "GoalUnitInfantryRegroup", 0, [[TAG_INSTANT ARG _instant]], _AI);
		} forEach _inf;

		// Set state
		T_SETV("state", ACTION_STATE_ACTIVE);

		// Return ACTIVE state
		ACTION_STATE_ACTIVE

	} ENDMETHOD;

	// logic to run each update-step
	METHOD("process") {
		params [P_THISOBJECT];

		T_CALLM0("failIfEmpty");

		private _state = T_CALLM0("activateIfInactive");

		if (_state == ACTION_STATE_ACTIVE) then {
			// check if one of the group is near _pos
			private _hG = T_GETV("hG");
			private _leader = leader _hG;
			private _destination = T_GETV("pos");
			// Leader is closer than 20 meters from destination, all units are less than 50m to the leader
			private _isGroupNearPos = ((_leader distance2D _destination) < 20) && ((units _hG) findIf { (_x distance2D _leader) > 50} == -1);

			// Return the current state
			if (_isGroupNearPos) then {
				_state = ACTION_STATE_COMPLETED
			} else {
				private _waypoints = waypoints _hG;
				// Groups have minimum 1 waypoint, just reactivate if waypoint is gone
				if(count _waypoints <= 1) then {
					_state = ACTION_STATE_INACTIVE;
				};
			}
		};

		T_SETV("state", _state);
		_state
	} ENDMETHOD;

	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [P_THISOBJECT];

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
