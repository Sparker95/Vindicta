#include "..\..\common.hpp"

CLASS("AST_GarrisonAttackTarget", "ActionStateTransition")
	VARIABLE_ATTR("action", [ATTR_PRIVATE]);
	VARIABLE_ATTR("successState", [ATTR_PRIVATE]);
	VARIABLE_ATTR("targetOutOfRangeState", [ATTR_PRIVATE]);
	VARIABLE_ATTR("garrDeadState", [ATTR_PRIVATE]);
	VARIABLE_ATTR("timeOutState", [ATTR_PRIVATE]);

	// Inputs
	VARIABLE_ATTR("garrIdVar", [ATTR_PRIVATE]);
	VARIABLE_ATTR("targetVar", [ATTR_PRIVATE]);
	VARIABLE_ATTR("maxDistanceVar", [ATTR_PRIVATE]);

	// If garrison is set to clear area
	VARIABLE_ATTR("startDate", [ATTR_PRIVATE]);
	VARIABLE_ATTR("clearing", [ATTR_PRIVATE]);

	METHOD("new") {
		params [P_THISOBJECT, 
			P_OOP_OBJECT("_action"),					// Source action for debugging purposes
			P_ARRAY("_fromStates"),						// States it is valid from
			P_AST_STATE("_successState"),				// State upon successfully destroying the target
			P_AST_STATE("_targetOutOfRangeState"), 		// State if target is out of our range
			P_AST_STATE("_garrDeadState"), 				// State if the garrison is dead (should really not get this far if it is)
			P_AST_STATE("_timeOutState"), 				// State if we timed out (couldn't kill and didn't get killed)
			// inputs
			P_AST_VAR("_garrIdVar"),	 				// Id of garrison to merge/join from
			P_AST_VAR("_targetVar"),					// Target to attack (garrison, location or cluster)
			P_AST_VAR("_maxDistanceVar")				// Target to attack (garrison, location or cluster)
		];
		ASSERT_OBJECT_CLASS(_action, "CmdrAction");

		T_SETV("action", _action);
		T_SETV("fromStates", _fromStates);

		T_SETV("successState", _successState);
		T_SETV("targetOutOfRangeState", _targetOutOfRangeState);
		T_SETV("garrDeadState", _garrDeadState);
		T_SETV("timeOutState", _timeOutState);
		T_SETV("garrIdVar", _garrIdVar);
		T_SETV("targetVar", _targetVar);
		T_SETV("maxDistanceVar", _maxDistanceVar);

		T_SETV("clearing", false);
	} ENDMETHOD;

	/* override */ METHOD("apply") {
		params [P_THISOBJECT, P_STRING("_world")];
		ASSERT_OBJECT_CLASS(_world, "WorldModel");

		T_PRVAR(action);
		private _garrId = T_GET_AST_VAR("garrIdVar");
		ASSERT_MSG(_garrId isEqualType 0, "garrId should be a garrison Id");
		private _garr = CALLM(_world, "getGarrison", [_garrId]);
		ASSERT_OBJECT(_garr);

		// If the detachment or target died then we just finish the whole action immediately
		if(CALLM(_garr, "isDead", [])) exitWith { 
			OOP_WARNING_MSG("[w %1 a %2] Garrison %3 is dead so can't attack target", [_world]+[_action]+[LABEL(_garr)]);
			T_GETV("garrDeadState")
		};

		private _target = T_GET_AST_VAR("targetVar");
		if(T_CALLM("isTargetDead", [_world ARG _target])) exitWith {
			T_GETV("successState")
		};

		private _targetPos = [_world, _target] call Target_fnc_GetPos;
		if(!(_targetPos isEqualType [])) exitWith { 
			OOP_WARNING_MSG("[w %1 a %2] Can't get position of target %3", [_world]+[_action]+[_target]);
			T_GETV("successState") 
		};

		// Check we are in range
		private _garrPos = GETV(_garr, "pos");
		if((_garrPos distance _targetPos) > T_GET_AST_VAR("maxDistanceVar")) exitWith {
			T_GETV("targetOutOfRangeState") 
		};

		private _success = false;
		switch(GETV(_world, "type")) do {
			// Attack can't be applied instantly
			case WORLD_TYPE_SIM_NOW: {};
			// Attack completes at some point in the future
			case WORLD_TYPE_SIM_FUTURE: {
				T_CALLM("simKillTarget", []);
				CALLM(_garr, "moveSim", [_world ARG _target]);
				_success = true;
			};
			case WORLD_TYPE_REAL: {
				private _radius = T_GET_AST_VAR("radius");
				T_PRVAR(clearing);
				if(!_clearing) then {
					// Start moving
					OOP_INFO_MSG("[w %1] %2 clearing area at %3: started", [_world ARG _garr ARG _targetPos]);
					CALLM(_garr, "clearAreaActual", [_targetPos ARG _radius ARG ]);
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

		CMDR_ACTION_STATE_NONE
	} ENDMETHOD;

	METHOD("isTargetDead") {
		params [P_THISOBJECT, P_OOP_OBJECT(_world), P_ARRAY(_targetObj)];

		_targetObj params ["_targetType", "_target"];

		private _isDead = false;
		switch(_targetType) do {
			case TARGET_TYPE_GARRISON: {
				ASSERT_MSG(_target isEqualType 0, "TARGET_TYPE_GARRISON expects a garrison ID");
				private _garr = CALLM(_world, "getGarrison", [_target]);
				ASSERT_OBJECT(_garr);
				_isDead = CALLM(_garr, "isDead", []);
			};
			case TARGET_TYPE_LOCATION: {
				ASSERT_MSG(_target isEqualType 0, "TARGET_TYPE_LOCATION expects a location ID");
				private _loc = CALLM(_world, "getLocation", [_target]);
				ASSERT_OBJECT(_loc);
				// TODO: What? Check intel on location?
				FAILURE("Not implemented");
			};
			case TARGET_TYPE_POSITION: {
				ASSERT_MSG(_target isEqualType [], "TARGET_TYPE_POSITION expects a position [x,y,z]");
				// TODO: What? Check surrounding area? Time out?
				FAILURE("Not implemented");
			};
			case TARGET_TYPE_CLUSTER: {
				ASSERT_MSG(_target isEqualType 0, "TARGET_TYPE_CLUSTER expects a cluster ID");
				private _cluster = CALLM(_world, "getCluster", [_target]);
				ASSERT_OBJECT(_cluster);
				_isDead = CALLM(_cluster, "isDead", []);
			};
			default {
				FAILURE("Target is not valid");
			};
		};
		_isDead

	} ENDMETHOD;

	METHOD("simKillTarget") {
		params [P_THISOBJECT, P_OOP_OBJECT(_world), P_ARRAY(_targetObj)];

		_targetObj params ["_targetType", "_target"];

		switch(_targetType) do {
			case TARGET_TYPE_GARRISON: {
				ASSERT_MSG(_target isEqualType 0, "TARGET_TYPE_GARRISON expects a garrison ID");
				private _garr = CALLM(_world, "getGarrison", [_target]);
				ASSERT_OBJECT(_garr);
				CALLM(_garr, "killed", []);
			};
			case TARGET_TYPE_LOCATION: {
				ASSERT_MSG(_target isEqualType 0, "TARGET_TYPE_LOCATION expects a location ID");
				private _loc = CALLM(_world, "getLocation", [_target]);
				ASSERT_OBJECT(_loc);
				// TODO: Kill enemy garrisons?
				FAILURE("Not implemented");
			};
			case TARGET_TYPE_POSITION: {
				ASSERT_MSG(_target isEqualType [], "TARGET_TYPE_POSITION expects a position [x,y,z]");
				// TODO: What? Check surrounding area? Time out?
				FAILURE("Not implemented");
			};
			case TARGET_TYPE_CLUSTER: {
				ASSERT_MSG(_target isEqualType 0, "TARGET_TYPE_CLUSTER expects a cluster ID");
				private _cluster = CALLM(_world, "getCluster", [_target]);
				ASSERT_OBJECT(_cluster);
				CALLM(_cluster, "killed", []);
			};
			default {
				FAILURE("Target is not valid");
			};
		};
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