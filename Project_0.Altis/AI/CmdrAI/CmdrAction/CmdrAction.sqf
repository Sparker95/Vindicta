#define OOP_DEBUG
#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR

#include "..\common.hpp"

// DOING:
// How to deal with this case: action requires resources, but they aren't available yet.
// 		Required resources should come from original world state? That would allow duplicate use...
// 		Actually the problem is temporality. Resouces in the future doesn't = resource now.
//		e.g. Deciding if you can reinforce FROM somewhere requires the resource now
//			 Deciding if you should reinforce TO somewhere should take into account future resources
//			 Applying reinforce action should take from src resources now, and apply to tgt in the future.
//		So sim should have now and future?
// 
// Reinforce is taking too much resource.
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
		params [P_THISOBJECT, P_STRING("_worldNow"), P_STRING("_worldFuture")];
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

		T_CALLM("pushState", []);
		// Actually this isn't right, multiple actions can happen instantly. Actions themselves should decide if they 
		// can apply based on the sim world type they are passed.
		// // For sim now world only apply the current action transition.
		// if(GETV(_world, "type") == WORLD_TYPE_SIM_NOW) then {
		// 	// Don't do anything if we are already at the end.
		// 	if(_state != CMDR_ACTION_STATE_END) then {
		// 		CALLSM("ActionStateTransition", "selectAndApply", [_world]+[_state]+[_transitions]);
		// 	};
		// } else {
		private _worldType = GETV(_world, "type");
		ASSERT_MSG(_worldType != WORLD_TYPE_REAL, "Cannot applyToSim on real world!");
		while {_state != CMDR_ACTION_STATE_END} do {
			private _newState = CALLSM("ActionStateTransition", "selectAndApply", [_world]+[_state]+[_transitions]);
			// State transitions are allowed to fail for NOW world sim (so they can limit changes to those that would happen instantly)
			ASSERT_MSG(_worldType == WORLD_TYPE_SIM_NOW or _newState != _state, format (["Couldn't apply action %1 to sim future, stuck in state %2"]+[_thisObject]+[_state]));
			if(_newState == _state) exitWith {};
			_state = _newState;
		};
		//};
		T_CALLM("popState", []);
		// We don't update any member variables here, this is just a sim.
	} ENDMETHOD;

	/* virtual */ METHOD("pushState") {
		params [P_THISOBJECT];
		
	} ENDMETHOD;
	
	/* virtual */ METHOD("popState") {
		params [P_THISOBJECT];
		
	} ENDMETHOD;

	METHOD("update") {
		params [P_THISOBJECT, P_STRING("_world")];
		
		ASSERT_MSG(GETV(_world, "type") == WORLD_TYPE_REAL, "Should only update CmdrActions on non sim world. Use applySim in sim worlds");

		T_PRVAR(state);
		T_PRVAR(transitions);
		ASSERT_MSG(count _transitions > 0, "CmdrAction hasn't got any _transitions assigned");
		
		private _oldState = CMDR_ACTION_STATE_NONE;
		// Apply states until we are blocked.
		while {_state != _oldState} do 
		{
			_oldState = _state;
			_state = CALLSM("ActionStateTransition", "selectAndApply", [_world]+[_oldState]+[_transitions]);
		};
		T_SETV("state", _state);
		
		#ifdef DEBUG_CMDRAI
		T_CALLM("debugDraw", [_world]);
		#endif
	} ENDMETHOD;

	METHOD("isComplete") {
		params [P_THISOBJECT];
		T_GETV("state") == CMDR_ACTION_STATE_END
	} ENDMETHOD;

	METHOD("getLabel") {
		params [P_THISOBJECT, P_STRING("_world")];
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
		CMDR_ACTION_STATE_END
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
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
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