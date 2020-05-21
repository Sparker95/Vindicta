#include "common.hpp"
FIX_LINE_NUMBERS()
/*
Class: ActionUnit.ActionUnitInfantryMoveToUnit
Makes a single unit move to a specified another <Unit>, destination position will be updated.

Parameters:
"unit" - the <Unit> to move to
*/

#define pr private

#define OOP_CLASS_NAME ActionUnitInfantryMoveToUnit
CLASS("ActionUnitInfantryMoveToUnit", "ActionUnitInfantryMoveBase")
	
	VARIABLE("destUnit");
	
	// ------------ N E W ------------
	
	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		
		pr _unit = CALLSM2("Action", "getParameterValue", _parameters, "unit");

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
		
		OOP_INFO_2("new: dest unit pos: %1, tolerance: %2", _posDest, _tolerance);
		
	ENDMETHOD;
	
	METHOD(process)
		params [P_THISOBJECT];
		
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
		if ((_pos distance2D _hDest) > 1.0) exitWith {
			T_SETV("pos", ASLToAGL (getPosASL _hDest));
			T_SETV("state", ACTION_STATE_INACTIVE);
			ACTION_STATE_INACTIVE
		};
		
		// Call base class process method
		pr _state = T_CALLCM0("ActionUnitInfantryMoveBase", "process");
		
		T_SETV("state", _state);
		_state
	ENDMETHOD;
	
	
ENDCLASS;