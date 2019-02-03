#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\Action\Action.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"
#include "..\Stimulus\Stimulus.hpp"
#include "..\WorldFact\WorldFact.hpp"
#include "..\stimulusTypes.hpp"
#include "..\worldFactTypes.hpp"

/*
Class: ActionUnit.ActionUnitInfantryMove
Makes a single unit move to a specified position.

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