#include "..\..\common.hpp"


CLASS("AST_AssignActionToGarrison", "ActionStateTransition")
	VARIABLE_ATTR("action", [ATTR_PRIVATE]);
	VARIABLE_ATTR("successState", [ATTR_PRIVATE]);

	// Inputs
	VARIABLE_ATTR("garrId", [ATTR_PRIVATE]);

	METHOD("new") {
		params [P_THISOBJECT, 
			P_OOP_OBJECT("_action"),			// Action to assign to the garrison
			P_ARRAY("_fromStates"),				// States it is valid from
			P_AST_STATE("_successState"),		// State to transition do after completion
			// inputs
			P_AST_VAR("_garrId")];				// Id of the garrison to assign the action to
		ASSERT_OBJECT_CLASS(_action, "CmdrAction");
		T_SETV("action", _action);
		T_SETV("fromStates", _fromStates);
		T_SETV("successState", _successState);
		T_SETV("garrId", _srcGarrId);
	} ENDMETHOD;

	/* override */ METHOD("apply") {
		params [P_THISOBJECT, P_STRING("_world")];
		ASSERT_OBJECT_CLASS(_world, "WorldModel");
		private _garr = CALLM(_world, "getGarrison", [T_GET_AST_VAR("garrId")]);
		ASSERT_OBJECT(_garr);
		CALLM(_garr, "setAction", [T_GETV("_action")]);
		T_GETV("successState")
	} ENDMETHOD;
ENDCLASS;