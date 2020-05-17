#include "common.hpp"

/*
Class: AI.CmdrAI.CmdrAction.ASTs.AST_AssignCargo
Assign cargo to T_VEH_Cargo units in the garrison.

Parent: <ActionStateTransition>
*/
#define OOP_CLASS_NAME AST_AssignCargo
CLASS("AST_AssignCargo", "ActionStateTransition")
	VARIABLE_ATTR("doneState", [ATTR_PRIVATE ARG ATTR_SAVE]);

	// Inputs
	VARIABLE_ATTR("cargo", [ATTR_PRIVATE ARG ATTR_SAVE]);
	VARIABLE_ATTR("garrIdVar", [ATTR_PRIVATE ARG ATTR_SAVE]);

	/*
	Method: new
	Create an AST to populate T_VEH_Cargo category vehicles with specified cargo
	
	Parameters:
		_action - <CmdrAction>, action this AST is part of, for debugging purposes
		_fromStates - Array of <CMDR_ACTION_STATE>, states this AST is valid from
		_doneState - <CMDR_ACTION_STATE>, state to return once done
		_garrIdVar - Garrison to assign supplies to
		_cargo - IN <Array of [item, count]>, cargo items and counts to add
	*/
	METHOD(new)
		params [P_THISOBJECT, 
			P_OOP_OBJECT("_action"),
			P_ARRAY("_fromStates"),
			P_AST_STATE("_doneState"),
			P_AST_VAR("_garrIdVar"),
			P_ARRAY("_cargo")
		];
		
		T_SETV("fromStates", _fromStates);
		T_SETV("doneState", _doneState);
		T_SETV("garrIdVar", _garrIdVar);
		T_SETV("cargo", _cargo);
	ENDMETHOD;

	/* override */ METHOD(apply)
		params [P_THISOBJECT, P_STRING("_world")];
		ASSERT_OBJECT_CLASS(_world, "WorldModel");

		private _garr = CALLM(_world, "getGarrison", [T_GET_AST_VAR("garrIdVar")]);
		ASSERT_OBJECT(_garr);

		if(CALLM0(_garr, "isDead")) exitWith {
			T_GETV("doneState")
		};

#ifndef _SQF_VM
		if(GETV(_world, "type") == WORLD_TYPE_REAL) then {
			private _cargo = T_GETV("cargo");
			CALLM1(_garr, "assignCargoActual", _cargo)
		};
#endif
		T_GETV("doneState")
	ENDMETHOD;
ENDCLASS;