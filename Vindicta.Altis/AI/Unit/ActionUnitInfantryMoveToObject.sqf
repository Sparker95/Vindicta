#include "common.hpp"

/*
Class: ActionUnit.ActionUnitInfantryMoveToObject
Makes a single unit move to a specified another object, destination position will be updated.

*/

#define pr private

#define OOP_CLASS_NAME ActionUnitInfantryMoveToObject
CLASS("ActionUnitInfantryMoveToObject", "ActionUnitInfantryMoveBase")
	
	VARIABLE("destObject");
	
	METHOD(getPossibleParameters)
		[
			[ [TAG_TARGET_OBJECT, [NULL_OBJECT] ] ],	// Required parameters
			[ [TAG_MOVE_RADIUS, [0]], [TAG_DURATION_SECONDS, [0]], [TAG_TELEPORT, [false]] ]	// Optional parameters
		]
	ENDMETHOD;

	// ------------ N E W ------------
	
	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		
		pr _targetObject = CALLSM2("Action", "getParameterValue", _parameters, TAG_TARGET_OBJECT);
		T_SETV("destObject", _targetObject);

		// Set position
		pr _hDest = _targetObject;
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
		
		// Bail if target is null
		pr _hDest = T_GETV("destObject");
		if (isNull _hDest) exitWith {
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