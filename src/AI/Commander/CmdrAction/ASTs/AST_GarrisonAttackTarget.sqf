#include "common.hpp"

/*
Class: AI.CmdrAI.CmdrAction.ASTs.AST_GarrisonAttackTarget
Order a garrison to attack a target.

Parent: <ActionStateTransition>
*/
#define OOP_CLASS_NAME AST_GarrisonAttackTarget
CLASS("AST_GarrisonAttackTarget", "ActionStateTransition")
	VARIABLE_ATTR("successState", [ATTR_PRIVATE ARG ATTR_SAVE]);
	VARIABLE_ATTR("garrDeadState", [ATTR_PRIVATE ARG ATTR_SAVE]);
	VARIABLE_ATTR("timeOutState", [ATTR_PRIVATE ARG ATTR_SAVE]);

	// Inputs
	VARIABLE_ATTR("garrIdVar", [ATTR_PRIVATE ARG ATTR_SAVE]);
	VARIABLE_ATTR("targetVar", [ATTR_PRIVATE ARG ATTR_SAVE]);
	VARIABLE_ATTR("moveRadiusVar", [ATTR_PRIVATE ARG ATTR_SAVE]);

	// If garrison is set to clear area
	VARIABLE_ATTR("startDate", [ATTR_PRIVATE ARG ATTR_SAVE]);
	VARIABLE_ATTR("clearing", [ATTR_PRIVATE ARG ATTR_SAVE]);

	/*
	Method: new
	Create an AST to give an attack target order to a garrison.
	
	Parameters:
		_action - <CmdrAction>, action this AST is part of, for debugging purposes
		_fromStates - Array of <CMDR_ACTION_STATE>, states this AST is valid from
		_successState - <CMDR_ACTION_STATE>, state to return after success
		_garrDeadState - <CMDR_ACTION_STATE>, state to return when garrison performing the action is dead
		_timeOutState - <CMDR_ACTION_STATE>, state to return if this action times out
		_garrIdVar - IN <AST_VAR>(Number), GarrisonModel Id of the garrison performing the attack
		_targetVar - IN <AST_VAR>(<CmdrAITarget>), target to attack
		_moveRadiusVar - IN <AST_VAR>(Number), radius around target at which to stop moving and start attacking
	*/
	METHOD(new)
		params [P_THISOBJECT,
			P_OOP_OBJECT("_action"),
			P_ARRAY("_fromStates"),
			P_AST_STATE("_successState"),
			P_AST_STATE("_garrDeadState"),
			P_AST_STATE("_timeOutState"),
			P_AST_VAR("_garrIdVar"),
			P_AST_VAR("_targetVar"),
			P_AST_VAR("_moveRadiusVar")
		];

		T_SETV("fromStates", _fromStates);

		T_SETV("successState", _successState);
		T_SETV("garrDeadState", _garrDeadState);
		T_SETV("timeOutState", _timeOutState);
		T_SETV("garrIdVar", _garrIdVar);
		T_SETV("targetVar", _targetVar);
		T_SETV("moveRadiusVar", _moveRadiusVar);

		T_SETV("clearing", false);
	ENDMETHOD;

	public override METHOD(apply)
		params [P_THISOBJECT, P_STRING("_world")];
		ASSERT_OBJECT_CLASS(_world, "WorldModel");

		private _action = T_GETV("action");
		private _clearing = T_GETV("clearing");

		private _garrId = T_GET_AST_VAR("garrIdVar");
		ASSERT_MSG(_garrId isEqualType 0, "garrId should be a garrison Id");
		private _garr = CALLM(_world, "getGarrison", [_garrId]);
		ASSERT_OBJECT(_garr);

		// If the detachment or target died then we just finish the whole action immediately
		if(CALLM0(_garr, "isDead")) exitWith { 
			OOP_WARNING_MSG("[w %1 a %2] Garrison %3 is dead so can't attack target", [_world ARG _action ARG LABEL(_garr)]);
			if(_clearing and GETV(_world, "type") == WORLD_TYPE_REAL) then {
				T_SETV("clearing", false);
			};
			T_GETV("garrDeadState")
		};

		// Stop the attack if the target is dead, call it success.
		// TODO: Perhaps we don't want to rely on this as a criteria to stop?
		private _target = T_GET_AST_VAR("targetVar");
		if(T_CALLM("isTargetDead", [_world ARG _target])) exitWith {
			if(_clearing and GETV(_world, "type") == WORLD_TYPE_REAL) then {
				CALLM0(_garr, "cancelClearAreaActual");
				T_SETV("clearing", false);
			};
			T_GETV("successState")
		};

		// If we can't get the target position then just finish with success. Blame commander.
		private _targetPos = [_world, _target] call Target_fnc_GetPos;
		if(!(_targetPos isEqualType [])) exitWith { 
			OOP_WARNING_MSG("[w %1 a %2] Can't get position of target %3", [_world ARG _action ARG _target]);
			T_GETV("successState") 
		};

		private _success = false;
		// How we behave depends on world type.
		switch(GETV(_world, "type")) do {
			// When update world NOW sim we do nothing, because we can't instantly move to and kill the enemy.
			case WORLD_TYPE_SIM_NOW: {};
			// When update world FUTURE sim we will assume we succeeded. Its the power of positive thinking.
			case WORLD_TYPE_SIM_FUTURE: {
				CALLM(_garr, "moveSim", [_targetPos]);
				T_CALLM("simKillTarget", [_world ARG _target]);
				_success = true;
			};
			// When doing a real world update we give the attack order if it isn't already given, 
			// or check if it is complete.
			case WORLD_TYPE_REAL: {
				if(!_clearing) then {
					private _moveRadius = T_GET_AST_VAR("moveRadiusVar");
					private _clearRadius = 50 max T_CALLM("getTargetRadius", [_world ARG _target]);
					//_moveRadius = _moveRadius + _clearRadius; // todo find a better way to specify where to dismount?
					// Start clear order
					OOP_INFO_MSG("[w %1] %2 clearing area at %3: started", [_world ARG _garr ARG _targetPos]);
					#ifdef RELEASE_BUILD
					private _timeToClear = (80 * sqrt (_clearRadius + 100)) min (20*60); // Seconds
					#else
					private _timeToClear = 120; // Seconds
					#endif
					CALLM(_garr, "clearAreaActual", [_targetPos ARG _moveRadius ARG _clearRadius ARG _timeToClear]);
					T_SETV("clearing", true);
				} else {
					// Are we done yet?
					_success = CALLM0(_garr, "clearActualComplete");
					T_SETV("clearing", not _success);
				};
			};
		};
		if(_success) then {
			T_GETV("successState")
		} else {
			CMDR_ACTION_STATE_NONE
		}
	ENDMETHOD;

	public override METHOD(cancel)
		params [P_THISOBJECT, P_OOP_OBJECT("_world")];
		if(GETV(_world, "type") == WORLD_TYPE_REAL && T_GETV("clearing")) then {
			private _garr = CALLM(_world, "getGarrison", [T_GET_AST_VAR("garrIdVar")]);
			ASSERT_OBJECT(_garr);
			CALLM0(_garr, "cancelClearAreaActual");
		};
	ENDMETHOD;

	METHOD(isTargetDead)
		params [P_THISOBJECT, P_OOP_OBJECT("_world"), P_ARRAY("_targetObj")];

		_targetObj params ["_targetType", "_target"];

		private _isDead = false;
		// How to determine if the target is "dead" depends on the target type. For some target types
		// there is no such concept as dead.
		// TODO: should we return true or false for target types that don't have a concept of "dead"?
		switch(_targetType) do {
			case TARGET_TYPE_GARRISON: {
				ASSERT_MSG(_target isEqualType 0, "TARGET_TYPE_GARRISON expects a garrison ID");
				private _garr = CALLM(_world, "getGarrison", [_target]);
				ASSERT_OBJECT(_garr);
				_isDead = CALLM0(_garr, "isDead");
			};
			case TARGET_TYPE_LOCATION: {
				ASSERT_MSG(_target isEqualType 0, "TARGET_TYPE_LOCATION expects a location ID");
				_isDead = false;
			};
			case TARGET_TYPE_POSITION: {
				ASSERT_MSG((_target isEqualType []), "TARGET_TYPE_POSITION expects a position [x,y,z]");
				_isDead = false;
			};
			case TARGET_TYPE_CLUSTER: {
				ASSERT_MSG(_target isEqualType 0, "TARGET_TYPE_CLUSTER expects a cluster ID");
				private _cluster = CALLM(_world, "getCluster", [_target]);
				ASSERT_OBJECT(_cluster);
				_isDead = CALLM0(_cluster, "isDead");
			};
			default {
				FAILURE("Target is not valid");
			};
		};
		_isDead

	ENDMETHOD;

	METHOD(getTargetRadius)
		params [P_THISOBJECT, P_OOP_OBJECT("_world"), P_ARRAY("_targetObj")];

		_targetObj params ["_targetType", "_target"];

		private _radius = 200; // default
		switch(_targetType) do {
			case TARGET_TYPE_LOCATION: {
				ASSERT_MSG(_target isEqualType 0, "TARGET_TYPE_LOCATION expects a location ID");
				private _loc = CALLM(_world, "getLocation", [_target]);
				ASSERT_OBJECT(_loc);
				_radius = GETV(_loc, "radius")
			};
			case TARGET_TYPE_CLUSTER: {
				ASSERT_MSG(_target isEqualType 0, "TARGET_TYPE_CLUSTER expects a cluster ID");
				private _cluster = CALLM(_world, "getCluster", [_target]);
				ASSERT_OBJECT(_cluster);
				_radius = GETV(_cluster, "radius") * 1.5
			};
		};
		_radius
	ENDMETHOD;

	// Simulate the death of the target (for FUTURE sim worlds).
	METHOD(simKillTarget)
		params [P_THISOBJECT, P_OOP_OBJECT("_world"), P_ARRAY("_targetObj")];

		_targetObj params ["_targetType", "_target"];

		switch(_targetType) do {
			case TARGET_TYPE_GARRISON: {
				ASSERT_MSG(_target isEqualType 0, "TARGET_TYPE_GARRISON expects a garrison ID");
				private _garr = CALLM(_world, "getGarrison", [_target]);
				ASSERT_OBJECT(_garr);
				CALLM0(_garr, "killed");
			};
			case TARGET_TYPE_LOCATION: {
				ASSERT_MSG(_target isEqualType 0, "TARGET_TYPE_LOCATION expects a location ID");
			};
			case TARGET_TYPE_POSITION: {
				ASSERT_MSG(_target isEqualType [], "TARGET_TYPE_POSITION expects a position [x,y,z]");
			};
			case TARGET_TYPE_CLUSTER: {
				ASSERT_MSG(_target isEqualType 0, "TARGET_TYPE_CLUSTER expects a cluster ID");
				private _cluster = CALLM(_world, "getCluster", [_target]);
				ASSERT_OBJECT(_cluster);
				CALLM0(_cluster, "killed");
			};
			default {
				FAILURE("Target is not valid");
			};
		};
	ENDMETHOD;
	
ENDCLASS;


#ifdef _SQF_VM

["AST_GarrisonAttackTarget.new", {
	SCOPE_IGNORE_ACCESS(CmdrAction);
	private _action = NEW("CmdrAction", []);
	private _thisObject = NEW("AST_GarrisonAttackTarget", 
		[_action]+
		[[CMDR_ACTION_STATE_START]]+
		[CMDR_ACTION_STATE_END]+
		[CMDR_ACTION_STATE_FAILED_GARRISON_DEAD]+
		[CMDR_ACTION_STATE_FAILED_TIMEOUT]+
		[CALLM1(_action, "createVariable", 0)]+
		[CALLM1(_action, "createVariable", [TARGET_TYPE_GARRISON, 0])]+
		[CALLM1(_action, "createVariable", 200)]
	);
	
	private _class = OBJECT_PARENT_CLASS_STR(_thisObject);
	["Object exists", !(isNil "_class")] call test_Assert;
}] call test_AddTest;

// AST_MoveGarrison_test_fn = {
// 	params ["_world", "_garrison", "_target"];
// 	private _action = NEW("CmdrAction", []);
// 	private _thisObject = NEW("AST_MoveGarrison", 
// 		[_action]+
// 		[[CMDR_ACTION_STATE_START]]+
// 		[CMDR_ACTION_STATE_END]+
// 		[CMDR_ACTION_STATE_FAILED_GARRISON_DEAD]+
// 		[CMDR_ACTION_STATE_FAILED_TARGET_DEAD]+
// 		[T_CALLM1("createVariable", GETV(_garrison, "id"))]+
// 		[T_CALLM1("createVariable", _target)]+
// 		[T_CALLM1("createVariable", 200)]
// 	);
// 	T_CALLM("apply", [_world])
// };

// #define TARGET_POS [1, 2, 3]

// ["AST_MoveGarrison.apply(sim, garrison=dead)", {
// 	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_FUTURE]);
// 	private _garrison = NEW("GarrisonModel", [_world]);
// 	private _endState = [_world, _garrison, [TARGET_TYPE_POSITION, TARGET_POS]] call AST_MoveGarrison_test_fn;
// 	["State after apply is correct", _endState == CMDR_ACTION_STATE_FAILED_GARRISON_DEAD] call test_Assert;
// }] call test_AddTest;

// ["AST_MoveGarrison.apply(sim, target=pos)", {
// 	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_FUTURE]);
// 	private _garrison = NEW("GarrisonModel", [_world]);
// 	SETV(_garrison, "efficiency", EFF_MIN_EFF);
// 	private _target = [TARGET_TYPE_POSITION, TARGET_POS];
// 	private _endState = [_world, _garrison, _target] call AST_MoveGarrison_test_fn;
// 	["State after apply is correct", _endState == CMDR_ACTION_STATE_END] call test_Assert;
// 	["Garrison pos correct", GETV(_garrison, "pos") isEqualTo TARGET_POS] call test_Assert;
// }] call test_AddTest;

// ["AST_MoveGarrison.apply(sim, target=garrison)", {
// 	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_FUTURE]);
// 	private _garrison = NEW("GarrisonModel", [_world]);
// 	SETV(_garrison, "efficiency", EFF_MIN_EFF);
// 	private _targetGarrison = NEW("GarrisonModel", [_world]);
// 	SETV(_targetGarrison, "efficiency", EFF_MIN_EFF);
// 	SETV(_targetGarrison, "pos", TARGET_POS);

// 	private _endState = [_world, _garrison, [TARGET_TYPE_GARRISON, GETV(_targetGarrison, "id")]] call AST_MoveGarrison_test_fn;
// 	["State after apply is correct", _endState == CMDR_ACTION_STATE_END] call test_Assert;
// 	["Garrison pos correct", GETV(_garrison, "pos") isEqualTo TARGET_POS] call test_Assert;
// }] call test_AddTest;

// ["AST_MoveGarrison.apply(sim, target=garrison+dead)", {
// 	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_FUTURE]);
// 	private _garrison = NEW("GarrisonModel", [_world]);
// 	SETV(_garrison, "efficiency", EFF_MIN_EFF);
// 	private _targetGarrison = NEW("GarrisonModel", [_world]);
// 	SETV(_targetGarrison, "pos", TARGET_POS);

// 	private _endState = [_world, _garrison, [TARGET_TYPE_GARRISON, GETV(_targetGarrison, "id")]] call AST_MoveGarrison_test_fn;
// 	["State after apply is correct", _endState == CMDR_ACTION_STATE_FAILED_TARGET_DEAD] call test_Assert;
// }] call test_AddTest;

// ["AST_MoveGarrison.apply(sim, target=location)", {
// 	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_FUTURE]);
// 	private _garrison = NEW("GarrisonModel", [_world]);
// 	SETV(_garrison, "efficiency", EFF_MIN_EFF);
// 	private _targetLocation = NEW("LocationModel", [_world]);
// 	SETV(_targetLocation, "pos", TARGET_POS);

// 	private _endState = [_world, _garrison, [TARGET_TYPE_LOCATION, GETV(_targetLocation, "id")]] call AST_MoveGarrison_test_fn;
// 	["State after apply is correct", _endState == CMDR_ACTION_STATE_END] call test_Assert;
// 	["Garrison pos correct", GETV(_garrison, "pos") isEqualTo TARGET_POS] call test_Assert;
// }] call test_AddTest;

#endif