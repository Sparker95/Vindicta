//#include "..\..\..\OOP_Light\OOP_Light.h"
#include "..\common.hpp"

CLASS("ActionStateTransition", "")

	// If more than one Action Transition is available then 
	// priority is used to decide which one to perform.
	VARIABLE("priority");
	// State(s) this transition is valid from
	VARIABLE("fromStates");
	// State this transition results in
	VARIABLE("toState");

	/*
	Parameters: 
	*/
	METHOD("new") {
		params [P_THISOBJECT];
		T_SETV("priority", CMDR_ACTION_PRIOR_LOW);
		T_SETV("fromStates", []);
		T_SETV("toState", CMDR_ACTION_STATE_END);
	} ENDMETHOD;

	METHOD("isValidFromState") {
		params [P_THISOBJECT, P_NUMBER("_state")];
		private _states = T_GETV("fromStates");
		(_state in _states) or (CMDR_ACTION_STATE_ALL in _states)
	} ENDMETHOD;

	STATIC_METHOD("selectAndApply") {
		params [P_THISCLASS, P_STRING("_world"), P_NUMBER("_state"), P_ARRAY("_transitions")];

		if(_state == CMDR_ACTION_STATE_END) exitWith { _state };

		// For efficiency we will first filter to transitions whose fromStates include
		// our current state, then sort by priority. Then we will check in decending
		// order until we find one we can apply and attempt to apply it.
		private _matchingTransitions = _transitions 
			select { CALLM(_x, "isValidFromState", [_state]) }
			apply { [GETV(_x, "priority"), _x] };

		// Lower value is higher priority (0 is top most priority)
		_matchingTransitions sort ASCENDING;

		private _foundIdx = _matchingTransitions findIf { CALLM(_x select 1, "isAvailable", [_world]) };
		if(_foundIdx != -1) then {
			private _selectedTransition = _matchingTransitions#_foundIdx#1;
			private _applied = CALLM(_selectedTransition, "apply", [_world]);
			if(_applied) then {
				private _newState = GETV(_selectedTransition, "toState");
				_state = _newState
			};
		} else {
			// If we can't apply any transitions then go directly to END
			// TODO: can we do something better than terminate?
			_state = CMDR_ACTION_STATE_END;
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
		true
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
		FAILURE("apply method must be implemented when deriving from ActionStateTransition");
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

// Unit test
#ifdef _SQF_VM

AST_test = NEW("ActionStateTransition", []);

#define CMDR_ACTION_STATE_TEST_1 2
#define CMDR_ACTION_STATE_TEST_2 3

// Dummy test classes
CLASS("TestASTBase", "ActionStateTransition")
	METHOD("new") {
		params [P_THISOBJECT];
	} ENDMETHOD;

	/* virtual */ METHOD("isAvailable") { 
		params [P_THISOBJECT, P_STRING("_world")];
		true
	} ENDMETHOD;

	/* virtual */ METHOD("apply") { 
		params [P_THISOBJECT, P_STRING("_world")];
		true
	} ENDMETHOD;
ENDCLASS;

CLASS("TestAST_Start_1", "TestASTBase")
	METHOD("new") {
		params [P_THISOBJECT];
		T_SETV("fromStates", [CMDR_ACTION_STATE_START]);
		T_SETV("toState", CMDR_ACTION_STATE_TEST_1);
	} ENDMETHOD;
ENDCLASS;

TestAST_Start_1 = NEW("TestAST_Start_1", []);

CLASS("TestAST_1_2", "TestASTBase")
	METHOD("new") {
		params [P_THISOBJECT];
		T_SETV("fromStates", [CMDR_ACTION_STATE_TEST_1]);
		T_SETV("toState", CMDR_ACTION_STATE_TEST_2);
	} ENDMETHOD;
ENDCLASS;
TestAST_1_2 = NEW("TestAST_1_2", []);

CLASS("TestAST_2_End", "TestASTBase")
	METHOD("new") {
		params [P_THISOBJECT];
		T_SETV("fromStates", [CMDR_ACTION_STATE_TEST_2]);
		T_SETV("toState", CMDR_ACTION_STATE_END);
	} ENDMETHOD;
ENDCLASS;
TestAST_2_End = NEW("TestAST_2_End", []);

CLASS("TestAST_1_End", "TestASTBase")
	METHOD("new") {
		params [P_THISOBJECT];
		T_SETV("priority", CMDR_ACTION_PRIOR_HIGH);
		T_SETV("fromStates", [CMDR_ACTION_STATE_TEST_1]);
		T_SETV("toState", CMDR_ACTION_STATE_END);
	} ENDMETHOD;
ENDCLASS;
TestAST_1_End = NEW("TestAST_1_End", []);

["ActionStateTransition.new", {
	private _obj = NEW("ActionStateTransition", [true]);
	private _class = OBJECT_PARENT_CLASS_STR(_obj);
	["Object exists", !(isNil "_class")] call test_Assert;
	["Priority is correct", GETV(_obj, "priority") == CMDR_ACTION_PRIOR_LOW] call test_Assert;
}] call test_AddTest;

["ActionStateTransition.delete", {
	private _obj = NEW("ActionStateTransition", [true]);
	DELETE(_obj);
	isNil { OBJECT_PARENT_CLASS_STR(_obj) }
}] call test_AddTest;

fn_Test_Transitions = {
	params ["_transitions", "_expectedStates", "_world"];	
	private _state = CMDR_ACTION_STATE_START;
	{
		_x params ["_desc", "_expected"];
		_state = CALLSM("ActionStateTransition", "selectAndApply", [_world]+[_state]+[_transitions]);
		[_desc, _state == _expected] call test_Assert;
	} forEach _expectedStates;
};

["ActionStateTransition.selectAndApply", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	[ 
		[ TestAST_Start_1, TestAST_1_2, TestAST_2_End ],
		[
			["Start -> 1", CMDR_ACTION_STATE_TEST_1],
			["1 -> 2", CMDR_ACTION_STATE_TEST_2],
			["2 -> End", CMDR_ACTION_STATE_END]
		],
		_world
	] call fn_Test_Transitions;
	[ 
		[ TestAST_Start_1, TestAST_1_2, TestAST_2_End, TestAST_1_End ],
		[
			["Start -> 1", CMDR_ACTION_STATE_TEST_1],
			["1 -> End", CMDR_ACTION_STATE_END]
		],
		_world
	] call fn_Test_Transitions;
}] call test_AddTest;


#endif
