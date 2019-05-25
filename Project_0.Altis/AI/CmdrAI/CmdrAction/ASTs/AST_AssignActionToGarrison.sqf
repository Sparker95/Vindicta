#include "..\..\common.hpp"

CLASS("AST_AssignActionToGarrison", "ActionStateTransition");
	VARIABLE_ATTR("action", [ATTR_PRIVATE]);
	VARIABLE_ATTR("successState", [ATTR_PRIVATE]);

	// Inputs
	VARIABLE_ATTR("garrId", [ATTR_PRIVATE]);

	METHOD("new") {
		params [P_THISOBJECT, 
			P_OOP_OBJECT("_action"),			// Action to assign to the garrison
			P_ARRAY("_fromStates"),				// States it is valid from
			P_AST_STATE("_successState"),		// State to transition do after completion
			// inputs
			P_AST_VAR("_garrId")];				// Id of the garrison to assign the action to
		ASSERT_OBJECT_CLASS(_action, "CmdrAction");
		T_SETV("action", _action);
		T_SETV("fromStates", _fromStates);
		T_SETV("successState", _successState);
		T_SETV("garrId", _garrId);
	} ENDMETHOD;

	/* override */ METHOD("apply") {
		params [P_THISOBJECT, P_STRING("_world")];
		ASSERT_OBJECT_CLASS(_world, "WorldModel");
		private _garr = CALLM(_world, "getGarrison", [T_GET_AST_VAR("garrId")]);
		ASSERT_OBJECT(_garr);
		CALLM(_garr, "setAction", [T_GETV("action")]);
		T_GETV("successState")
	} ENDMETHOD;
ENDCLASS;

#ifdef _SQF_VM

["AST_AssignActionToGarrison.new", {
	private _action = NEW("CmdrAction", []);
	private _thisObject = NEW("AST_AssignActionToGarrison", 
		[_action]+
		[[CMDR_ACTION_STATE_START]]+
		[CMDR_ACTION_STATE_END]+
		[MAKE_AST_VAR(0)]
	);
	
	private _class = OBJECT_PARENT_CLASS_STR(_thisObject);
	["Object exists", !(isNil "_class")] call test_Assert;
	//["Initial state is correct", GETV(_thisObject, "state") == CMDR_ACTION_STATE_START] call test_Assert;
}] call test_AddTest;

["AST_AssignActionToGarrison.apply", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _garrison = NEW("GarrisonModel", [_world]);
	private _action = NEW("CmdrAction", []);
	private _thisObject = NEW("AST_AssignActionToGarrison", 
		[_action]+
		[[CMDR_ACTION_STATE_START]]+
		[CMDR_ACTION_STATE_END]+
		[MAKE_AST_VAR(GETV(_garrison, "id"))]
	);

	private _endState = CALLM(_thisObject, "apply", [_world]);
	["State after apply is correct", _endState == CMDR_ACTION_STATE_END] call test_Assert;
	["Action was applied correctly", CALLM(_garrison, "getAction", []) isEqualTo _action] call test_Assert;
}] call test_AddTest;


#endif