#include "..\..\common.hpp"

CLASS("AST_MergeOrJoinTarget", "ActionStateTransition")
	VARIABLE_ATTR("action", [ATTR_PRIVATE]);
	VARIABLE_ATTR("successState", [ATTR_PRIVATE]);
	VARIABLE_ATTR("fromGarrDeadState", [ATTR_PRIVATE]);
	VARIABLE_ATTR("targetDeadState", [ATTR_PRIVATE]);

	// Inputs
	VARIABLE_ATTR("fromGarrId", [ATTR_PRIVATE]);
	VARIABLE_ATTR("target", [ATTR_PRIVATE]);

	METHOD("new") {
		params [P_THISOBJECT, 
			P_OOP_OBJECT("_action"),			// Source action for debugging purposes
			P_ARRAY("_fromStates"),				// States it is valid from
			P_AST_STATE("_successState"),		// State upon successful join
			P_AST_STATE("_fromGarrDeadState"), 	// State if the fromGarr is dead (should really not get this far if it is)
			P_AST_STATE("_targetDeadState"), 	// State if the target is dead (if is a garrison)
			// inputs
			P_AST_VAR("_fromGarrId"), 			// Id of garrison to merge/join from
			P_AST_VAR("_target")				// Target to merge/join to (garrison or location)
		];
		ASSERT_OBJECT_CLASS(_action, "CmdrAction");

		T_SETV("action", _action);
		T_SETV("fromStates", _fromStates);

		T_SETV("successState", _successState);
		T_SETV("fromGarrDeadState", _fromGarrDeadState);
		T_SETV("targetDeadState", _targetDeadState);
		T_SETV("fromGarrId", _fromGarrId);
		T_SETV("target", _target);
	} ENDMETHOD;

	/* override */ METHOD("apply") {
		params [P_THISOBJECT, P_STRING("_world")];
		ASSERT_OBJECT_CLASS(_world, "WorldModel");

		T_PRVAR(action);
		private _fromGarrId = T_GET_AST_VAR("fromGarrId");
		ASSERT_MSG(_fromGarrId isEqualType 0, "fromGarrId should be a garrison Id");
		private _fromGarr = CALLM(_world, "getGarrison", [_fromGarrId]);
		ASSERT_OBJECT(_fromGarr);

		// If the detachment or target died then we just finish the whole action immediately
		if(CALLM(_fromGarr, "isDead", [])) exitWith { 
			OOP_WARNING_MSG("[w %1 a %2] Garrison %3 is dead so can't merge to target", [_world]+[_action]+[LABEL(_fromGarr)]);
			T_GETV("fromGarrDeadState")
		};

		T_GET_AST_VAR("target") params ["_targetType", "_target"];

		private _targetDead = false;
		
		switch(_targetType) do {
			case TARGET_TYPE_GARRISON: {
				ASSERT_MSG(_target isEqualType 0, "TARGET_TYPE_GARRISON target type expects a garrison ID");
				private _toGarr = CALLM(_world, "getGarrison", [_target]);
				ASSERT_OBJECT(_toGarr);
				_targetDead = if(CALLM(_toGarr, "isDead", [])) then {
					OOP_WARNING_MSG("[w %1 a %2] Garrison %3 can't merge to dead garrison %4", [_world]+[_action]+[LABEL(_fromGarr)]+[LABEL(_toGarr)]);
					true
				} else {
					if(GETV(_world, "type") != WORLD_TYPE_REAL) then {
						CALLM(_fromGarr, "mergeSim", [_toGarr]);
					} else {
						CALLM(_fromGarr, "mergeActual", [_toGarr]);
					};
					false
				};
			};
			case TARGET_TYPE_LOCATION: {
				ASSERT_MSG(_target isEqualType 0, "TARGET_TYPE_LOCATION target type expects a location ID");
				private _loc = CALLM(_world, "getLocation", [_target]);
				ASSERT_OBJECT(_loc);
				private _side = GETV(_fromGarr, "side");
				private _toGarr = CALLM(_loc, "getGarrison", [_side]);
				if(!IS_NULL_OBJECT(_toGarr)) then {
					if(GETV(_world, "type") != WORLD_TYPE_REAL) then {
						CALLM(_fromGarr, "mergeSim", [_toGarr]);
					} else {
						CALLM(_fromGarr, "mergeActual", [_toGarr]);
					};
					OOP_INFO_MSG("[w %1 a %2] Merged %3 to %4 (at %5)", [_world]+[_action]+[LABEL(_fromGarr)]+[LABEL(_toGarr)]+[LABEL(_loc)]);
				} else {
					if(GETV(_world, "type") != WORLD_TYPE_REAL) then {
						CALLM(_fromGarr, "joinLocationSim", [_loc]);
					} else {
						CALLM(_fromGarr, "joinLocationActual", [_loc]);
					};
					OOP_INFO_MSG("[w %1 a %2] Joined %3 to %4", [_world]+[_action]+[LABEL(_fromGarr)]+[LABEL(_loc)]);
				};
			};
			case TARGET_TYPE_POSITION: {
				FAILURE("Target must be a garrison or location");
			};
		};
		if(_targetDead) then {
			T_GETV("targetDeadState")
		} else {
			T_GETV("successState")
		}
	} ENDMETHOD;
ENDCLASS;

#ifdef _SQF_VM

#define CMDR_ACTION_STATE_FAILED_GARRISON_DEAD CMDR_ACTION_STATE_CUSTOM+1
#define CMDR_ACTION_STATE_FAILED_TARGET_DEAD CMDR_ACTION_STATE_CUSTOM+2

["AST_MergeOrJoinTarget.new", {
	private _action = NEW("CmdrAction", []);
	private _thisObject = NEW("AST_MergeOrJoinTarget", 
		[_action]+
		[[CMDR_ACTION_STATE_START]]+
		[CMDR_ACTION_STATE_END]+
		[CMDR_ACTION_STATE_FAILED_GARRISON_DEAD]+
		[CMDR_ACTION_STATE_FAILED_TARGET_DEAD]+
		[MAKE_AST_VAR(0)]+
		[MAKE_AST_VAR([TARGET_TYPE_GARRISON, 0])]
	);
	
	private _class = OBJECT_PARENT_CLASS_STR(_thisObject);
	["Object exists", !(isNil "_class")] call test_Assert;
}] call test_AddTest;

AST_MergeOrJoinTarget_test_fn = {
	params ["_world", "_garrison", "_target"];
	private _action = NEW("CmdrAction", []);
	private _thisObject = NEW("AST_MergeOrJoinTarget", 
		[_action]+
		[[CMDR_ACTION_STATE_START]]+
		[CMDR_ACTION_STATE_END]+
		[CMDR_ACTION_STATE_FAILED_GARRISON_DEAD]+
		[CMDR_ACTION_STATE_FAILED_TARGET_DEAD]+
		[MAKE_AST_VAR(GETV(_garrison, "id"))]+
		[MAKE_AST_VAR(_target)]
	);
	CALLM(_thisObject, "apply", [_world])
};

["AST_MergeOrJoinTarget.apply(sim, garrison=dead)", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_FUTURE]);
	private _garrison = NEW("GarrisonModel", [_world]);
	private _endState = [_world, _garrison, [TARGET_TYPE_POSITION, TARGET_POS]] call AST_MergeOrJoinTarget_test_fn;
	["State after apply is correct", _endState == CMDR_ACTION_STATE_FAILED_GARRISON_DEAD] call test_Assert;
}] call test_AddTest;

["AST_MergeOrJoinTarget.apply(sim, target=garrison)", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_FUTURE]);
	private _garrison = NEW("GarrisonModel", [_world]);
	SETV(_garrison, "efficiency", EFF_MIN_EFF);
	private _targetGarrison = NEW("GarrisonModel", [_world]);
	SETV(_targetGarrison, "efficiency", EFF_MIN_EFF);

	private _endState = [_world, _garrison, [TARGET_TYPE_GARRISON, GETV(_targetGarrison, "id")]] call AST_MergeOrJoinTarget_test_fn;
	["State after apply is correct", _endState == CMDR_ACTION_STATE_END] call test_Assert;
	["Source garrison correct after", CALLM(_garrison, "isDead", [])] call test_Assert;
	["Target garrison correct after", GETV(_targetGarrison, "efficiency") isEqualTo EFF_ADD(EFF_MIN_EFF, EFF_MIN_EFF)] call test_Assert;
}] call test_AddTest;

["AST_MergeOrJoinTarget.apply(sim, target=garrison+dead)", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_FUTURE]);
	private _garrison = NEW("GarrisonModel", [_world]);
	SETV(_garrison, "efficiency", EFF_MIN_EFF);
	private _targetGarrison = NEW("GarrisonModel", [_world]);

	private _endState = [_world, _garrison, [TARGET_TYPE_GARRISON, GETV(_targetGarrison, "id")]] call AST_MergeOrJoinTarget_test_fn;
	["State after apply is correct", _endState == CMDR_ACTION_STATE_FAILED_TARGET_DEAD] call test_Assert;
}] call test_AddTest;

["AST_MergeOrJoinTarget.apply(sim, target=location+empty)", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_FUTURE]);
	private _garrison = NEW("GarrisonModel", [_world]);
	SETV(_garrison, "efficiency", EFF_MIN_EFF);
	private _targetLocation = NEW("LocationModel", [_world]);

	private _endState = [_world, _garrison, [TARGET_TYPE_LOCATION, GETV(_targetLocation, "id")]] call AST_MergeOrJoinTarget_test_fn;
	["State after apply is correct", _endState == CMDR_ACTION_STATE_END] call test_Assert;
	["Garrison assigned to location after", CALLM(_garrison, "getLocation", []) isEqualTo _targetLocation] call test_Assert;

}] call test_AddTest;

#endif

// CLASS("MergeGarrison", "ActionStateTransition")
// 	VARIABLE("action");

// 	METHOD("new") {
// 		params [P_THISOBJECT, P_STRING("_action")];

// 		T_SETV("action", _action);
// 		T_SETV("fromStates", [CMDR_ACTION_STATE_ARRIVED]);
// 		T_SETV("toState", CMDR_ACTION_STATE_END);
// 	} ENDMETHOD;

// 	/* override */ METHOD("apply") { 
// 		params [P_THISOBJECT, P_STRING("_world")];
// 		ASSERT_OBJECT_CLASS(_world, "WorldModel");

// 		T_PRVAR(action);
// 		private _detachedGarrId = GETV(_action, "detachedGarrId");
// 		private _detachedGarr = CALLM(_world, "getGarrison", [_detachedGarrId]);
// 		ASSERT_OBJECT(_detachedGarr);

// 		private _tgtGarrId = GETV(_action, "tgtGarrId");
// 		private _tgtGarr = CALLM(_world, "getGarrison", [_tgtGarrId]);
// 		ASSERT_OBJECT(_tgtGarr);

// 		// If the detachment or target died then we just finish the whole action immediately
// 		if(CALLM(_detachedGarr, "isDead", [])) exitWith { 
// 			OOP_WARNING_MSG("[w %1 a %2] Detached garrison %3 is dead so can't merge to %4 (aborting the action)", [_world ARG _action ARG LABEL(_detachedGarr) ARG LABEL(_tgtGarr)]);
// 			// HACK: Return true to indicate we "succeeded" until AST can support failure conditions.
// 			true
// 		};

// 		// If the detachment or target died then we just finish the whole action immediately
// 		if(CALLM(_tgtGarr, "isDead", [])) exitWith { 
// 			OOP_WARNING_MSG("[w %1 a %2] Target garrison %4 is dead so can't merge %3 to it (aborting the action)", [_world ARG _action ARG LABEL(_detachedGarr) ARG LABEL(_tgtGarr)]);
// 			// HACK: Return true to indicate we "succeeded" until AST can support failure conditions.
// 			true 
// 		};

// 		// ASSERT_MSG(!CALLM(_detachedGarr, "isDead", []), "Garrison to merge from is dead");
// 		// ASSERT_MSG(!CALLM(_tgtGarr, "isDead", []), "Garrison to merge to is dead");

// 		// Merge can happen instantly so apply it to now and future sim worlds.
// 		if(GETV(_world, "type") != WORLD_TYPE_REAL) then {
// 			CALLM(_detachedGarr, "mergeSim", [_tgtGarr]);
// 		} else {
// 			CALLM(_detachedGarr, "mergeActual", [_tgtGarr]);
// 			//private _rc = GETV(_action, "refCount");
// 			//OOP_INFO_MSG("[w %1 a %2] After merged action has ref count %3", [_world ARG _action ARG _rc]);
// 		};
// 		OOP_INFO_MSG("[w %1 a %2] Merged %3 to %4", [_world ARG _action ARG LABEL(_detachedGarr) ARG LABEL(_tgtGarr)]);
// 		true
// 	} ENDMETHOD;
// ENDCLASS;
