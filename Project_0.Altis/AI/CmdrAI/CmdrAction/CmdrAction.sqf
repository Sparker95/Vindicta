
#include "..\..\..\OOP_Light\OOP_Light.h"

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
		T_SETV("complete", false);
		T_SETV("state", CMDR_ACTION_STATE_START);
		T_SETV("transitions", []);
	} ENDMETHOD;

	METHOD("updateScore") {
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
		while {_state != CMDR_ACTION_STATE_END} do {
			private _newState = CALLMS("ActionStateTransition", "selectAndApply", [_world]+[_state]+[_transitions]);
			if(_newState == _state) then {
				OOP_ERROR_2("Couldn't apply action %1 to sim, stuck in state %2", _thisObject, _state);
			};
		};
	} ENDMETHOD;

	METHOD("update") {
		params [P_THISOBJECT, P_STRING("_world")];
		T_PRVAR(state);
		T_PRVAR(transitions);
		private _newState = CALLMS("ActionStateTransition", "selectAndApply", [_world]+[_state]+[_transitions]);
		if(_newState != _state) then {
			T_SETV("_state", _newState);
		};
	} ENDMETHOD;

	METHOD("getLabel") {
		params [P_THISOBJECT];
		""
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
