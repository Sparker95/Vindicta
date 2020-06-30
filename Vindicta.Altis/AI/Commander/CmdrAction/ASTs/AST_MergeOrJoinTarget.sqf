#include "common.hpp"

/*
Class: AI.CmdrAI.CmdrAction.ASTs.AST_MergeOrJoinTarget
Merge to a garrison or join a location. Does NOT use an order or move the garrison at all,
just directly merges/joins.

Parent: <ActionStateTransition>
*/
#define OOP_CLASS_NAME AST_MergeOrJoinTarget
CLASS("AST_MergeOrJoinTarget", "ActionStateTransition")
	VARIABLE_ATTR("successState", [ATTR_PRIVATE ARG ATTR_SAVE]);
	VARIABLE_ATTR("fromGarrDeadState", [ATTR_PRIVATE ARG ATTR_SAVE]);
	VARIABLE_ATTR("targetDeadState", [ATTR_PRIVATE ARG ATTR_SAVE]);

	// Inputs
	VARIABLE_ATTR("fromGarrIdVar", [ATTR_PRIVATE ARG ATTR_SAVE]);
	VARIABLE_ATTR("targetVar", [ATTR_PRIVATE ARG ATTR_SAVE]);

	/*
	Method: new
	Create an AST to merge or join a garrison to a target.

	Parameters:
		_action - <CmdrAction>, action this AST is part of, for debugging purposes
		_fromStates - Array of <CMDR_ACTION_STATE>, states this AST is valid from
		_successState - <CMDR_ACTION_STATE>, state to return after success
		_fromGarrDeadState - <CMDR_ACTION_STATE>, state to return when garrison performing the action is dead
		_targetDeadState - <CMDR_ACTION_STATE>, state to return when the target is dead
		_fromGarrIdVar - IN <AST_VAR>(Number), <Model.GarrisonModel> Id of the garrison performing the action
		_targetVar - IN <AST_VAR>(<CmdrAITarget>), target to merge or join to
	*/
	METHOD(new)
		params [P_THISOBJECT, 
			P_OOP_OBJECT("_action"),
			P_ARRAY("_fromStates"),
			P_AST_STATE("_successState"),
			P_AST_STATE("_fromGarrDeadState"),
			P_AST_STATE("_targetDeadState"),
			P_AST_VAR("_fromGarrIdVar"),
			P_AST_VAR("_targetVar")
		];
		
		T_SETV("fromStates", _fromStates);

		T_SETV("successState", _successState);
		T_SETV("fromGarrDeadState", _fromGarrDeadState);
		T_SETV("targetDeadState", _targetDeadState);
		T_SETV("fromGarrIdVar", _fromGarrIdVar);
		T_SETV("targetVar", _targetVar);
	ENDMETHOD;

	public override METHOD(apply)
		params [P_THISOBJECT, P_STRING("_world")];
		ASSERT_OBJECT_CLASS(_world, "WorldModel");

		private _action = T_GETV("action");
		private _fromGarrId = T_GET_AST_VAR("fromGarrIdVar");
		ASSERT_MSG(_fromGarrId isEqualType 0, "fromGarrIdVar should be a garrison Id");
		private _fromGarr = CALLM(_world, "getGarrison", [_fromGarrId]);
		ASSERT_OBJECT(_fromGarr);

		// If the detachment died then we return the appropriate state
		if(CALLM0(_fromGarr, "isDead")) exitWith { 
			#ifndef _SQF_VM
			// We don't want this warning in auto-tests, its already being tested
			OOP_WARNING_MSG("[w %1 a %2] Garrison %3 is dead so can't merge to target", [_world ARG _action ARG LABEL(_fromGarr)]);
			#endif
			FIX_LINE_NUMBERS()
			T_GETV("fromGarrDeadState")
		};

		T_GET_AST_VAR("targetVar") params ["_targetType", "_target"];

		private _targetDead = false;

		switch(_targetType) do {
			// If the target is a garrison we merge to it
			case TARGET_TYPE_GARRISON: {
				ASSERT_MSG(_target isEqualType 0, "TARGET_TYPE_GARRISON target type expects a garrison ID");
				private _toGarr = CALLM(_world, "getGarrison", [_target]);
				ASSERT_OBJECT(_toGarr);
				// Check if the target garrison is dead
				_targetDead = if(CALLM0(_toGarr, "isDead") && (IS_NULL_OBJECT(CALLM0(_toGarr, "getLocation"))) ) then {
					#ifndef _SQF_VM
					// We don't want this warning in auto-tests, its already being tested
					OOP_WARNING_MSG("[w %1 a %2] Garrison %3 can't merge to dead garrison %4", [_world ARG _action ARG LABEL(_fromGarr) ARG LABEL(_toGarr)]);
					#endif
					FIX_LINE_NUMBERS()
					true
				} else {
					// If target is alive then do the merge
					if(GETV(_world, "type") != WORLD_TYPE_REAL) then {
						OOP_INFO_MSG("[w %1 a %2] %3 comp %4", [_world ARG _action ARG LABEL(_fromGarr) ARG GETV(_fromGarr, "composition")]);
						OOP_INFO_MSG("[w %1 a %2] %3 before comp %4", [_world ARG _action ARG LABEL(_toGarr) ARG GETV(_toGarr, "composition")]);
						CALLM(_fromGarr, "mergeSim", [_toGarr]);
						OOP_INFO_MSG("[w %1 a %2] %3 after comp %4", [_world ARG _action ARG LABEL(_toGarr) ARG GETV(_toGarr, "composition")]);
					} else {
						CALLM(_fromGarr, "mergeActual", [_toGarr]);
					};
					OOP_INFO_MSG("[w %1 a %2] Merged %3 to %4", [_world ARG _action ARG LABEL(_fromGarr) ARG LABEL(_toGarr)]);
					false
				};
			};
			// If the target is a location then we can join it
			case TARGET_TYPE_LOCATION: {
				ASSERT_MSG(_target isEqualType 0, "TARGET_TYPE_LOCATION target type expects a location ID");
				private _loc = CALLM(_world, "getLocation", [_target]);
				ASSERT_OBJECT(_loc);
				private _side = GETV(_fromGarr, "side");
				// Check for an existing garrison at the location, of the same side as us
				private _toGarr = CALLM(_loc, "getGarrison", [_side]);
				// If there is an existing garrison at the location then we merge to it
				if(!IS_NULL_OBJECT(_toGarr)) then {
					// Perform the merge
					if(GETV(_world, "type") != WORLD_TYPE_REAL) then {
						CALLM(_fromGarr, "mergeSim", [_toGarr]);
					} else {
						CALLM(_fromGarr, "mergeActual", [_toGarr]);
					};
					OOP_INFO_MSG("[w %1 a %2] Merged %3 to %4 (at %5)", [_world ARG _action ARG LABEL(_fromGarr) ARG LABEL(_toGarr) ARG LABEL(_loc)]);
				} else {
					// Otherwise we join the location ourselves
					if(GETV(_world, "type") != WORLD_TYPE_REAL) then {
						CALLM(_fromGarr, "joinLocationSim", [_loc]);
					} else {
						CALLM(_fromGarr, "joinLocationActual", [_loc]);
					};
					OOP_INFO_MSG("[w %1 a %2] Joined %3 to %4", [_world ARG _action ARG LABEL(_fromGarr) ARG LABEL(_loc)]);
				};
			};
			default {
				FAILURE("Target must be a garrison or location");
			};
		};
		if(_targetDead) then {
			T_GETV("targetDeadState")
		} else {
			T_GETV("successState")
		}
	ENDMETHOD;
ENDCLASS;

#ifdef _SQF_VM

#define CMDR_ACTION_STATE_FAILED_GARRISON_DEAD CMDR_ACTION_STATE_CUSTOM+1
#define CMDR_ACTION_STATE_FAILED_TARGET_DEAD CMDR_ACTION_STATE_CUSTOM+2

["AST_MergeOrJoinTarget.new", {
	SCOPE_IGNORE_ACCESS(CmdrAction);
	private _action = NEW("CmdrAction", []);
	private _thisObject = NEW("AST_MergeOrJoinTarget", 
		[_action]+
		[[CMDR_ACTION_STATE_START]]+
		[CMDR_ACTION_STATE_END]+
		[CMDR_ACTION_STATE_FAILED_GARRISON_DEAD]+
		[CMDR_ACTION_STATE_FAILED_TARGET_DEAD]+
		[CALLM1(_action, "createVariable", 0)]+
		[CALLM1(_action, "createVariable", [TARGET_TYPE_GARRISON, 0])]
	);
	
	private _class = OBJECT_PARENT_CLASS_STR(_thisObject);
	["Object exists", !(isNil "_class")] call test_Assert;
}] call test_AddTest;

AST_MergeOrJoinTarget_test_fn = {
	SCOPE_IGNORE_ACCESS(CmdrAction);
	params ["_world", "_garrison", "_target"];
	private _action = NEW("CmdrAction", []);
	private _thisObject = NEW("AST_MergeOrJoinTarget", 
		[_action]+
		[[CMDR_ACTION_STATE_START]]+
		[CMDR_ACTION_STATE_END]+
		[CMDR_ACTION_STATE_FAILED_GARRISON_DEAD]+
		[CMDR_ACTION_STATE_FAILED_TARGET_DEAD]+
		[CALLM1(_action, "createVariable", GETV(_garrison, "id"))]+
		[CALLM1(_action, "createVariable", _target)]
	);
	T_CALLM("apply", [_world])
};

["AST_MergeOrJoinTarget.apply(sim, garrison=dead)", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_FUTURE]);
	private _garrison = NEW("GarrisonModel", [_world ARG "<undefined>"]);
	private _endState = [_world, _garrison, [TARGET_TYPE_POSITION, [1, 2, 3]]] call AST_MergeOrJoinTarget_test_fn;
	["State after apply is correct", _endState == CMDR_ACTION_STATE_FAILED_GARRISON_DEAD] call test_Assert;
}] call test_AddTest;

["AST_MergeOrJoinTarget.apply(sim, target=garrison)", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_FUTURE]);
	private _garrison = NEW("GarrisonModel", [_world ARG "<undefined>"]);
	SETV(_garrison, "efficiency", EFF_MIN_EFF);
	private _targetGarrison = NEW("GarrisonModel", [_world ARG "<undefined>"]);
	SETV(_targetGarrison, "efficiency", EFF_MIN_EFF);

	private _endState = [_world, _garrison, [TARGET_TYPE_GARRISON, GETV(_targetGarrison, "id")]] call AST_MergeOrJoinTarget_test_fn;
	["State after apply is correct", _endState == CMDR_ACTION_STATE_END] call test_Assert;
	["Source garrison correct after", CALLM0(_garrison, "isDead")] call test_Assert;
	["Target garrison correct after", GETV(_targetGarrison, "efficiency") isEqualTo EFF_ADD(EFF_MIN_EFF, EFF_MIN_EFF)] call test_Assert;
}] call test_AddTest;

["AST_MergeOrJoinTarget.apply(sim, target=garrison+dead)", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_FUTURE]);
	private _garrison = NEW("GarrisonModel", [_world ARG "<undefined>"]);
	SETV(_garrison, "efficiency", EFF_MIN_EFF);
	private _targetGarrison = NEW("GarrisonModel", [_world ARG "<undefined>"]);

	private _endState = [_world, _garrison, [TARGET_TYPE_GARRISON, GETV(_targetGarrison, "id")]] call AST_MergeOrJoinTarget_test_fn;
	["State after apply is correct", _endState == CMDR_ACTION_STATE_FAILED_TARGET_DEAD] call test_Assert;
}] call test_AddTest;

["AST_MergeOrJoinTarget.apply(sim, target=location+empty)", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_FUTURE]);
	private _garrison = NEW("GarrisonModel", [_world ARG "<undefined>"]);
	SETV(_garrison, "efficiency", EFF_MIN_EFF);
	private _targetLocation = NEW("LocationModel", [_world ARG "<undefined>"]);

	private _endState = [_world, _garrison, [TARGET_TYPE_LOCATION, GETV(_targetLocation, "id")]] call AST_MergeOrJoinTarget_test_fn;
	["State after apply is correct", _endState == CMDR_ACTION_STATE_END] call test_Assert;
	["Garrison assigned to location after", CALLM0(_garrison, "getLocation") isEqualTo _targetLocation] call test_Assert;

}] call test_AddTest;

#endif
