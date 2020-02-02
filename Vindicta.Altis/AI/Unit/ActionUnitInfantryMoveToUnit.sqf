#include "common.hpp"

/*
Class: ActionUnit.ActionUnitInfantryMoveToUnit
Makes a single unit move to a specified another <Unit>, destination position will be updated.

Parameters:
"unit" - the <Unit> to move to
*/

#define pr private

CLASS("ActionUnitInfantryMoveToUnit", "ActionUnitInfantryMoveBase")
	
	VARIABLE("destUnit");
	
	// ------------ N E W ------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_parameters", [], [[]]] ];
		
		pr _unit = (_parameters select {_x select 0 == "unit"}) select 0 select 1;
		T_SETV("destUnit", _unit);
		
		// Set position
		pr _hDest = CALLM0(_unit, "getObjectHandle");
		pr _posDest = ASLtoAGL (getPosASL _hDest);
		T_SETV("pos", _posDest);
		
		// Set tolerance from bounding box size
		pr _a = (boundingBoxReal _hDest) select 0;
		_a set [2, 0]; // Erase the vertical component
		pr _tolerance = vectorMagnitude _a;
		T_SETV("tolerance", _tolerance + 1.5);
		
		OOP_INFO_2("ACTIVATE: dest unit pos: %1, tolerance: %2", _posDest, _tolerance);
		
	} ENDMETHOD;
	
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		// Bail if dest unit is destroyed or whatever
		pr _destUnit = T_GETV("destUnit");
		if (!IS_OOP_OBJECT(_destUnit)) exitWith {
			T_SETV("state", ACTION_STATE_FAILED);
			ACTION_STATE_FAILED
		};

		pr _hDest = CALLM0(_destUnit, "getObjectHandle");
		if (! alive _hDest) exitWith {
			T_SETV("state", ACTION_STATE_FAILED);
			ACTION_STATE_FAILED
		};

		// Check if the other unit has moved a lot so we need to update the position
		pr _pos = T_GETV("pos");
		if ((_pos distance2D _hDest) > 1.0) then {
			T_SETV("pos", ASLToAGL (getPosASL _hDest));
			CALL_CLASS_METHOD("ActionUnitInfantryMoveBase", _thisObject, "activate", []);
		};
		
		// Call base class process method
		pr _state = CALL_CLASS_METHOD("ActionUnitInfantryMoveBase", _thisObject, "process", []);
		
		T_SETV("state", _state);
		_state
	} ENDMETHOD;
	
	
ENDCLASS;