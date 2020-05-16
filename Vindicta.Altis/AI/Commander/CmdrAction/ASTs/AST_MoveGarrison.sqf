#include "common.hpp"

/*
Class: AI.CmdrAI.CmdrAction.ASTs.AST_MoveGarrison
Order a garrison to move to a target within a certain radius.

Radius is recalculated in case location is specified as destination

Parent: <ActionStateTransition>
*/

#define OOP_CLASS_NAME AST_MoveGarrison
CLASS("AST_MoveGarrison", "ActionStateTransition")
	VARIABLE_ATTR("successState", [ATTR_PRIVATE ARG ATTR_SAVE]);
	VARIABLE_ATTR("failGarrisonDead", [ATTR_PRIVATE ARG ATTR_SAVE]);
	VARIABLE_ATTR("failTargetDead", [ATTR_PRIVATE ARG ATTR_SAVE]);
	VARIABLE_ATTR("moving", [ATTR_PRIVATE ARG ATTR_SAVE]);
	// Inputs
	VARIABLE_ATTR("garrIdVar", [ATTR_PRIVATE ARG ATTR_SAVE]);
	VARIABLE_ATTR("targetVar", [ATTR_PRIVATE ARG ATTR_SAVE]);
	VARIABLE_ATTR("radiusVar", [ATTR_PRIVATE ARG ATTR_SAVE]);

	/*
	Method: new
	Create an AST to give a move to target order to a garrison.

	Parameters:
		_action - <CmdrAction>, action this AST is part of, for debugging purposes
		_fromStates - Array of <CMDR_ACTION_STATE>, states this AST is valid from
		_successState - <CMDR_ACTION_STATE>, state to return after success
		_failGarrisonDead - <CMDR_ACTION_STATE>, state to return if the garrison performing the action is dead
		_failTargetDead - <CMDR_ACTION_STATE>, state to return if the target is dead
		_garrIdVar - IN <AST_VAR>(Number), <Model.GarrisonModel> Id of the garrison performing the move
		_targetVar - IN <AST_VAR>(<CmdrAITarget>), target to move to
		_radiusVar - IN <AST_VAR>(Number), radius around target within which to consider the move complete
	*/
	METHOD(new)
		params [P_THISOBJECT, 
			P_OOP_OBJECT("_action"),
			P_ARRAY("_fromStates"),
			P_AST_STATE("_successState"),
			P_AST_STATE("_failGarrisonDead"),
			P_AST_STATE("_failTargetDead"),
			P_AST_VAR("_garrIdVar"),
			P_AST_VAR("_targetVar"),
			P_AST_VAR("_radiusVar")
		];

		T_SETV("fromStates", _fromStates);
		T_SETV("successState", _successState);
		T_SETV("failGarrisonDead", _failGarrisonDead);
		T_SETV("failTargetDead", _failTargetDead);
		T_SETV("moving", false);
		T_SETV("garrIdVar", _garrIdVar);
		T_SETV("targetVar", _targetVar);
		T_SETV("radiusVar", _radiusVar);
	ENDMETHOD;

	public override METHOD(apply)
		params [P_THISOBJECT, P_STRING("_world")];
		ASSERT_OBJECT_CLASS(_world, "WorldModel");

		private _moving = T_GETV("moving");

		private _garr = CALLM(_world, "getGarrison", [T_GET_AST_VAR("garrIdVar")]);
		ASSERT_OBJECT(_garr);

		// If the garrison is dead then return the appropriate state
		if(CALLM0(_garr, "isDead")) exitWith {
			if(_moving and GETV(_world, "type") == WORLD_TYPE_REAL) then {
				T_SETV("moving", false);
			};
			T_GETV("failGarrisonDead")
		};

		// If we can't get the target position, then return the appropriate state (cancel the move order
		// as well if it is active)
		private _targetPos = [_world, T_GET_AST_VAR("targetVar")] call Target_fnc_GetPos;
		if(!(_targetPos isEqualType [])) exitWith {
			if(_moving and GETV(_world, "type") == WORLD_TYPE_REAL) then {
				CALLM0(_garr, "cancelMoveActual");
				T_SETV("moving", false);
			};
			T_GETV("failTargetDead");
		};

		private _arrived = false;

		// What we do depends on if we are applying to a sim world model or the real world.
		switch(GETV(_world, "type")) do {
			// Move can't happen instantly so we don't change the NOW world sim model.
			case WORLD_TYPE_SIM_NOW: {};
			// Move completes at some point in the future so we apply it immediately to the FUTURE world model.
			case WORLD_TYPE_SIM_FUTURE: {
				CALLM(_garr, "moveSim", [_targetPos]);
				OOP_INFO_MSG("[w %1] Move %2 to %3: complete", [_world ARG LABEL(_garr) ARG _targetPos]);
				_arrived = true;
			};
			case WORLD_TYPE_REAL: {
				private _radius = T_GET_AST_VAR("radiusVar");
				// If we didn't start moving yet then start moving
				if(!_moving) then {
					OOP_INFO_MSG("[w %1] Move %2 to %3: started", [_world ARG _garr ARG _targetPos]);

					// Recalculate radius according to the proper function if we are targeting a location
					T_GET_AST_VAR("targetVar") params ["_targetType", "_targetTarget"];
					if (_targetType == TARGET_TYPE_LOCATION) then {
						private _locModel = CALLM(_world, "getLocation", [_targetTarget]);
						private _radiusNew = CALLSM1("GoalGarrisonMove", "getLocationMoveRadius", GETV(_locModel, "actual"));
						T_SET_AST_VAR("radiusVar", _radiusNew);
						_radius = _radiusNew;
					};

					CALLM(_garr, "moveActual", [_targetPos ARG _radius]);
					T_SETV("moving", true);
				} else {
					// Are we there yet?
					_arrived = CALLM0(_garr, "moveActualComplete");
					if(_arrived) then {
						T_SETV("moving", false);
					};
				};
			};
		};
		if(_arrived) then {
			T_GETV("successState")
		} else {
			CMDR_ACTION_STATE_NONE
		}
	ENDMETHOD;

	public override METHOD(cancel)
		params [P_THISOBJECT, P_OOP_OBJECT("_world")];
		if(GETV(_world, "type") == WORLD_TYPE_REAL && T_GETV("moving")) then {
			private _garr = CALLM(_world, "getGarrison", [T_GET_AST_VAR("garrIdVar")]);
			ASSERT_OBJECT(_garr);
			CALLM0(_garr, "cancelMoveActual");
		};
	ENDMETHOD;
ENDCLASS;


#ifdef _SQF_VM

#define CMDR_ACTION_STATE_FAILED_GARRISON_DEAD CMDR_ACTION_STATE_CUSTOM+1
#define CMDR_ACTION_STATE_FAILED_TARGET_DEAD CMDR_ACTION_STATE_CUSTOM+2

["AST_MoveGarrison.new", {
	private _action = NEW("CmdrAction", []);
	private _thisObject = NEW("AST_MoveGarrison", 
		[_action]+
		[[CMDR_ACTION_STATE_START]]+
		[CMDR_ACTION_STATE_END]+
		[CMDR_ACTION_STATE_FAILED_GARRISON_DEAD]+
		[CMDR_ACTION_STATE_FAILED_TARGET_DEAD]+
		[CALLM1(_action, "createVariable", 0)]+
		[CALLM1(_action, "createVariable", [TARGET_TYPE_GARRISON, 0])]+
		[CALLM1(_action, "createVariable", 200)]
	);
	
	private _class = OBJECT_PARENT_CLASS_STR(_thisObject);
	["Object exists", !(isNil "_class")] call test_Assert;
}] call test_AddTest;

AST_MoveGarrison_test_fn = {
	params ["_world", "_garrison", "_target"];
	private _action = NEW("CmdrAction", []);
	private _thisObject = NEW("AST_MoveGarrison", 
		[_action]+
		[[CMDR_ACTION_STATE_START]]+
		[CMDR_ACTION_STATE_END]+
		[CMDR_ACTION_STATE_FAILED_GARRISON_DEAD]+
		[CMDR_ACTION_STATE_FAILED_TARGET_DEAD]+
		[CALLM1(_action, "createVariable", GETV(_garrison, "id"))]+
		[CALLM1(_action, "createVariable", _target)]+
		[CALLM1(_action, "createVariable", 200)]
	);
	T_CALLM("apply", [_world])
};

#define TARGET_POS [1, 2, 3]

["AST_MoveGarrison.apply(sim, garrison=dead)", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_FUTURE]);
	private _garrison = NEW("GarrisonModel", [_world ARG "<undefined>"]);
	private _endState = [_world, _garrison, [TARGET_TYPE_POSITION, TARGET_POS]] call AST_MoveGarrison_test_fn;
	["State after apply is correct", _endState == CMDR_ACTION_STATE_FAILED_GARRISON_DEAD] call test_Assert;
}] call test_AddTest;

["AST_MoveGarrison.apply(sim, target=pos)", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_FUTURE]);
	private _garrison = NEW("GarrisonModel", [_world ARG "<undefined>"]);
	SETV(_garrison, "efficiency", EFF_MIN_EFF);
	private _target = [TARGET_TYPE_POSITION, TARGET_POS];
	private _endState = [_world, _garrison, _target] call AST_MoveGarrison_test_fn;
	["State after apply is correct", _endState == CMDR_ACTION_STATE_END] call test_Assert;
	["Garrison pos correct", GETV(_garrison, "pos") isEqualTo TARGET_POS] call test_Assert;
}] call test_AddTest;

["AST_MoveGarrison.apply(sim, target=garrison)", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_FUTURE]);
	private _garrison = NEW("GarrisonModel", [_world ARG "<undefined>"]);
	SETV(_garrison, "efficiency", EFF_MIN_EFF);
	private _targetGarrison = NEW("GarrisonModel", [_world ARG "<undefined>"]);
	SETV(_targetGarrison, "efficiency", EFF_MIN_EFF);
	SETV(_targetGarrison, "pos", TARGET_POS);

	private _endState = [_world, _garrison, [TARGET_TYPE_GARRISON, GETV(_targetGarrison, "id")]] call AST_MoveGarrison_test_fn;
	["State after apply is correct", _endState == CMDR_ACTION_STATE_END] call test_Assert;
	["Garrison pos correct", GETV(_garrison, "pos") isEqualTo TARGET_POS] call test_Assert;
}] call test_AddTest;

/*
// After the changes I have added to make player commander UI work, it's a bit different, so I have disabled this test
//    Sparker

["AST_MoveGarrison.apply(sim, target=garrison+dead)", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_FUTURE]);
	private _garrison = NEW("GarrisonModel", [_world ARG "<undefined>"]);
	SETV(_garrison, "efficiency", EFF_MIN_EFF);
	private _targetGarrison = NEW("GarrisonModel", [_world ARG "<undefined>"]);
	SETV(_targetGarrison, "pos", TARGET_POS);

	private _endState = [_world, _garrison, [TARGET_TYPE_GARRISON, GETV(_targetGarrison, "id")]] call AST_MoveGarrison_test_fn;
	["State after apply is correct", _endState == CMDR_ACTION_STATE_FAILED_TARGET_DEAD] call test_Assert;
}] call test_AddTest;
*/

["AST_MoveGarrison.apply(sim, target=location)", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_FUTURE]);
	private _garrison = NEW("GarrisonModel", [_world ARG "<undefined>"]);
	SETV(_garrison, "efficiency", EFF_MIN_EFF);
	private _targetLocation = NEW("LocationModel", [_world ARG "<undefined>"]);
	SETV(_targetLocation, "pos", TARGET_POS);

	private _endState = [_world, _garrison, [TARGET_TYPE_LOCATION, GETV(_targetLocation, "id")]] call AST_MoveGarrison_test_fn;
	["State after apply is correct", _endState == CMDR_ACTION_STATE_END] call test_Assert;
	["Garrison pos correct", GETV(_garrison, "pos") isEqualTo TARGET_POS] call test_Assert;
}] call test_AddTest;

#endif