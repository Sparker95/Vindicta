#include "common.hpp"

CLASS("ActionGroupMoveToPos", "ActionGroup")

	VARIABLE("pos");

	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_parameters", [], [[]]] ];
		T_SETV("pos", _parameters select 1);
	} ENDMETHOD;

	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];
		private _pos = T_GETV("pos");

	 	// Set behaviour
		private _hG = GETV(_thisObject, "hG");
		_hG setBehaviour "SAFE";
		{_x doFollow (leader _hG)} forEach (units _hG);
		_hG setFormation "DIAMOND";

		// Delete all waypoints
		while {(count (waypoints _hG)) > 0} do {
			deleteWaypoint [_hG, ((waypoints _hG) select 0) select 1];
		};

		// Add a move waypoint
		private _wp = _hG addWaypoint [_pos, 0, 0];
		_wp setWaypointType "MOVE";
		_wp setWaypointFormation "DIAMOND";
		_wp setWaypointBehaviour "SAFE";
		_hG setCurrentWaypoint _wp;

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
			// check if one of the group is near _pos
			private _hG = GETV(_thisObject, "hG");
			private _destination = GETV(_thisObject, "pos");
			private _isGroupNearPos = false;
			{
				private _unitPos = getPos _x;
				private _distance = _destination distance _unitPos;
				if (_distance < 20) exitWith { _isGroupNearPos = true; };
			} forEach (units _hG);

			// Return the current state
			if (_isGroupNearPos) then { _state = ACTION_STATE_COMPLETED } else { _state = ACTION_STATE_ACTIVE };
		};

		T_SETV("state", _state);
		_state
	} ENDMETHOD;

	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];

		// Delete the goal
		private _AI = T_GETV("AI") ;
		CALLM2(_AI, "deleteExternalGoal", "GoalGroupMoveToPos", "");
	} ENDMETHOD;

ENDCLASS;
