#include "common.hpp"

/*
Class: AI.CmdrAI.CmdrAction.ASTs.AST_ArrayPopFront
Pop a value from the front of an array into another variable.
For example to select the next patrol waypoint in an array of positions.

Parent: <ActionStateTransition>
*/
#define OOP_CLASS_NAME AST_ArrayPopFront
CLASS("AST_ArrayPopFront", "ActionStateTransition")
	VARIABLE_ATTR("notEmptyState", [ATTR_PRIVATE ARG ATTR_SAVE]);
	VARIABLE_ATTR("emptyBeforeState", [ATTR_PRIVATE ARG ATTR_SAVE]);
	VARIABLE_ATTR("emptyAfterState", [ATTR_PRIVATE ARG ATTR_SAVE]);
	VARIABLE_ATTR("arrayVar", [ATTR_PRIVATE ARG ATTR_SAVE]);
	VARIABLE_ATTR("resultVar", [ATTR_PRIVATE ARG ATTR_SAVE]);

	/*
	Method: new

	Create an AST to pop a value from the front of an array into a variable.
	
	Parameters:
		_fromStates - Array of <CMDR_ACTION_STATE>, states this AST is valid from
		_notEmptyState - <CMDR_ACTION_STATE>, state to return when array is not empty after pop
		_emptyBeforeState - <CMDR_ACTION_STATE>, state to return when array is empty before pop
		_emptyAfterState - <CMDR_ACTION_STATE>, state to return when array is empty after pop
		_arrayVar - IN <AST_VAR>(Array of Any), array to pop front off of
		_resultVar - OUT <AST_VAR>(Any), element that was popped from the array
	*/
	METHOD(new)
		params [P_THISOBJECT, 
			P_OOP_OBJECT("_action"),
			P_ARRAY("_fromStates"),
			P_AST_STATE("_notEmptyState"),
			P_AST_STATE("_emptyBeforeState"),
			P_AST_STATE("_emptyAfterState"),
			P_AST_VAR("_arrayVar"),
			P_AST_VAR("_resultVar")
		];
		T_SETV("fromStates", _fromStates);
		T_SETV("notEmptyState", _notEmptyState);
		T_SETV("emptyBeforeState", _emptyBeforeState);
		T_SETV("emptyAfterState", _emptyAfterState);
		T_SETV("arrayVar", _arrayVar);
		T_SETV("resultVar", _resultVar);
	ENDMETHOD;

	public override METHOD(apply)
		params [P_THISOBJECT, P_OOP_OBJECT("_world") ];

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
	ENDMETHOD;
ENDCLASS;

#ifdef _SQF_VM

["AST_ArrayPopFront.new", {
	SCOPE_IGNORE_ACCESS(CmdrAction);
	private _action = NEW("CmdrAction", []);
	private _args = [_action ARG [0] ARG 1 ARG 2 ARG 3 ARG CALLM1(_action, "createVariable", [])];
	private _ast = NEW("AST_ArrayPopFront", _args);
	
	private _class = OBJECT_PARENT_CLASS_STR(_ast);
	["Object exists", !(isNil "_class")] call test_Assert;
}] call test_AddTest;

["AST_ArrayPopFront.apply", {
	SCOPE_IGNORE_ACCESS(CmdrAction);
	private _array = [0, 1];
	private _action = NEW("CmdrAction", []);
	private _arrayVar = CALLM1(_action, "createVariable", _array);
	private _resultVar = CALLM1(_action, "createVariable", -1);
	private _ast = NEW("AST_ArrayPopFront", [_action ARG [0] ARG 1 ARG 2 ARG 3 ARG _arrayVar ARG _resultVar]);
	private _world = NEW("WorldModel", [WORLD_TYPE_REAL]);
	private _notEmptyState = CALLM(_ast, "apply", [_world]);
	["Not empty state", _notEmptyState == 1] call test_Assert;
	private _array = GET_AST_VAR(_action, _arrayVar);
	["Not empty state array", _array isEqualTo [1]] call test_Assert;
	["Not empty state result", GET_AST_VAR(_action, _resultVar) isEqualTo 0] call test_Assert;
	private _emptyAfterState = CALLM(_ast, "apply", [_world]);
	["Empty after state", _emptyAfterState == 3] call test_Assert;
	private _array = GET_AST_VAR(_action, _arrayVar);
	["Empty after state array", _array isEqualTo []] call test_Assert;
	["Empty after state result", GET_AST_VAR(_action, _resultVar) isEqualTo 1] call test_Assert;
	private _emptyBeforeState = CALLM(_ast, "apply", [_world]);
	["Empty before state", _emptyBeforeState == 2] call test_Assert;
	private _array = GET_AST_VAR(_action, _arrayVar);
	["Empty before state array", _array isEqualTo []] call test_Assert;
	["Empty before state result", GET_AST_VAR(_action, _resultVar) isEqualTo 1] call test_Assert;
}] call test_AddTest;

#endif