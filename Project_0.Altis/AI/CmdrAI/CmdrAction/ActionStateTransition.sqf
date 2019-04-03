
#include "..\..\..\OOP_Light\OOP_Light.h"

CLASS("ActionStateTransition", "")

	// If more than one Action Transition is available then 
	// priority is used to decide which one to perform.
	VARIABLE("priority");
	// State(s) this transition is valid from
	VARIABLE("fromStates");
	// State this transition results in
	VARIABLE("toState");
	// We have separate state requirements for executing on sim so a transition
	// function can perform operations in a more efficient manner, e.g. skipping multiple
	// steps, or being valid from more states.
	// State(s) this transition is valid from when executing on sim
	VARIABLE("fromStatesSim");
	// State this transition results in on sim
	VARIABLE("toStateSim");
	/*
	Parameters: 
	*/
	METHOD("new") {
		params [P_THISOBJECT];
		T_SETV("priority", CMDR_ACTION_PRIOR_LOW);
		T_SETV("fromStates", []);
		T_SETV("toState", CMDR_ACTION_STATE_END);
		T_SETV("fromStatesSim", []);
		T_SETV("toStateSim", CMDR_ACTION_STATE_END);
	} ENDMETHOD;

	METHOD("isValidFromState") {
		params [P_THISOBJECT, P_NUMBER("_state"), P_BOOL("_isSim")];
		if(_isSim) exitWith { _state in T_GETV("fromStatesSim") };
		_state in T_GETV("fromStates")
	} ENDMETHOD;

	METHOD("getToState") {
		params [P_THISOBJECT, P_BOOL("_isSim")];
		if(_isSim) exitWith { T_GETV("toStateSim") };
		T_GETV("toState")
	} ENDMETHOD;

	STATIC_METHOD("selectAndApply") {
		params [P_THISCLASS, P_STRING("_world"), P_NUMBER("_state"), P_ARRAY("_transitions")];
		private _isSim = GETV(_world, "isSim");

		// For efficiency we will first filter to transitions whose fromStates include
		// our current state, then sort by priority. Then we will check in decending
		// order until we find one we can apply and attempt to apply it.
		private _matchingTransitions = _transitions 
			select { CALLM(_x, "isValidFromState", [_state]+[_isSim]) }
			apply { [GETV(_x, "priority"), _x] };

		// Lower value is higher priority (0 is top most priority)
		_matchingTransitions sort true;
		private _foundIdx = _matchingTransitions findIf { CALLM(_x, "isAvailable", [_world]) };
		if(_foundIdx != -1) then {
			private _selectedTransition = _matchingTransitions#_foundIdx;
			private _applied = CALLM(_selectedTransition, "apply", [_world]);
			if(_applied) exitWith {
				private _newState = CALLM(_selectedTransition, "getToState", [_isSim]);
				_newState
			};
		};
		_state
	} ENDMETHOD;
	
	// ----------------------------------+----------------------------------
	// |                 V I R T U A L   F U N C T I O N S                 |
	// ----------------------------------+----------------------------------
	/*
	Method: isAvailable
	    Implement in derived classes to check prerequisites for this state transition.
	Return: true if prerequisites for this transition are met.
	*/
	/* virtual */ METHOD("isAvailable") { 
		params [P_THISOBJECT, P_STRING("_world")];
		
	} ENDMETHOD;

	// /*
	// Method: isAvailableSim
	//     Implement in derived classes to check prerequisites for this state transition in sim world.
	// Return: true if prerequisites for this transition are met.
	// */
	// /* virtual */ METHOD("isAvailableSim") { 
	// 	params [P_THISOBJECT, P_STRING("_simWorld")];
		
	// } ENDMETHOD;
	
	/*
	Method: apply
	    Implement in derived classes to attempt to apply the state transition.
	Return: true if the transition was applied successfully.
	*/
	/* virtual */ METHOD("apply") { 
		params [P_THISOBJECT, P_STRING("_world")];
		// Always apply successfully by default
		true 
	} ENDMETHOD;
	
	// /*
	// Method: applySim
	//     Implement in derived classes to attempt to apply the state transition to sim world.
	// Return: true if the transition was applied successfully.
	// */
	// /* virtual */ METHOD("applySim") { 
	// 	params [P_THISOBJECT, P_STRING("_simWorld")];
	// 	// Always apply successfully by default
	// 	true 
	// } ENDMETHOD;
ENDCLASS;