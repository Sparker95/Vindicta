#include "common.hpp"

/*
Class: AI.CmdrAI.CmdrAction.ASTs.AST_WaitGarrison
Have a garrison wait for a period of time.

Parent: <ActionStateTransition>
*/
#define OOP_CLASS_NAME AST_WaitGarrison
CLASS("AST_WaitGarrison", "ActionStateTransition")
	VARIABLE_ATTR("successState", [ATTR_PRIVATE ARG ATTR_SAVE]);
	VARIABLE_ATTR("failGarrisonDead", [ATTR_PRIVATE ARG ATTR_SAVE]);

	// Inputs
	VARIABLE_ATTR("waitUntilDateVar", [ATTR_PRIVATE ARG ATTR_SAVE]);
	VARIABLE_ATTR("garrIdVar", [ATTR_PRIVATE ARG ATTR_SAVE]);

	/*
	Method: new
	Create an AST for a garrison to wait for a period of time.
	
	Parameters:
		_action - <CmdrAction>, action this AST is part of, for debugging purposes
		_fromStates - Array of <CMDR_ACTION_STATE>, states this AST is valid from
		_successState - <CMDR_ACTION_STATE>, state to return after success, when wait is over and garrison is still alive
		_failGarrisonDead - <CMDR_ACTION_STATE>, state to return when garrison performing the action is dead
		_waitUntilDateVar - IN <AST_VAR>(Date), date to wait until
		_garrIdVar - IN <AST_VAR>(Number), <Model.GarrisonModel> Id of the garrison waiting
	*/
	METHOD(new)
		params [P_THISOBJECT, 
			P_OOP_OBJECT("_action"),
			P_ARRAY("_fromStates"),
			P_AST_STATE("_successState"),
			P_AST_STATE("_failGarrisonDead"),
			P_AST_VAR("_waitUntilDateVar"),
			P_AST_VAR("_garrIdVar")
		];
		
		T_SETV("fromStates", _fromStates);
		T_SETV("successState", _successState);
		T_SETV("failGarrisonDead", _failGarrisonDead);
		T_SETV("garrIdVar", _garrIdVar);
		T_SETV("waitUntilDateVar", _waitUntilDateVar);
	ENDMETHOD;

	public override METHOD(apply)
		params [P_THISOBJECT, P_STRING("_world")];
		ASSERT_OBJECT_CLASS(_world, "WorldModel");

		private _garr = CALLM(_world, "getGarrison", [T_GET_AST_VAR("garrIdVar")]);
		ASSERT_OBJECT(_garr);

		if(CALLM0(_garr, "isDead")) exitWith {
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
	ENDMETHOD;
ENDCLASS;