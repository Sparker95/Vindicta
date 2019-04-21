#define OOP_DEBUG
#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR

#include "..\common.hpp"

CLASS("CmdrAction", "RefCounted")

	// The priority of this action in relation to other actions of the same or different type.
	VARIABLE("scorePriority");
	// The resourcing available for this action.
	VARIABLE("scoreResource");
	// How strongly this action correlates with the current strategy.
	VARIABLE("scoreStrategy");
	// How close to being complete this action is (>1)
	VARIABLE("scoreCompleteness");

	// Current state of the action
	VARIABLE("state");
	// State transition functions
	VARIABLE("transitions");

	METHOD("new") {
		params [P_THISOBJECT];
		T_SETV("scorePriority", 1);
		T_SETV("scoreResource", 1);
		T_SETV("scoreStrategy", 1);
		T_SETV("scoreCompleteness", 1);
		//T_SETV("complete", false);
		T_SETV("state", CMDR_ACTION_STATE_START);
		T_SETV("transitions", []);
	} ENDMETHOD;

	/* virtual */ METHOD("updateScore") {
		params [P_THISOBJECT, P_STRING("_state")];
	} ENDMETHOD;

	METHOD("getFinalScore") {
		params [P_THISOBJECT];
		T_PRVAR(scorePriority);
		T_PRVAR(scoreResource);
		T_PRVAR(scoreStrategy);
		T_PRVAR(scoreCompleteness);
		// TODO: what is the correct way to combine these scores?
		// Should we try to get them all from 0 to 1?
		// Maybe we want R*(iP + jS + kC)?
		_scorePriority * _scoreResource * _scoreStrategy * _scoreCompleteness
	} ENDMETHOD;

	METHOD("applyToSim") {
		params [P_THISOBJECT, P_STRING("_world")];
		T_PRVAR(state);
		T_PRVAR(transitions);
		ASSERT_MSG(count _transitions > 0, "CmdrAction hasn't got any _transitions assigned");

		while {_state != CMDR_ACTION_STATE_END} do {
			private _newState = CALLSM("ActionStateTransition", "selectAndApply", [_world]+[_state]+[_transitions]);
			ASSERT_MSG(_newState != _state, format (["Couldn't apply action %1 to sim, stuck in state %2"]+[_thisObject]+[_state]));
			_state = _newState;
		};
		// We don't update member var "state" here, this is just a sim
	} ENDMETHOD;

	METHOD("update") {
		params [P_THISOBJECT, P_STRING("_world")];
		T_PRVAR(state);
		T_PRVAR(transitions);
		ASSERT_MSG(count _transitions > 0, "CmdrAction hasn't got any _transitions assigned");
		
		_state = CALLSM("ActionStateTransition", "selectAndApply", [_world]+[_state]+[_transitions]);
		T_SETV("state", _state)
		
		#ifdef DEBUG_CMDRAI
		T_CALLM("debugDraw", []);
		#endif
	} ENDMETHOD;

	METHOD("isComplete") {
		params [P_THISOBJECT];
		T_GETV("state") == CMDR_ACTION_STATE_END
	} ENDMETHOD;

	METHOD("getLabel") {
		params [P_THISOBJECT];
		""
	} ENDMETHOD;

	/* virtual */ METHOD("debugDraw") {
		params [P_THISOBJECT];
	} ENDMETHOD;
	
	// Toolkit for scoring actions -----------------------------------------

	// Get a value that falls off from 1 to 0 with distance, scaled by k.
	// 0m = 1, 2000m = 0.5, 4000m = 0.25, 6000m = 0.2, 10000m = 0.0385
	// See https://www.desmos.com/calculator/59i3cltsfr
	STATIC_METHOD("calcDistanceFalloff") {
		params [P_THISCLASS, P_ARRAY("_from"), P_ARRAY("_to"), "_k"];
		private _kf = if(isNil "_k") then { 1 } else { _k };
		// See https://www.desmos.com/calculator/59i3cltsfr
		private _distScaled = 0.0005 * (_from distance _to) * _kf;
		(1 / (1 + _distScaled * _distScaled))
	} ENDMETHOD;
	
ENDCLASS;


// Unit test
#ifdef _SQF_VM

// Dummy test classes
CLASS("AST_KillGarrison", "ActionStateTransition")
	VARIABLE("garrisonId");

	METHOD("new") {
		params [P_THISOBJECT, P_NUMBER("_garrisonId")];
		T_SETV("garrisonId", _garrisonId);
		T_SETV("fromStates", [CMDR_ACTION_STATE_START]);
		T_SETV("toState", CMDR_ACTION_STATE_END);
	} ENDMETHOD;

	/* virtual */ METHOD("isAvailable") { 
		params [P_THISOBJECT, P_STRING("_world")];
		T_PRVAR(garrisonId);
		private _garrison = CALLM(_world, "getGarrison", [_garrisonId]);
		!(isNil "_garrison")
	} ENDMETHOD;

	/* virtual */ METHOD("apply") { 
		params [P_THISOBJECT, P_STRING("_world")];
		T_PRVAR(garrisonId);
		private _garrison = CALLM(_world, "getGarrison", [_garrisonId]);
		CALLM(_garrison, "killed", []);
		true
	} ENDMETHOD;
ENDCLASS;

["CmdrAction.new", {
	private _obj = NEW("CmdrAction", []);
	private _class = OBJECT_PARENT_CLASS_STR(_obj);
	["Object exists", !(isNil "_class")] call test_Assert;
	["Initial state is correct", GETV(_obj, "state") == CMDR_ACTION_STATE_START] call test_Assert;
}] call test_AddTest;

["CmdrAction.delete", {
	private _obj = NEW("CmdrAction", []);
	DELETE(_obj);
	isNil { OBJECT_PARENT_CLASS_STR(_obj) }
}] call test_AddTest;

["CmdrAction.getFinalScore", {
	private _obj = NEW("CmdrAction", []);
	CALLM(_obj, "getFinalScore", []) == 1
}] call test_AddTest;

["CmdrAction.applyToSim", {
	private _world = NEW("WorldModel", [true]);
	private _garrison = NEW("GarrisonModel", [_world]);
	private _ast = NEW("AST_KillGarrison", [GETV(_garrison, "id")]);
	private _asts = [_ast];
	private _obj = NEW("CmdrAction", []);
	SETV(_obj, "transitions", _asts);
	["Transitions correct", GETV(_obj, "transitions") isEqualTo _asts] call test_Assert;
	CALLM(_obj, "applyToSim", [_world]);
	["applyToSim applied state to sim correctly", CALLM(_garrison, "isDead", [])] call test_Assert;
}] call test_AddTest;

#endif