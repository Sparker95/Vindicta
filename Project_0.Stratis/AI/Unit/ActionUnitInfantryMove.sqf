#include "common.hpp"

/*
Class: ActionUnit.ActionUnitInfantryMove
Makes a single unit move to a specified static position.

Parameters:
"position" - position AGL
*/

#define pr private

CLASS("ActionUnitInfantryMove", "ActionUnitInfantryMoveBase")
	
	// ------------ N E W ------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_parameters", [], [[]]] ];
		
		pr _pos = (_parameters select {_x select 0 == "position"}) select 0 select 1;
		T_SETV("pos", _pos);
		
	} ENDMETHOD;
ENDCLASS;

/*
Code to test it quickly:

//infmove

_unit = cursorObject;
_parameters = [["position", getPos player]];

newAction = [_unit, "ActionUnitInfantryMove", _parameters, 1] call AI_misc_fnc_forceUnitAction;
*/