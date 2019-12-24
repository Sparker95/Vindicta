#include "common.hpp"

/*
Location will be created at the specified place.
Construction resources will be removed from garrison.
Position of the garrison is irrelevant.

Parent: <ActionStateTransition>
*/

CLASS("AST_GarrisonConstructLocation", "ActionStateTransition")

	// Inputs
	VARIABLE_ATTR("garrIdVar", [ATTR_PRIVATE]);
	VARIABLE_ATTR("locPos", [ATTR_PRIVATE]);
	VARIABLE_ATTR("locType", [ATTR_PRIVATE]);

	/*
			P_OOP_OBJECT("_action"), - action
			P_ARRAY("_fromStates"), - array of states this is valid from
			P_AST_STATE("_successState"), - state to go to when this is successful
			P_AST_STATE("_failGarrisonDead"), - state to go to when garrison is dead
			P_AST_VAR("_garrIdVar"), - <AST_VAR> <Model.GarrisonModel> Id of the garrison performing the action
			P_POSITION("_locPos"), - Array [x, y, z] with the position where the location will be created
			P_DYNAMIC("_locType"), - Type of the location to create
			P_NUMBER("_buildRes") - Amount of build resources to remove from the garrison when the AST is complete
	*/

	METHOD("new") {
		params [P_THISOBJECT, 
			P_OOP_OBJECT("_action"),
			P_ARRAY("_fromStates"),
			P_AST_STATE("_successState"),
			P_AST_STATE("_failGarrisonDead"),
			P_AST_VAR("_garrIdVar"),
			P_POSITION("_locPos"),
			P_DYNAMIC("_locType"),
			P_NUMBER("_buildRes")
		];
		
		T_SETV("fromStates", _fromStates);
		T_SETV("successState", _successState);
		T_SETV("failGarrisonDead", _failGarrisonDead);
		T_SETV("garrIdVar", _garrIdVar);
		T_SETV("locPos", _locPos);
		T_SETV("locType", _locType);
		T_SETV("buildRes", _buildRes);
	} ENDMETHOD;

ENDCLASS;