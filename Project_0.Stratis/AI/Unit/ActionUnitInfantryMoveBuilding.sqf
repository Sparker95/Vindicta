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
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_parameters", [], [[]]] ];
		
		pr _building = (_parameters select {_x select 0 == "building"}) select 0 select 1;
		pr _posID = (_parameters select {_x select 0 == "posID"}) select 0 select 1;
		
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