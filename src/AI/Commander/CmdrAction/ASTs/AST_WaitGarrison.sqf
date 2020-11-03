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

	VARIABLE_ATTR("targetVar", [ATTR_PRIVATE ARG ATTR_SAVE_VER(28)]);
	VARIABLE_ATTR("failTargetDead", [ATTR_PRIVATE ARG ATTR_SAVE_VER(28)]);

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
		_targetVar - IN <AST_VAR>(<CmdrAITarget>), target which will be evaluated to not be dead while waiting, can be -1 if it's irrelevant
		_targetDeadState - <CMDR_ACTION_STATE>, state to return when the target is dead
	*/
	METHOD(new)
		params [P_THISOBJECT, 
			P_OOP_OBJECT("_action"),
			P_ARRAY("_fromStates"),
			P_AST_STATE("_successState"),
			P_AST_STATE("_failGarrisonDead"),
			P_AST_VAR("_waitUntilDateVar"),
			P_AST_VAR("_garrIdVar"),
			P_AST_VAR("_targetVar"),
			P_AST_STATE("_targetDeadState")
		];
		
		T_SETV("fromStates", _fromStates);
		T_SETV("successState", _successState);
		T_SETV("failGarrisonDead", _failGarrisonDead);
		T_SETV("garrIdVar", _garrIdVar);
		T_SETV("waitUntilDateVar", _waitUntilDateVar);
		T_SETV("targetVar", _targetVar);
		T_SETV("failTargetDead", _targetDeadState);
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
		// Cancel the wait if target is destroyed
		private _targetDead = false;
		if (T_GETV("targetVar") != -1) then {
			T_GET_AST_VAR("targetVar") params ["_targetType", "_target"];
			if (_targetType == TARGET_TYPE_GARRISON) then {
				ASSERT_MSG(_target isEqualType 0, "TARGET_TYPE_GARRISON target type expects a garrison ID");
				private _toGarr = CALLM(_world, "getGarrison", [_target]);
				ASSERT_OBJECT(_toGarr);
				_targetDead = CALLM0(_toGarr, "isDead");
			};
		};
		if (_targetDead) exitWith {
			T_GETV("failTargetDead");
		};

		// Complete when time is out
		if((GETV(_world, "type") == WORLD_TYPE_SIM_FUTURE) or (_waitUntil isEqualTo []) or {(dateToNumber DATE_NOW) > (dateToNumber _waitUntil)}) exitWith {
			T_GETV("successState")
		};
		
		CMDR_ACTION_STATE_NONE;
#else
		T_GETV("successState")
#endif
	ENDMETHOD;

	public override METHOD(postDeserialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage"), P_NUMBER("_version")];

		if (_version < 28) then {
			// Initialize these to invalid values
			T_SETV("failTargetDead", CMDR_ACTION_STATE_END);
			T_SETV("targetVar", -1);
		};

		true; // Success
	ENDMETHOD;

ENDCLASS;