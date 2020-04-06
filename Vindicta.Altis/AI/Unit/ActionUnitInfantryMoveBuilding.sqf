#include "common.hpp"

/*
Class: ActionUnit.ActionUnitInfantryMoveBuilding
Makes a single unit to move to a specified building position.

Parameters:
"building" - object handle of the building
"posID" - ID of the building position used with buildingPos command
*/

#define pr private

CLASS("ActionUnitInfantryMoveBuilding", "ActionUnitInfantryMoveBase")
	
	
	// ------------ N E W ------------
	
	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		
		pr _building = CALLSM2("Action", "getParameterValue", _parameters, "building");
		pr _posID = CALLSM2("Action", "getParameterValue", _parameters, "posID");

		pr _pos = _building buildingPos _posID;
		T_SETV("pos", _pos);
		
		T_SETV("tolerance", 1.0);
		
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