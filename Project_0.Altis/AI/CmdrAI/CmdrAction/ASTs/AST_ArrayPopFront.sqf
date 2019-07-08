#include "..\..\common.hpp"

/*
Class: AST_ArrayPopFront
Pop a value from the front of an array into another variable.
*/
CLASS("AST_ArrayPopFront", "ActionStateTransition")
	VARIABLE_ATTR("notEmptyState", [ATTR_PRIVATE]);
	VARIABLE_ATTR("emptyBeforeState", [ATTR_PRIVATE]);
	VARIABLE_ATTR("emptyAfterState", [ATTR_PRIVATE]);
	VARIABLE_ATTR("arrayVar", [ATTR_PRIVATE]);
	VARIABLE_ATTR("resultVar", [ATTR_PRIVATE]);

	/*
	Method: new
	Create a ActionStateTransition to pop a value from the front of an array into a variable.
	
	Parameters: _fromStates, _notEmptyState, _emptyBeforeState, _emptyAfterState, _arrayVar, _resultVar
	
	_fromStates - Array<CMDR_ACTION_STATE*>, states it is valid from
	_notEmptyState - CMDR_ACTION_STATE*, state when array is not empty after pop
	_emptyBeforeState - CMDR_ACTION_STATE*, state when array is empty before pop
	_emptyAfterState - CMDR_ACTION_STATE*, state when array is empty after pop
	_arrayVar - AST_VAR(Array<Any>), array to pop front on
	_resultVar - AST_VAR(Any), element that was popped
	*/
	METHOD("new") {
		params [P_THISOBJECT, 
			P_ARRAY("_fromStates"),				// states it is valid from
			P_AST_STATE("_notEmptyState"),		// state when array is not empty after
			P_AST_STATE("_emptyBeforeState"),	// state when array is empty before pop
			P_AST_STATE("_emptyAfterState"),	// state when array is empty after
			// input
			P_AST_VAR("_arrayVar"),				// array to pop front on
			// output
			P_AST_VAR("_resultVar")				// element that was popped
		];
		T_SETV("fromStates", _fromStates);
		T_SETV("notEmptyState", _notEmptyState);
		T_SETV("emptyBeforeState", _emptyBeforeState);
		T_SETV("emptyAfterState", _emptyAfterState);
		T_SETV("arrayVar", _arrayVar);
		T_SETV("resultVar", _resultVar);
	} ENDMETHOD;

	/* override */ METHOD("apply") {
		params [P_THISOBJECT, P_OOP_OBJECT("_world") ];

		// if(GETV(_world, "type") != WORLD_TYPE_REAL) exitWith { CMDR_ACTION_STATE_NONE };

		private _array = +T_GET_AST_VAR("arrayVar");
		ASSERT_MSG(_array isEqualType [], "AST_ArrayPopFront only works with arrays");

		// Array is empty before pop
		if(count _array == 0) exitWith { T_GETV("emptyBeforeState") };

		// Pop the value
		private _result = _array deleteAt 0;
		T_SET_AST_VAR("resultVar", _result);
		T_SET_AST_VAR("arrayVar", _array);

		OOP_INFO_MSG("%1 %2 %3", [_world ARG _array ARG _result]);
		
		// Array is empty after pop
		if(count _array == 0) exitWith { T_GETV("emptyAfterState") };

		T_GETV("notEmptyState");
	} ENDMETHOD;
ENDCLASS;

#ifdef _SQF_VM

["AST_ArrayPopFront.new", {
	private _ast = NEW("AST_ArrayPopFront", [[0] ARG 1 ARG 2 ARG 3 ARG MAKE_AST_VAR([])]);
	
	private _class = OBJECT_PARENT_CLASS_STR(_ast);
	["Object exists", !(isNil "_class")] call test_Assert;
}] call test_AddTest;

["AST_ArrayPopFront.apply", {
	private _array = [0, 1];
	private _arrayVar = MAKE_AST_VAR(_array);
	private _resultVar = MAKE_AST_VAR(-1);
	private _ast = NEW("AST_ArrayPopFront", [[0] ARG 1 ARG 2 ARG 3 ARG _arrayVar ARG _resultVar]);
	private _world = NEW("WorldModel", [WORLD_TYPE_REAL]);
	private _notEmptyState = CALLM(_ast, "apply", [_world]);
	["Not empty state", _notEmptyState == 1] call test_Assert;
	private _array = GET_AST_VAR(_arrayVar);
	["Not empty state array", _array isEqualTo [1]] call test_Assert;
	["Not empty state result", GET_AST_VAR(_resultVar) isEqualTo 0] call test_Assert;
	private _emptyAfterState = CALLM(_ast, "apply", [_world]);
	["Empty after state", _emptyAfterState == 3] call test_Assert;
	private _array = GET_AST_VAR(_arrayVar);
	["Empty after state array", _array isEqualTo []] call test_Assert;
	["Empty after state result", GET_AST_VAR(_resultVar) isEqualTo 1] call test_Assert;
	private _emptyBeforeState = CALLM(_ast, "apply", [_world]);
	["Empty before state", _emptyBeforeState == 2] call test_Assert;
	private _array = GET_AST_VAR(_arrayVar);
	["Empty before state array", _array isEqualTo []] call test_Assert;
	["Empty before state result", GET_AST_VAR(_resultVar) isEqualTo 1] call test_Assert;
}] call test_AddTest;

#endif