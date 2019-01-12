#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\..\MessageTypes.hpp"
#include "unitWorldStateProperties.hpp"
#include "..\..\GlobalAssert.hpp"

/*
Class: AI.AIUnitVehicle

Author: Sparker 12.11.2018
*/

#define pr private

CLASS("AIUnitVehicle", "AI")

	// Assigned crew variables
	VARIABLE("assignedDriver");
	VARIABLE("assignedGunner");
	VARIABLE("assignedCargo"); // Array of [unit, cargo index]
	VARIABLE("assignedTurrets"); // Array of [unit, turret path]

	METHOD("new") {
		params [["_thisObject", "", [""]]];
		
		// Make sure that the needed MessageLoop exists
		ASSERT_GLOBAL_OBJECT(gMessageLoopGroupAI);
		
		// Initialize sensors
		
		//SETV(_thisObject, "worldState", _ws);
	} ENDMETHOD;
	
	/*
	Method: unassignUnit
	Unassigns unit from this vehicle, if it was assigned. Only changes variables in this AI object.
	
	Parameters: _unit
	
	_unit - <Unit>
	
	Returns: nil
	*/
	METHOD("unassignUnit") {
		params [["_thisObject", "", [""]], ["_unit", "", [""]]];
		
		// Unassign driver
		pr _driver = GETV(_thisObject, "assignedDriver");
		if (!isNil "_driver") then {
			if (_driver == _unit) then { SETV(_thisObject, "assignedDriver", nil);};
		};
		
		// Unassign gunner
		pr _gunner = GETV(_thisObject, "assignedGunner");
		if (!isNil "_gunner") then {
			if (_gunner == _unit) then { SETV(_thisObject, "assignedDriver", nil);};
		};
		
		// Unassign cargo
		pr _cargo = GETV(_thisObject, "assignedCargo");
		if (!isNil "_cargo") then {
			pr _cargoThisUnit = _cargo select {_x select 0 == _unit};
			{
				_cargo deleteAt (_cargo find _x);
			} forEach _cargoThisUnit;
		};
		
		// Unassign turrets
		pr _turrets = GETV(_thisObject, "assignedTurrets");
		if (!isNil "_turrets") then {
			pr _turretsThisUnit = _turrets select {_x select 0 == _unit};
			{
				_turrets deleteAt (_turrets find _x);
			} forEach _turretsThisUnit;
		};
		
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    G E T   M E S S A G E   L O O P
	// | The group AI resides in its own thread
	// ----------------------------------------------------------------------
	
	METHOD("getMessageLoop") {
		gMessageLoopGroupAI
	} ENDMETHOD;

ENDCLASS;