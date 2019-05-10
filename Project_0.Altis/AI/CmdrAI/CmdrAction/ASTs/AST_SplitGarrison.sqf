#include "..\..\common.hpp"


CLASS("AST_SplitGarrison", "ActionStateTransition")
	VARIABLE_ATTR("action", [ATTR_PRIVATE]);
	VARIABLE_ATTR("successState", [ATTR_PRIVATE]);
	VARIABLE_ATTR("failState", [ATTR_PRIVATE]);

	// Inputs
	VARIABLE_ATTR("srcGarrId", [ATTR_PRIVATE]);
	VARIABLE_ATTR("detachmentEff", [ATTR_PRIVATE]);
	VARIABLE_ATTR("splitFlags", [ATTR_PRIVATE]);

	// Outputs
	VARIABLE_ATTR("detachedGarrId", [ATTR_PRIVATE]);

	METHOD("new") {
		params [P_THISOBJECT, 
			P_OOP_OBJECT("_action"),
			P_ARRAY("_fromStates"),				// States it is valid from
			P_AST_STATE("_successState"), 		// Split succeeded
			P_AST_STATE("_failState"), 			// Split failed (TODO: differentiate failure types)
			// inputs
			P_AST_VAR("_srcGarrId"), 			// Garrison we want to split
			P_AST_VAR("_detachmentEff"), 		// Efficiency we want detachment to have
			P_AST_VAR("_splitFlags"),			// Split flags (required transport etc.)
			// outputs
			P_AST_VAR("_detachedGarrId")		// Output Id of new detachment garrison
		];

		ASSERT_OBJECT_CLASS(_action, "CmdrAction");
		T_SETV("action", _action);
		T_SETV("fromStates", _fromStates);
		T_SETV("successState", _successState);
		T_SETV("failState", _failState);
		T_SETV("srcGarrId", _srcGarrId);
		T_SETV("splitFlags", _splitFlags);
		T_SETV("detachmentEff", _detachmentEff);
		T_SETV("detachedGarrId", _detachedGarrId);
	} ENDMETHOD;

	/* override */ METHOD("apply") {
		params [P_THISOBJECT, P_STRING("_world")];
		ASSERT_OBJECT_CLASS(_world, "WorldModel");

		T_PRVAR(action);
		private _srcGarrId = T_GET_AST_VAR("srcGarrId");
		private _srcGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
		ASSERT_OBJECT(_srcGarr);
		//private _detachmentEff = CALLM(_action, "getDetachmentEff", [_world]);

		// Get the previously calculated efficiency
		private _detachmentEff = T_GET_AST_VAR("detachmentEff");

		ASSERT_MSG(EFF_GTE(_detachmentEff, EFF_MIN_EFF), "Detachment efficiency is below min allowed");

		// Apply split to all sim worlds as it always happens immediately at the start of action
		// TODO: better evalulation of efficiency requirements (and application to sim especially)
		// Currently this will only apply changes to attack part of sim efficiency vector.
		//private _attackEfficiency = EFF_MASK_ATT(_detachmentEff);
		// Split can happen instantly so apply it to now and future sim worlds.
		private _splitFlags = T_GET_AST_VAR("splitFlags");
		private _detachedGarr = if(GETV(_world, "type") != WORLD_TYPE_REAL) then {
									CALLM(_srcGarr, "splitSim", [_detachmentEff ARG _splitFlags])
								} else {
									CALLM(_srcGarr, "splitActual", [EFF_MASK_ATT(_detachmentEff) ARG _splitFlags])
								};

		if(IS_NULL_OBJECT(_detachedGarr)) exitWith {
			OOP_WARNING_MSG("[w %1 a %2] Failed to detach from %3", [_world ARG _action ARG LABEL(_srcGarr)]);
			T_GETV("failState")
		};

		private _finalDetachEff = GETV(_detachedGarr, "efficiency");
		// We want this to be impossible. Sadly it seems it isn't :/
		ASSERT_MSG(EFF_GTE(_finalDetachEff, EFF_ZERO), "Final detachment efficiency is zero!");
		//ASSERT_MSG(EFF_GTE(_finalDetachEff, _detachmentEff), "Final detachment efficiency is below requested");

		// This shouldn't be possible and if it does happen then we would need to do something with the resultant understaffed garrison.
		// if(!EFF_GTE(_finalDetachEff, _detachmentEff)) exitWith {
		// 	OOP_DEBUG_MSG("[w %1 a %2] Failed to detach from %3", [_world ARG _action ARG _srcGarr]);
		// 	false
		// };

		OOP_INFO_MSG("[w %1 a %2] Detached %3 from %4", [_world ARG _action ARG LABEL(_detachedGarr) ARG LABEL(_srcGarr)]);

		T_SET_AST_VAR("detachedGarrId", GETV(_detachedGarr, "id"));
		T_GETV("successState")
	} ENDMETHOD;
ENDCLASS;


#ifdef _SQF_VM

#define CMDR_ACTION_STATE_FAILED CMDR_ACTION_STATE_CUSTOM+1

["AST_SplitGarrison.new", {
	private _action = NEW("CmdrAction", []);
	private _thisObject = NEW("AST_SplitGarrison", 
		[_action]+
		[[CMDR_ACTION_STATE_START]]+
		[CMDR_ACTION_STATE_END]+
		[CMDR_ACTION_STATE_FAILED]+
		[MAKE_AST_VAR(0)]+
		[MAKE_AST_VAR(EFF_MIN)]+
		[MAKE_AST_VAR([])]+
		[MAKE_AST_VAR(0)]
	);
	
	private _class = OBJECT_PARENT_CLASS_STR(_thisObject);
	["Object exists", !(isNil "_class")] call test_Assert;
}] call test_AddTest;

["AST_SplitGarrison.apply(sim)", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _garrison = NEW("GarrisonModel", [_world]);
	private _eff1 = [12, 4, 4, 2, 20, 0, 0, 0];
	private _eff2 = EFF_MIN_EFF;
	private _effr = EFF_DIFF(_eff1, _eff2);
	SETV(_garrison, "efficiency", _eff1);

	private _splitGarrIdVar = MAKE_AST_VAR(-1);
	private _action = NEW("CmdrAction", []);
	private _thisObject = NEW("AST_SplitGarrison", 
		[_action]+
		[[CMDR_ACTION_STATE_START]]+
		[CMDR_ACTION_STATE_END]+
		[CMDR_ACTION_STATE_FAILED]+
		[MAKE_AST_VAR(GETV(_garrison, "id"))]+
		[MAKE_AST_VAR(_eff2)]+
		[MAKE_AST_VAR([])]+
		[_splitGarrIdVar]
	);

	private _endState = CALLM(_thisObject, "apply", [_world]);
	["State after apply is correct", _endState == CMDR_ACTION_STATE_END] call test_Assert;
	["Split garrison var is valid", GET_AST_VAR(_splitGarrIdVar) != -1] call test_Assert;
	private _splitGarr = CALLM(_world, "getGarrison", [GET_AST_VAR(_splitGarrIdVar)]);
	["Split garrison is valid", !IS_NULL_OBJECT(_splitGarr)] call test_Assert;
	["Orig eff", GETV(_garrison, "efficiency") isEqualTo _effr] call test_Assert;
	["Split eff", GETV(_splitGarr, "efficiency") isEqualTo _eff2] call test_Assert;
}] call test_AddTest;


["AST_SplitGarrison.apply(actual)", {
	private _actual = NEW("Garrison", [WEST]);
	private _group = NEW("Group", Test_group_args);
	private _eff1 = +T_EFF_null;
	for "_i" from 0 to 19 do
	{
		private _unit = NEW("Unit", Test_unit_args + [_group]);
		//CALLM(_actual, "addUnit", [_unit]);
		private _unitEff = CALLM(_unit, "getEfficiency", []);
		_eff1 = EFF_ADD(_eff1, _unitEff);
	};

	CALLM(_actual, "addGroup", [_group]);
	
	private _world = NEW("WorldModel", [WORLD_TYPE_REAL]);
	private _garrison = NEW("GarrisonModel", [_world] + [_actual]);
	["Initial eff", GETV(_garrison, "efficiency") isEqualTo _eff1] call test_Assert;
	private _eff2 = EFF_MIN_EFF;
	private _effr = EFF_DIFF(_eff1, _eff2);
	SETV(_garrison, "efficiency", _eff1);

	private _splitGarrIdVar = MAKE_AST_VAR(-1);
	private _action = NEW("CmdrAction", []);
	private _thisObject = NEW("AST_SplitGarrison", 
		[_action]+
		[[CMDR_ACTION_STATE_START]]+
		[CMDR_ACTION_STATE_END]+
		[CMDR_ACTION_STATE_FAILED]+
		[MAKE_AST_VAR(GETV(_garrison, "id"))]+
		[MAKE_AST_VAR(_eff2)]+
		[MAKE_AST_VAR([])]+
		[_splitGarrIdVar]
	);
	
	private _endState = CALLM(_thisObject, "apply", [_world]);
	

	["State after apply is correct", _endState == CMDR_ACTION_STATE_END] call test_Assert;
	["Split garrison var is valid", GET_AST_VAR(_splitGarrIdVar) != -1] call test_Assert;
	private _splitGarr = CALLM(_world, "getGarrison", [GET_AST_VAR(_splitGarrIdVar)]);
	["Split garrison is valid", !IS_NULL_OBJECT(_splitGarr)] call test_Assert;

	// Sync the Models
	CALLM(_garrison, "sync", []);
	CALLM(_splitGarr, "sync", []);

	["Orig eff", GETV(_garrison, "efficiency") isEqualTo _effr] call test_Assert;
	["Split eff", GETV(_splitGarr, "efficiency") isEqualTo _eff2] call test_Assert;
}] call test_AddTest;

#endif
// ORIGINAL


// CLASS("ReinforceSplitGarrison", "ActionStateTransition")
// 	VARIABLE("action");
// 	VARIABLE("successState");
// 	VARIABLE("failState");

// 	// Inputs
// 	VARIABLE("srcGarrId");
// 	VARIABLE("detachmentEff");

// 	// DOING: bindings for inputs and outputs, not straight up values. We need 
// 	// later actions to be able to access these values.
// 	// Options:
// 	// 1- Store directly to action. If the variable doesn't exist then it won't work, and all the names have to match.
// 	// 2- Value container. Simple, just make it an array and pass by ref!
// 	// 3- Make them read/write functions instead of values, like std::bind kind of thing.
// 	//
// 	// 2 seems simplest. Wrap it into macros for GET+SET value?


// 	// Outputs
// 	VARIABLE("detachedGarrId");

// 	METHOD("new") {
// 		params [P_THISOBJECT, P_STRING("_action"), P_NUMBER("_successState"), P_NUMBER("_failState")];
// 		T_SETV("action", _action);
// 		T_SETV("fromStates", [CMDR_ACTION_STATE_START]);
// 		// T_SETV("toState", CMDR_ACTION_STATE_SPLIT);
// 	} ENDMETHOD;

// 	/* override */ METHOD("apply") {
// 		params [P_THISOBJECT, P_STRING("_world")];
// 		ASSERT_OBJECT_CLASS(_world, "WorldModel");

// 		T_PRVAR(action);
// 		private _srcGarrId = GETV(_action, "srcGarrId");
// 		private _srcGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
// 		ASSERT_OBJECT(_srcGarr);
// 		//private _detachEff = CALLM(_action, "getDetachmentEff", [_world]);

// 		// Get the previously calculated efficiency
// 		private _detachEff = GETV(_action, "detachmentEff");

// 		ASSERT_MSG(EFF_GTE(_detachEff, EFF_MIN_EFF), "Detachment efficiency is below min allowed");

// 		// Apply split to all sim worlds as it always happens immediately at the start of action
// 		// TODO: we need to check if this actually works.
// 		// TODO: some kind of failure ability for actions in general.

// 		// Split can happen instantly so apply it to now and future sim worlds.
// 		private _detachedGarr = if(GETV(_world, "type") != WORLD_TYPE_REAL) then {
// 									CALLM(_srcGarr, "splitSim", [_detachEff ARG [ASSIGN_TRANSPORT ARG FAIL_UNDER_EFF]])
// 								} else {
// 									CALLM(_srcGarr, "splitActual", [_detachEff ARG [ASSIGN_TRANSPORT ARG FAIL_UNDER_EFF]])
// 								};

// 		if(IS_NULL_OBJECT(_detachedGarr)) exitWith {
// 			OOP_WARNING_MSG("[w %1 a %2] Failed to detach from %3", [_world ARG _action ARG LABEL(_srcGarr)]);
// 			false
// 		};

// 		private _finalDetachEff = GETV(_detachedGarr, "efficiency");
// 		// We want this to be impossible. Sadly it seems it isn't :/
// 		ASSERT_MSG(EFF_GTE(_finalDetachEff, EFF_ZERO), "Final detachment efficiency is zero!");
// 		//ASSERT_MSG(EFF_GTE(_finalDetachEff, _detachEff), "Final detachment efficiency is below requested");

// 		// This shouldn't be possible and if it does happen then we would need to do something with the resultant understaffed garrison.
// 		// if(!EFF_GTE(_finalDetachEff, _detachEff)) exitWith {
// 		// 	OOP_DEBUG_MSG("[w %1 a %2] Failed to detach from %3", [_world ARG _action ARG _srcGarr]);
// 		// 	false
// 		// };

// 		OOP_INFO_MSG("[w %1 a %2] Detached %3 from %4", [_world ARG _action ARG LABEL(_detachedGarr) ARG LABEL(_srcGarr)]);

// 		// DOING: HOW TO FIX THIS? ASTS need to save state, sometimes they modify the Action. How to 
// 		// apply them to simworlds in this case without breaking action state for real world?
// 		// simCopy actions as well? Probably make sense.
// 		CALLM(_detachedGarr, "setAction", [_action]);
// 		SETV(_action, "detachedGarrId", GETV(_detachedGarr, "id"));
// 		true
// 	} ENDMETHOD;
// ENDCLASS;