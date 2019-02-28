#include "common.hpp"
#define OFSTREAM_FILE "Help.rpt"

CLASS("ActionGroupMoveToPos", "ActionGroup")

	VARIABLE("pos");

	METHOD("new") {
		params [ ["_thisObject", "", [""]] , ["_AI", "", [""]] , ["_pos", [], []] ];
		T_SETV("pos", _pos);
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
		while {(count (waypoints _hG)) > 0} do
		{
			deleteWaypoint [_hG, ((waypoints _hG) select 0) select 1];
		};

		// Add a move waypoint
		private _wp = _hG addWaypoint [_pos, 0, 0];
		_wp setWaypointType "MOVE";
		_wp setWaypointFormation "DIAMOND";
		_wp setWaypointBehaviour "SAFE";
		_hG setCurrentWaypoint _wp;

		// TODO Give a goal to units
		// private _group = GETV(T_GETV("AI"), "agent");
		// private _units = CALLM0(_group, "getUnits");
		// {
		// 	private _unitAI = CALLM0(_x, "getAI");
		// 	CALLM4(_unitAI, "addExternalGoal", "GoalUnitDismountCurrentVehicle", 0, [], _AI);
		// } forEach _units;

		// Set state
		SETV(_thisObject, "state", ACTION_STATE_ACTIVE);

		// Return ACTIVE state
		ACTION_STATE_ACTIVE

	} ENDMETHOD;

	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];

		private _state = CALLM0(_thisObject, "activateIfInactive");

		if (_state == ACTION_STATE_ACTIVE) then {
			// check if one of the group is near _pos
			private _hG = GETV(_thisObject, "hG");
			private _destination = GETV(_thisObject, "pos");
			private _isGroupNearPos = false;
			{
				private _unitPos = getPos _x;
				private _distance = _destination distance _unitPos;
				if (_distance < 30) exitWith { _isGroupNearPos = true; };
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
		OOP_INFO_1("terminated: _thisObject: %1", _thisObject);

		// Delete the goal to dismount vehicles
		// pr _group = GETV(T_GETV("AI"), "agent");
		// pr _units = CALLM0(_group, "getUnits");
		// {
		// 	pr _unitAI = CALLM0(_x, "getAI");
		// 	CALLM2(_unitAI, "deleteExternalGoal", "GoalUnitDismountCurrentVehicle", "");
		// } forEach _units;
	} ENDMETHOD;

ENDCLASS;
