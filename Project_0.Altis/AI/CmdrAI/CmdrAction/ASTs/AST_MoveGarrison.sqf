#include "..\..\common.hpp"

CLASS("AST_MoveGarrison", "ActionStateTransition")
	VARIABLE_ATTR("action", [ATTR_PRIVATE]);
	VARIABLE_ATTR("successState", [ATTR_PRIVATE]);
	VARIABLE_ATTR("failGarrisonDead", [ATTR_PRIVATE]);
	VARIABLE_ATTR("failTargetDead", [ATTR_PRIVATE]);
	VARIABLE_ATTR("moving", [ATTR_PRIVATE]);
	// Inputs
	VARIABLE_ATTR("garrId", [ATTR_PRIVATE]);
	VARIABLE_ATTR("target", [ATTR_PRIVATE]);
	VARIABLE_ATTR("radius", [ATTR_PRIVATE]);

	METHOD("new") {
		params [P_THISOBJECT, 
			P_OOP_OBJECT("_action"),			// Owner action for debugging purposes
			P_ARRAY("_fromStates"),				// States it is valid from
			P_AST_STATE("_successState"),		// if we reached the target
			P_AST_STATE("_failGarrisonDead"), 	// if the garrison we are moving died
			P_AST_STATE("_failTargetDead"), 	// if the target died (if it can)
			// inputs
			P_AST_VAR("_garrId"), 				// garrison to move
			P_AST_VAR("_target"), 				// target [type, value] (garrison, location or position)
			P_AST_VAR("_radius") 				// radius we need to reach
		];
		ASSERT_OBJECT_CLASS(_action, "CmdrAction");

		T_SETV("action", _action);
		T_SETV("fromStates", _fromStates);
		T_SETV("successState", _successState);
		T_SETV("failGarrisonDead", _failGarrisonDead);
		T_SETV("failTargetDead", _failTargetDead);
		T_SETV("moving", false);
		T_SETV("garrId", _garrId);
		T_SETV("target", _target);
		T_SETV("radius", _radius);
	} ENDMETHOD;

	/* override */ METHOD("apply") {
		params [P_THISOBJECT, P_STRING("_world")];
		ASSERT_OBJECT_CLASS(_world, "WorldModel");

		private _garr = CALLM(_world, "getGarrison", [T_GET_AST_VAR("garrId")]);
		ASSERT_OBJECT(_garr);

		if(CALLM(_garr, "isDead", [])) exitWith {
			T_GETV("failGarrisonDead")
		};

		//T_GET_AST_VAR("target") params ["_targetType", "_target"];

		private _targetPos = [_world, T_GET_AST_VAR("target")] call Target_fnc_GetPos;
		if(!(_targetPos isEqualType [])) exitWith { T_GETV("failTargetDead") };

		private _arrived = false;

		switch(GETV(_world, "type")) do {
			// Move can't be applied instantly
			case WORLD_TYPE_SIM_NOW: {};
			// Move completes at some point in the future
			case WORLD_TYPE_SIM_FUTURE: {
				CALLM(_garr, "moveSim", [_targetPos]);
				_arrived = true;
			};
			case WORLD_TYPE_REAL: {
				private _radius = T_GET_AST_VAR("radius");
				T_PRVAR(moving);
				if(!_moving) then {
					// Start moving
					OOP_INFO_MSG("[w %1] Move %2 to %3: started", [_world ARG _garr ARG _targetPos]);
					CALLM(_garr, "moveActual", [_targetPos ARG _radius]);
					T_SETV("moving", true);
				} else {
					// Are we there yet?
					private _done = CALLM(_garr, "moveActualComplete", []);
					if(_done) then {
						private _garrPos = GETV(_garr, "pos");
						if((_garrPos distance _targetPos) <= _radius * 1.5) then {
							OOP_INFO_MSG("[w %1] Move %2 to %3: complete, reached target within %4m", [_world ARG LABEL(_garr) ARG _targetPos ARG _radius]);
							_arrived = true;
						} else {
							// Move again cos we didn't get there yet!
							OOP_INFO_MSG("[w %1] Move %2 to %3: complete, didn't reach target within %4m, moving again", [_world ARG LABEL(_garr) ARG _targetPos ARG _radius]);
							T_SETV("moving", false);
						};
					};
				};
			};
		};
		if(_arrived) then {
			T_GETV("successState")
		} else {
			CMDR_ACTION_STATE_NONE
		}
	} ENDMETHOD;
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
		[MAKE_AST_VAR(0)]+
		[MAKE_AST_VAR([TARGET_TYPE_GARRISON, 0])]+
		[MAKE_AST_VAR(200)]
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
		[MAKE_AST_VAR(GETV(_garrison, "id"))]+
		[MAKE_AST_VAR(_target)]+
		[MAKE_AST_VAR(200)]
	);
	CALLM(_thisObject, "apply", [_world])
};

#define TARGET_POS [1, 2, 3]

["AST_MoveGarrison.apply(sim, garrison=dead)", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_FUTURE]);
	private _garrison = NEW("GarrisonModel", [_world]);
	private _endState = [_world, _garrison, [TARGET_TYPE_POSITION, TARGET_POS]] call AST_MoveGarrison_test_fn;
	["State after apply is correct", _endState == CMDR_ACTION_STATE_FAILED_GARRISON_DEAD] call test_Assert;
}] call test_AddTest;

["AST_MoveGarrison.apply(sim, target=pos)", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_FUTURE]);
	private _garrison = NEW("GarrisonModel", [_world]);
	SETV(_garrison, "efficiency", EFF_MIN_EFF);
	private _target = [TARGET_TYPE_POSITION, TARGET_POS];
	private _endState = [_world, _garrison, _target] call AST_MoveGarrison_test_fn;
	["State after apply is correct", _endState == CMDR_ACTION_STATE_END] call test_Assert;
	["Garrison pos correct", GETV(_garrison, "pos") isEqualTo TARGET_POS] call test_Assert;
}] call test_AddTest;

["AST_MoveGarrison.apply(sim, target=garrison)", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_FUTURE]);
	private _garrison = NEW("GarrisonModel", [_world]);
	SETV(_garrison, "efficiency", EFF_MIN_EFF);
	private _targetGarrison = NEW("GarrisonModel", [_world]);
	SETV(_targetGarrison, "efficiency", EFF_MIN_EFF);
	SETV(_targetGarrison, "pos", TARGET_POS);

	private _endState = [_world, _garrison, [TARGET_TYPE_GARRISON, GETV(_targetGarrison, "id")]] call AST_MoveGarrison_test_fn;
	["State after apply is correct", _endState == CMDR_ACTION_STATE_END] call test_Assert;
	["Garrison pos correct", GETV(_garrison, "pos") isEqualTo TARGET_POS] call test_Assert;
}] call test_AddTest;

["AST_MoveGarrison.apply(sim, target=garrison+dead)", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_FUTURE]);
	private _garrison = NEW("GarrisonModel", [_world]);
	SETV(_garrison, "efficiency", EFF_MIN_EFF);
	private _targetGarrison = NEW("GarrisonModel", [_world]);
	SETV(_targetGarrison, "pos", TARGET_POS);

	private _endState = [_world, _garrison, [TARGET_TYPE_GARRISON, GETV(_targetGarrison, "id")]] call AST_MoveGarrison_test_fn;
	["State after apply is correct", _endState == CMDR_ACTION_STATE_FAILED_TARGET_DEAD] call test_Assert;
}] call test_AddTest;

["AST_MoveGarrison.apply(sim, target=location)", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_FUTURE]);
	private _garrison = NEW("GarrisonModel", [_world]);
	SETV(_garrison, "efficiency", EFF_MIN_EFF);
	private _targetLocation = NEW("LocationModel", [_world]);
	SETV(_targetLocation, "pos", TARGET_POS);

	private _endState = [_world, _garrison, [TARGET_TYPE_LOCATION, GETV(_targetLocation, "id")]] call AST_MoveGarrison_test_fn;
	["State after apply is correct", _endState == CMDR_ACTION_STATE_END] call test_Assert;
	["Garrison pos correct", GETV(_garrison, "pos") isEqualTo TARGET_POS] call test_Assert;
}] call test_AddTest;

#endif