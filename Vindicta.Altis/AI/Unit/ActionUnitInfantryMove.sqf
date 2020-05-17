#include "common.hpp"

/*
Class: ActionUnit.ActionUnitInfantryMove
Makes a single unit move to a specified static position.

Parameters:
"position" - position AGL
"teleport" - bool, default false, if set to true, unit will be teleported to his destination
*/

#define pr private

#define OOP_CLASS_NAME ActionUnitInfantryMove
CLASS("ActionUnitInfantryMove", "ActionUnitInfantryMoveBase")
	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		pr _pos = CALLSM2("Action", "getParameterValue", _parameters, TAG_POS);
		T_SETV("pos", _pos);
	ENDMETHOD;
ENDCLASS;

/*
Code to test it quickly:

//infmove

_unit = cursorObject;
_parameters = [["position", getPos player]];

newAction = [_unit, "ActionUnitInfantryMove", _parameters, 1] call AI_misc_fnc_forceUnitAction;
*/