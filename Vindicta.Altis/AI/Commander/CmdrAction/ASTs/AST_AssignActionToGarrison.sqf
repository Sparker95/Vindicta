#include "common.hpp"

/*
Class: AI.CmdrAI.CmdrAction.ASTs.AST_AssignActionToGarrison
Assigns a <CmdrAction> instance to a <Model.GarrisonModel>.
Example: 
	Detachment <GarrisonModel>s performing an action have the action assigned to 
them with this AST. It indicates to <CmdrAction> generators that the <Model.GarrisonModel> is currently
doing something else.

Parent: <ActionStateTransition>
*/
#define OOP_CLASS_NAME AST_AssignActionToGarrison
CLASS("AST_AssignActionToGarrison", "ActionStateTransition");
	VARIABLE_ATTR("successState", [ATTR_PRIVATE ARG ATTR_SAVE]);

	// Inputs
	VARIABLE_ATTR("garrIdVar", [ATTR_PRIVATE ARG ATTR_SAVE]);

	/*
	Method: new
	Create an AST to assign a <CmdrAction> instance to a <Model.GarrisonModel>.
	
	Parameters:
		_action - <CmdrAction>, action to assign
		_fromStates - Array of <CMDR_ACTION_STATE>, states this AST is valid from
		_successState - <CMDR_ACTION_STATE>, state to return after success
		_garrIdVar - IN <AST_VAR>(Number), Id of the <Model.GarrisonModel> to assign the action to
	*/
	METHOD(new)
		params [P_THISOBJECT, 
			P_OOP_OBJECT("_action"),
			P_ARRAY("_fromStates"),
			P_AST_STATE("_successState"),
			P_AST_VAR("_garrIdVar")
		];
		T_SETV("fromStates", _fromStates);
		T_SETV("successState", _successState);
		T_SETV("garrIdVar", _garrIdVar);
	ENDMETHOD;

	/* override */ METHOD(apply)
		params [P_THISOBJECT, P_STRING("_world")];
		ASSERT_OBJECT_CLASS(_world, "WorldModel");
		private _garr = CALLM(_world, "getGarrison", [T_GET_AST_VAR("garrIdVar")]);
		ASSERT_OBJECT(_garr);
		private _action = T_GETV("action");
		CALLM(_garr, "setAction", [_action]);

		// Give personal intel to garrison
		CALLM(_action, "setPersonalGarrisonIntel", [_garr]);
		T_GETV("successState")

	ENDMETHOD;
ENDCLASS;

#ifdef _SQF_VM

["AST_AssignActionToGarrison.new", {
	private _action = NEW("CmdrAction", []);
	private _thisObject = NEW("AST_AssignActionToGarrison", 
		[_action]+
		[[CMDR_ACTION_STATE_START]]+
		[CMDR_ACTION_STATE_END]+
		[CALLM1(_action, "createVariable", 0)]
	);
	
	private _class = OBJECT_PARENT_CLASS_STR(_thisObject);
	["Object exists", !(isNil "_class")] call test_Assert;
	//["Initial state is correct", T_GETV("state") == CMDR_ACTION_STATE_START] call test_Assert;
}] call test_AddTest;

["AST_AssignActionToGarrison.apply", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _garrison = NEW("GarrisonModel", [_world ARG "<undefined>"]);
	private _action = NEW("CmdrAction", []);
	private _IDASTVar = CALLM1(_action, "createVariable", GETV(_garrison, "id"));
	//diag_log format ["ID AST VAR: %1", _IDASTVar];
	private _thisObject = NEW("AST_AssignActionToGarrison", 
		[_action]+
		[[CMDR_ACTION_STATE_START]]+
		[CMDR_ACTION_STATE_END]+
		[_IDASTVar]
	);

	private _endState = T_CALLM("apply", [_world]);
	["State after apply is correct", _endState == CMDR_ACTION_STATE_END] call test_Assert;
	["Action was applied correctly", CALLM0(_garrison, "getAction") isEqualTo _action] call test_Assert;
}] call test_AddTest;


#endif