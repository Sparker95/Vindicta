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
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_parameters", [], [[]]] ];
		
		pr _pos = CALLSM2("Action", "getParameterValue", _parameters, TAG_POS);
		T_SETV("pos", POS_TO_ATL(_pos));
		
	} ENDMETHOD;

	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];
		private _pos = T_GETV("pos");

	 	// Set behaviour
		private _hG = GETV(_thisObject, "hG");
		_hG setBehaviour "AWARE";
		{_x doFollow (leader _hG)} forEach (units _hG);
		_hG setFormation "DIAMOND";

		// Delete all waypoints
		while {(count (waypoints _hG)) > 0} do {
			deleteWaypoint [_hG, ((waypoints _hG) select 0) select 1];
		};

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
			CALLM4(_unitAI, "addExternalGoal", "GoalUnitInfantryRegroup", 0, [], _AI);
		} forEach _inf;

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
			private _leader = leader _hG;
			private _destination = GETV(_thisObject, "pos");
			// Leader is closer than 20 meters from destination, all units are less than 50m to the leader
			private _isGroupNearPos = ((_leader distance2D _destination) < 20) && ((units _hG) findIf { (_x distance2D _leader) > 50} == -1);

			// Return the current state
			if (_isGroupNearPos) then {
				_state = ACTION_STATE_COMPLETED
			} else {
				private _waypoints = waypoints _hG;
				if(count _waypoints == 0) then {
					_state = ACTION_STATE_FAILED;
				};
			}
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
