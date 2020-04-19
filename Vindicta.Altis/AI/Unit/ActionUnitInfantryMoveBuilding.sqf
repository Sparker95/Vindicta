#include "common.hpp"

/*
Class: ActionUnit.ActionUnitInfantryMoveBuilding
Makes a single unit to move to a specified building position.

Parameters:
"building" - object handle of the building
"posID" - ID of the building position used with buildingPos command
*/

CLASS("ActionUnitInfantryMoveBuilding", "ActionUnitInfantryMoveBase")
	VARIABLE("building");
	VARIABLE("posID");

	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		private _building = CALLSM2("Action", "getParameterValue", _parameters, TAG_TARGET);
		T_SETV("building", _building);
		private _posID = CALLSM2("Action", "getParameterValue", _parameters, TAG_BUILDING_POS_ID);
		T_SETV("posID", _posID);

		private _pos = _building buildingPos _posID;
		T_SETV("pos", _pos);
		T_SETV("tolerance", 1.0);

		// Mark the position occupied
		(_building getVariable "vin_occupied_positions") pushBackUnique _posID;
	} ENDMETHOD;

	METHOD("terminate") {
		params [P_THISOBJECT];
	
		// Mark the position unoccupied again
		private _occupiedPositions = T_GETV("building") getVariable "vin_occupied_positions";
		_occupiedPositions deleteAt (_occupiedPositions find T_GETV("posID"));
	} ENDMETHOD;
ENDCLASS;

/*
Code to test it quickly:

// ! set building first !
private _building = cursorObject;
private _posID = 0;

_unit = cursorObject;
_parameters = [["building", _building], ["posID", _posID]];

newAction = [_unit, "ActionUnitInfantryMoveBuilding", _parameters, 1] call AI_misc_fnc_forceUnitAction;
*/