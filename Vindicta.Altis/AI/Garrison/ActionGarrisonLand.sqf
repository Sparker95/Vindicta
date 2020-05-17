#include "common.hpp"

#define OOP_CLASS_NAME ActionGarrisonLand
CLASS("ActionGarrisonLand", "ActionGarrisonBehaviour")

	VARIABLE("groups");

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		T_SETV("groups", []);
	ENDMETHOD;
	

	METHOD(activate)
		params [P_THISOBJECT, P_BOOL("_instant")];

		private _AI = T_GETV("AI");
		private _gar = GETV(_AI, "agent");
		private _groups = CALLM1(_gar, "findGroupsByType", GROUP_TYPE_VEH) select { CALLM0(_x, "isAirGroup") && { CALLM0(_x, "getAI") != NULL_OBJECT }};

		private _extraParams = [[TAG_INSTANT, _instant]];

		{ // foreach _groups
			private _groupAI = CALLM0(_x, "getAI");
			private _args = ["GoalGroupAirLand", 0, _extraParams, _AI];
			CALLM2(_groupAI, "postMethodAsync", "addExternalGoal", _args);
		} forEach _groups;

		T_SETV("groups", _groups);
		T_SETV("state", ACTION_STATE_ACTIVE);
		ACTION_STATE_ACTIVE
	ENDMETHOD;

	METHOD(process)
		params [P_THISOBJECT];

		private _gar = T_GETV("gar");
		if (!CALLM0(_gar, "isSpawned")) exitWith {
			T_SETV("state", ACTION_STATE_COMPLETED);
			ACTION_STATE_COMPLETED
		};

		private _state = T_CALLM0("activateIfInactive");
		if(CALLSM3("AI_GOAP", "allAgentsCompletedExternalGoalRequired", T_GETV("groups"), "GoalGroupAirLand", T_GETV("_AI"))) then {
			_state = ACTION_STATE_COMPLETED;
		};
		T_SETV("state", _state);
		_state
	ENDMETHOD;

ENDCLASS;