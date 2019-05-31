#include "..\..\common.hpp"

CLASS("AST_WaitGarrison", "ActionStateTransition")
	VARIABLE_ATTR("action", [ATTR_PRIVATE]);
	VARIABLE_ATTR("successState", [ATTR_PRIVATE]);
	VARIABLE_ATTR("failGarrisonDead", [ATTR_PRIVATE]);
	// Inputs
	VARIABLE_ATTR("waitUntilDateVar", [ATTR_PRIVATE]);
	VARIABLE_ATTR("garrIdVar", [ATTR_PRIVATE]);

	METHOD("new") {
		params [P_THISOBJECT, 
			P_OOP_OBJECT("_action"),			// Owner action for debugging purposes
			P_ARRAY("_fromStates"),				// States it is valid from
			P_AST_STATE("_successState"),		// if we reached the target
			P_AST_STATE("_failGarrisonDead"), 	// if the garrison we are moving died
			// inputs
			P_AST_VAR("_waitUntilDateVar"), 		// target [type, value] (garrison, location or position)
			P_AST_VAR("_garrIdVar") 				// garrison to move
		];
		ASSERT_OBJECT_CLASS(_action, "CmdrAction");

		T_SETV("action", _action);
		T_SETV("fromStates", _fromStates);
		T_SETV("successState", _successState);
		T_SETV("failGarrisonDead", _failGarrisonDead);
		T_SETV("garrIdVar", _garrIdVar);
		T_SETV("waitUntilDateVar", _waitUntilDateVar);
	} ENDMETHOD;

	/* override */ METHOD("apply") {
		params [P_THISOBJECT, P_STRING("_world")];
		ASSERT_OBJECT_CLASS(_world, "WorldModel");

		private _garr = CALLM(_world, "getGarrison", [T_GET_AST_VAR("garrIdVar")]);
		ASSERT_OBJECT(_garr);

		if(CALLM(_garr, "isDead", [])) exitWith {
			T_GETV("failGarrisonDead")
		};

		private _waitUntil = T_GET_AST_VAR("waitUntilDateVar");

#ifndef _SQF_VM
		if((GETV(_world, "type") == WORLD_TYPE_SIM_FUTURE) or (_waitUntil isEqualTo []) or {(DATE_NOW call misc_fnc_dateToNumber) > (_waitUntil call misc_fnc_dateToNumber)}) then {
			T_GETV("successState")
		} else {
			CMDR_ACTION_STATE_NONE
		}
#else
		T_GETV("successState")
#endif
	} ENDMETHOD;
ENDCLASS;