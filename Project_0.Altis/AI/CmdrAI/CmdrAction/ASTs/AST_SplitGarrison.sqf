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
			P_AST_STATE("_successState"), P_AST_STATE("_failState"), 
			// inputs
			P_AST_VAR("_srcGarrId"), P_AST_VAR("_detachmentEff"), P_AST_VAR("_splitFlags"),
			// outputs
			P_AST_VAR("_detachedGarrId")];
		ASSERT_OBJECT_CLASS(_action, "CmdrAction");
		T_SETV("action", _action);
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
		// TODO: we need to check if this actually works.
		// TODO: some kind of failure ability for actions in general.

		// Split can happen instantly so apply it to now and future sim worlds.
		private _splitFlags = T_GET_AST_VAR("splitFlags");
		private _detachedGarr = if(GETV(_world, "type") != WORLD_TYPE_REAL) then {
									CALLM(_srcGarr, "splitSim", [_detachmentEff ARG _splitFlags])
								} else {
									CALLM(_srcGarr, "splitActual", [_detachmentEff ARG _splitFlags])
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

		// DOING: HOW TO FIX THIS? ASTS need to save state, sometimes they modify the Action. How to 
		// apply them to simworlds in this case without breaking action state for real world?
		// simCopy actions as well? Probably make sense.

		// CALLM(_detachedGarr, "setAction", [_action]);
		T_SET_AST_VAR("detachedGarrId", GETV(_detachedGarr, "id"));
		T_GETV("successState")
	} ENDMETHOD;
ENDCLASS;