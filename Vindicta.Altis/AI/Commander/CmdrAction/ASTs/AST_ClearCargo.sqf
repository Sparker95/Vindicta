#include "common.hpp"

/*
Class: AI.CmdrAI.CmdrAction.ASTs.AST_ClearCargo
Clear cargo to T_VEH_Cargo units in the garrison.

Parent: <ActionStateTransition>
*/
#define OOP_CLASS_NAME AST_ClearCargo
CLASS("AST_ClearCargo", "ActionStateTransition")
	VARIABLE_ATTR("doneState", [ATTR_PRIVATE ARG ATTR_SAVE]);

	// Inputs
	VARIABLE_ATTR("garrIdVar", [ATTR_PRIVATE ARG ATTR_SAVE]);

	/*
	Method: new
	Create an AST to clear T_VEH_Cargo category vehicles of all cargo

	Parameters:
		_action - <CmdrAction>, action this AST is part of, for debugging purposes
		_fromStates - Array of <CMDR_ACTION_STATE>, states this AST is valid from
		_doneState - <CMDR_ACTION_STATE>, state to return once done
		_garrIdVar - Garrison to clear the supplies of
	*/
	METHOD(new)
		params [P_THISOBJECT, 
			P_OOP_OBJECT("_action"),
			P_ARRAY("_fromStates"),
			P_AST_STATE("_doneState"),
			P_AST_VAR("_garrIdVar")
		];
		
		T_SETV("fromStates", _fromStates);
		T_SETV("doneState", _doneState);
		T_SETV("garrIdVar", _garrIdVar);
	ENDMETHOD;

	public override METHOD(apply)
		params [P_THISOBJECT, P_STRING("_world")];
		ASSERT_OBJECT_CLASS(_world, "WorldModel");

		private _garr = CALLM(_world, "getGarrison", [T_GET_AST_VAR("garrIdVar")]);
		ASSERT_OBJECT(_garr);

		if(CALLM0(_garr, "isDead")) exitWith {
			T_GETV("doneState")
		};

#ifndef _SQF_VM
		if(GETV(_world, "type") == WORLD_TYPE_REAL) then {
			CALLM0(_garr, "clearCargoActual")
		};
#endif
		T_GETV("doneState")
	ENDMETHOD;
ENDCLASS;