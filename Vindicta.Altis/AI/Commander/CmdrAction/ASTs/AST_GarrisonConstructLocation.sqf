#include "common.hpp"

/*
Location will be created at the specified place.
Construction resources will be removed from garrison.
Position of the garrison is irrelevant.

Parent: <ActionStateTransition>
*/

#define pr private

#define OOP_CLASS_NAME AST_GarrisonConstructLocation
CLASS("AST_GarrisonConstructLocation", "ActionStateTransition")

	// Inputs
	VARIABLE_ATTR("garrIdVar", [ATTR_PRIVATE ARG ATTR_SAVE]);
	VARIABLE_ATTR("locPos", [ATTR_PRIVATE ARG ATTR_SAVE]);
	VARIABLE_ATTR("locType", [ATTR_PRIVATE ARG ATTR_SAVE]);
	VARIABLE_ATTR("buildRes", [ATTR_PRIVATE ARG ATTR_SAVE]);

	VARIABLE_ATTR("successState", [ATTR_PRIVATE ARG ATTR_SAVE]);
	VARIABLE_ATTR("failGarrisonDead", [ATTR_PRIVATE ARG ATTR_SAVE]);

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

	METHOD(new)
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
	ENDMETHOD;

	METHOD(apply)

		params [P_THISOBJECT, P_STRING("_world")];

		private _garrId = T_GET_AST_VAR("garrIdVar");

		ASSERT_MSG(_garrId isEqualType 0, "garrID must be a number");
		pr _garr = CALLM(_world, "getGarrison", [_garrId]);
		ASSERT_OBJECT(_garr);

		// If the garrison is dead then return the appropriate state
		if(CALLM0(_garr, "isDead")) exitWith {
			T_GETV("failGarrisonDead")
		};

		switch (GETV(_world, "type")) do {
			case WORLD_TYPE_SIM_NOW: {
				// Location creation doesn't happen instantly
			};

			case WORLD_TYPE_SIM_FUTURE: {
				// In the future we have a new location
				// This garrison is also attached ot the new location
				private _newLocModel = NEW("LocationModel", [_world ARG NULL_OBJECT]);
				SETV(_newLocModel, "type", T_GETV("locType"));
				SETV(_newLocModel, "pos", T_GETV("locPos"));
				CALLM1(_garr, "joinLocationSim", _newLocModel);
			};

			case WORLD_TYPE_REAL: {
				// Create an actual location
				private _side = GETV(_garr, "side");
				private _args = [T_GETV("locPos"), _side]; // Our side creates this location
				private _newLoc = NEW_PUBLIC("Location", _args);
				CALLM1(_newLoc, "setType", T_GETV("locType"));
				CALLM1(_newLoc, "setBorderCircle", 100);
				pr _gridpos = mapGridPosition T_GETV("locPos");
				pr _type = T_GETV("locType");
				pr _typeName = CALLSM1("Location", "getTypeString", _type);
				pr _name = format ["%1 %2", _typeName, _gridPos];
				CALLM1(_newLoc, "setName", _name);

				// Register the location with the model
				private _newLocModel = NEW("LocationModel", [_world ARG _newLoc]);

				CALLM1(_garr, "joinLocationActual", _newLocModel);
				pr _actual = GETV(_garr, "actual");
				CALLM2(_actual, "postMethodAsync", "removeBuildResources", [T_GETV("buildRes")]);
			};
		};

		T_GETV("successState")
	ENDMETHOD;

ENDCLASS;

#ifdef _SQF_VM



#endif