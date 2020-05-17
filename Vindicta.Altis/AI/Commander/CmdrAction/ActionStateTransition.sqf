#include "..\common.hpp"

/*
Class: AI.CmdrAI.CmdrAction.ASTs.ActionStateTransition
Base class for ASTs.

An AST (Action State Transition) defines an operation to be performed when transitioning from
one <CmdrAction> state to another, as well as what states it can transition from and to.

ASTs form the bulk of the behaviour of <CmdrActions> implementations.

fromStates defines what states the AST instance is valid from. All the from and to states in 
ASTs should be passed in a constructor parameters, as the <CmdrAction> that owns them defines 
what states it wants to use. Often they will be from a common set, or the same between actions
but not always. e.g. An AST that performs a move operation might transition to a READY_TO_ATTACK
state in a <CmdrAction> that is implementing an attack, but to DONE in a <CmdrAction> that is just 
implementing a move.

This operation can be parameterized using fixed values and/or <AST_VARs>.
An <AST_VAR> is a reference to a variable that can be shared between multiple ASTs. 
When one AST modifies the value the <AST_VAR> refers to, that modification is also visible to 
other ASTs.
See CmdrActionStates.hpp for the <AST_VAR> macros.

The apply function is where the behaviour of the AST should be implemented. It should attempt to 
perform the action required, and then return the new state, or <CMDR_ACTION_STATE_NONE> if no
state change should occur. For ASTs whose behaviour cannot occur instantly (e.g. moving a 
garrison to another location), the apply function should return <CMDR_ACTION_STATE_NONE> while the 
behaviour is ongoing, then an appropriate state once it is complete (or failed). See 
<AST_GarrisonAttackTarget> for an example of this. The <CmdrAction> will stay in the same state
after calling an AST apply function if that function does returns <CMDR_ACTION_STATE_NONE>.
*/
#define OOP_CLASS_NAME ActionStateTransition
CLASS("ActionStateTransition", "Storable")

	// If more than one Action Transition is available then 
	// priority is used to decide which one to perform.
	VARIABLE_ATTR("priority", [ATTR_SAVE]);
	// State(s) this transition is valid from
	VARIABLE_ATTR("fromStates", [ATTR_SAVE]);
	// CmdrAction to which this AST belongs
	VARIABLE_ATTR("action", [ATTR_SAVE]);

	/*
	Method: new
	Base constructor for ASTs. See implementing classes (AST_*) for concrete constuctor definitions.
	*/
	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_action")];
		ASSERT_OBJECT_CLASS(_action, "CmdrAction");
		T_SETV("action", _action);
		T_SETV("priority", CMDR_ACTION_PRIOR_LOW);
		T_SETV("fromStates", []);
	ENDMETHOD;

	/*
	Method: isValidFromState
	Returns true if this AST can apply a transition from _state. 
	i.e. if fromStates contains _state.
	
	Parameters:
		_state - <CMDR_ACTION_STATE>, The state to test against
	
	Returns: Boolean, true if this AST can apply a transition from _state
	*/
	METHOD(isValidFromState)
		params [P_THISOBJECT, P_NUMBER("_state")];
		private _states = T_GETV("fromStates");
		(_state in _states) or (CMDR_ACTION_STATE_ALL in _states)
	ENDMETHOD;

	/*
	Method: (static) selectAndApply
	
	Parameters:
		_world - <Model.WorldModel>, the world we want to apply state transition behaviours in, could be 
		REAL or SIM.
		_state - <CMDR_ACTION_STATE>, the Current state from which we want to attempt transition.
		_transitions - Array of <ActionStateTransition>, possible transitions we can select from.
	
	Returns: <CMDR_ACTION_STATE>, new state (might not have changed)
	*/
	STATIC_METHOD(selectAndApply)
		params [P_THISCLASS, P_OOP_OBJECT("_world"), P_NUMBER("_state"), P_ARRAY("_transitions")];

		if(_state == CMDR_ACTION_STATE_END) exitWith { _state };

		// For efficiency we will first filter to transitions whose fromStates include
		// our current state, then sort by priority. Then we will check in decending
		// order until we find one we can apply and attempt to apply it.
		private _matchingTransitions = _transitions 
			select { CALLM(_x, "isValidFromState", [_state]) }
			apply { [GETV(_x, "priority"), _x] };

		// Lower value is higher priority (0 is top most priority)
		_matchingTransitions sort ASCENDING;

		// Check the transitions are available in case they have implemented the isAvailable function
		private _foundIdx = _matchingTransitions findIf { CALLM(_x select 1, "isAvailable", [_world]) };
		if(_foundIdx != NOT_FOUND) then {
			// Get the transition we selected
			private _selectedTransition = _matchingTransitions#_foundIdx#1;
			private _newState = CALLM(_selectedTransition, "apply", [_world]);
			ASSERT_MSG(_newState isEqualType 0, "ActionStateTransition apply should return a new state value, or CMDR_ACTION_STATE_NONE if unchanged");
			// If new state is set then apply it
			if(_newState != CMDR_ACTION_STATE_NONE) then {
				_state = _newState
			};
		} else {
			// If we can't apply any transitions then go directly to END
			// TODO: can we do something better than terminate?
			_state = CMDR_ACTION_STATE_END;
		};
		_state
	ENDMETHOD;

	/*
	Method: (static) selectTransition
	
	Parameters:
		_world - <Model.WorldModel>, the world we want to apply state transition behaviours in, could be 
		REAL or SIM.
		_state - <CMDR_ACTION_STATE>, the Current state from which we want to attempt transition.
		_transitions - Array of <ActionStateTransition>, possible transitions we can select from.
	
	Returns: a transition which can be run from the current _state, or NULL_OBJECT
	*/

	STATIC_METHOD(selectTransition)
		params [P_THISCLASS, P_OOP_OBJECT("_world"), P_NUMBER("_state"), P_ARRAY("_transitions")];

		if(_state == CMDR_ACTION_STATE_END) exitWith { NULL_OBJECT };

		// For efficiency we will first filter to transitions whose fromStates include
		// our current state, then sort by priority. Then we will check in decending
		// order until we find one we can apply and attempt to apply it.
		private _matchingTransitions = _transitions 
			select { CALLM(_x, "isValidFromState", [_state]) }
			apply { [GETV(_x, "priority"), _x] };

		// Lower value is higher priority (0 is top most priority)
		_matchingTransitions sort ASCENDING;

		// Check the transitions are available in case they have implemented the isAvailable function
		private _foundIdx = _matchingTransitions findIf { CALLM(_x select 1, "isAvailable", [_world]) };
		if(_foundIdx != NOT_FOUND) then {
			// Get the transition we selected
			_matchingTransitions#_foundIdx#1;
		} else {
			NULL_OBJECT
		};
	ENDMETHOD;

	// ----------------------------------+----------------------------------
	// |                 V I R T U A L   F U N C T I O N S                 |
	// ----------------------------------+----------------------------------
	/*
	Method: (virtual) isAvailable
	Implement in derived classes to check custom prerequisites for this AST.
	
	Parameters:
		_world - <Model.WorldModel>, the world model we are currently applying ASTs to.

	Returns: Boolean, if the AST is allowed to be applied now, defaults to true
	*/
	/* virtual */ METHOD(isAvailable) 
		params [P_THISOBJECT, P_OOP_OBJECT("_world")];
		true
	ENDMETHOD;

	
	/*
	Method: (abstract virtual) apply
	Implement in derived classes to attempt to apply the state transition.
	
	Parameters:
		_world - <Model.WorldModel>, the world model we are currently applying ASTs to.
	
	Return: <CMDR_ACTION_STATE>, the new state, or <CMDR_ACTION_STATE_NONE> to stay in the 
	current state (can be used for transitions that take time).
	*/
	/* virtual */ METHOD(apply) 
		params [P_THISOBJECT, P_OOP_OBJECT("_world")];
		FAILURE("apply method must be implemented when deriving from ActionStateTransition");
	ENDMETHOD;

	/*
	Method: (abstract virtual) cancel
	Implement in derived classes to cancel this action state transition while it is in progress.
	
	Parameters:
		_world - <Model.WorldModel>, the world model we are currently applying ASTs to. Must be WORLD_TYPE_REAL.
	
	Return: <CMDR_ACTION_STATE>, the new state, or <CMDR_ACTION_STATE_NONE> to stay in the 
	current state (can be used for transitions that take time).
	*/
	/* virtual */ METHOD(cancel)
		params [P_THISOBJECT, P_OOP_OBJECT("_world")];
	ENDMETHOD;

ENDCLASS;

// Unit test
#ifdef _SQF_VM

#define CMDR_ACTION_STATE_TEST_1 2
#define CMDR_ACTION_STATE_TEST_2 3

["AST Dummy test classes", {
	CmdrAction_test = NEW("CmdrAction", []);
	AST_test = NEW("ActionStateTransition", [CmdrAction_test]);

	// Dummy test classes
	#define OOP_CLASS_NAME TestASTBase
CLASS("TestASTBase", "ActionStateTransition")
		VARIABLE("successState");

		METHOD(new)
			params [P_THISOBJECT];
			T_SETV("successState", CMDR_ACTION_STATE_END);
		ENDMETHOD;

		/* virtual */ METHOD(isAvailable) 
			params [P_THISOBJECT, P_STRING("_world")];
			true
		ENDMETHOD;

		/* virtual */ METHOD(apply) 
			params [P_THISOBJECT, P_STRING("_world")];
			T_GETV("successState")
		ENDMETHOD;
	ENDCLASS;

	#define OOP_CLASS_NAME TestAST_Start_1
CLASS("TestAST_Start_1", "TestASTBase")
		METHOD(new)
			params [P_THISOBJECT];
			T_SETV("fromStates", [CMDR_ACTION_STATE_START]);
			T_SETV("successState", CMDR_ACTION_STATE_TEST_1);
			//T_SETV("toStates", [CMDR_ACTION_STATE_TEST_1]);
		ENDMETHOD;
	ENDCLASS;

	TestAST_Start_1 = NEW("TestAST_Start_1", [CmdrAction_test]);

	#define OOP_CLASS_NAME TestAST_1_2
CLASS("TestAST_1_2", "TestASTBase")
		METHOD(new)
			params [P_THISOBJECT];
			T_SETV("fromStates", [CMDR_ACTION_STATE_TEST_1]);
			T_SETV("successState", CMDR_ACTION_STATE_TEST_2);
		ENDMETHOD;
	ENDCLASS;
	TestAST_1_2 = NEW("TestAST_1_2", [CmdrAction_test]);

	#define OOP_CLASS_NAME TestAST_2_End
CLASS("TestAST_2_End", "TestASTBase")
		METHOD(new)
			params [P_THISOBJECT];
			T_SETV("fromStates", [CMDR_ACTION_STATE_TEST_2]);
			T_SETV("successState", CMDR_ACTION_STATE_END);
		ENDMETHOD;
	ENDCLASS;
	TestAST_2_End = NEW("TestAST_2_End", [CmdrAction_test]);

	#define OOP_CLASS_NAME TestAST_1_End
CLASS("TestAST_1_End", "TestASTBase")
		METHOD(new)
			params [P_THISOBJECT];
			T_SETV("priority", CMDR_ACTION_PRIOR_HIGH);
			T_SETV("fromStates", [CMDR_ACTION_STATE_TEST_1]);
			T_SETV("successState", CMDR_ACTION_STATE_END);
		ENDMETHOD;
	ENDCLASS;
	TestAST_1_End = NEW("TestAST_1_End", [CmdrAction_test]);
}] call test_AddTest;

["ActionStateTransition.new", {
	private _obj = NEW("ActionStateTransition", [CmdrAction_test]);
	private _class = OBJECT_PARENT_CLASS_STR(_obj);
	["Object exists", !(isNil "_class")] call test_Assert;
	["Priority is correct", GETV(_obj, "priority") == CMDR_ACTION_PRIOR_LOW] call test_Assert;
}] call test_AddTest;

["ActionStateTransition.delete", {
	private _obj = NEW("ActionStateTransition", [CmdrAction_test]);
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
