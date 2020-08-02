#include "common.hpp"

#define OOP_CLASS_NAME ActionGarrisonMoveMounted
CLASS("ActionGarrisonMoveMounted", "ActionGarrisonMoveBase")

	protected override METHOD(assignMoveGoals)
		params [P_THISOBJECT, P_POSITION("_pos"), P_NUMBER("_radius"), P_ARRAY("_route"), P_BOOL("_instant")];

		private _AI = T_GETV("AI");
		private _gar = T_GETV("gar");

		private _vehGroups = CALLM1(_gar, "findGroupsByType", [GROUP_TYPE_VEH ARG GROUP_TYPE_STATIC]);
		if (count _vehGroups > 1) exitWith {
			OOP_WARNING_0("More than one vehicle group in the garrison!");
			ACTION_STATE_FAILED
		};

		// No instant move for this action we track unspawned progress already, and groups should be formed up and 
		// mounted already before it is called.
		private _args = ["GoalGroupMove", 0, [
			[TAG_POS, _pos],
			[TAG_MOVE_RADIUS, _radius],
			[TAG_ROUTE, _route]
		], _AI];
		private _vehGroup = _vehGroups#0;
		private _vehGroupAI = CALLM0(_vehGroup, "getAI");
		CALLM2(_vehGroupAI, "postMethodAsync", "addExternalGoal", _args);

		// Reset current location of this garrison
		CALLM0(_gar, "detachFromLocation");

		// Give goals to infantry groups
		private _infGroups = CALLM1(_gar, "findGroupsByType", GROUP_TYPE_INF);
		private _args = ["GoalGroupStayInVehicles", 0, [], _AI];
		{
			CALLM2(_x, "postMethodAsync", "addExternalGoal", _args);
		} forEach (_infGroups apply {CALLM0(_x, "getAI")});

		ACTION_STATE_ACTIVE
	ENDMETHOD;

	protected override METHOD(checkMoveGoals)
		params [P_THISOBJECT];

		private _gar = T_GETV("gar");
		private _AI = T_GETV("AI");

		private _vehGroups = CALLM1(_gar, "findGroupsByType", [GROUP_TYPE_VEH ARG GROUP_TYPE_STATIC]);
		if (CALLSM3("AI_GOAP", "anyAgentFailedExternalGoal", _vehGroups, "GoalGroupMove", _AI)) exitWith {
			ACTION_STATE_FAILED
		};

		private _infGroups = CALLM1(_gar, "findGroupsByType", GROUP_TYPE_INF);
		if (CALLSM3("AI_GOAP", "anyAgentFailedExternalGoal", _infGroups, "GoalGroupStayInVehicles", _AI)) exitWith {
			ACTION_STATE_FAILED
		};

		if (CALLSM3("AI_GOAP", "allAgentsCompletedExternalGoalRequired", _vehGroups, "GoalGroupMove", _AI)) exitWith {
			// If goals all agent goals completed then we shouldn't have got this far, as the garrison action
			// checks its own criteria for completion.
			// Therefore we reactivate to push out the goals again.
			// This strategy could be revisited if it doesn't work well (i.e. just rely on the group goals to validate correctness)
			ACTION_STATE_INACTIVE
		};

		ACTION_STATE_ACTIVE
	ENDMETHOD;

ENDCLASS;