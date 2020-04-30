#include "common.hpp"

/*
Class: AI.CmdrAI.CmdrAction.ASTs.AST_Nothing
AST that does nothing but immediately succeed, used as placeholder, or replacement for optional AST nodes

Parent: <ActionStateTransition>
*/
#define OOP_CLASS_NAME AST_Success
CLASS("AST_Success", "ActionStateTransition")
	VARIABLE_ATTR("successState", [ATTR_PRIVATE ARG ATTR_SAVE]);

	/*
	Method: new
	Create an AST that succeeds immediately
	
	Parameters:
		_action - Action this AST instance belongs to, for debugging
		_fromStates - Array of <CMDR_ACTION_STATE>, states this AST is valid from
		_successState - <CMDR_ACTION_STATE>, state to return after success, which happens immediately
	*/
	METHOD(new)
		params [P_THISOBJECT, 
			P_OOP_OBJECT("_action"),
			P_ARRAY("_fromStates"),
			P_AST_STATE("_successState")
		];
		
		T_SETV("fromStates", _fromStates);
		T_SETV("successState", _successState);
	ENDMETHOD;

	/* override */ METHOD(apply)
		params [P_THISOBJECT];
		T_GETV("successState")
	ENDMETHOD;
ENDCLASS;
