#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
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
	VARIABLE("assignedCargo"); // Array of [unit, cargo index]
	VARIABLE("assignedTurrets"); // Array of [unit, turret path]

	METHOD("new") {
		params [["_thisObject", "", [""]], ["_agent", "", [""]]];
		
		ASSERT_OBJECT_CLASS(_agent, "Unit");
		
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
		
		ASSERT_OBJECT_CLASS(_unit, "Unit");
		
		OOP_INFO_1("Unassigning unit: %1", _unit);
		
		// Unassign driver
		pr _driver = GETV(_thisObject, "assignedDriver");
		if (!isNil "_driver") then {
			if (_driver == _unit) then {
				OOP_INFO_0("unassigned driver");
				SETV(_thisObject, "assignedDriver", nil);
			};
		};
		
		// Unassign gunner
		/*
		pr _gunner = GETV(_thisObject, "assignedGunner");
		if (!isNil "_gunner") then {
			if (_gunner == _unit) then { SETV(_thisObject, "assignedDriver", nil);};
		};
		*/
		
		// Unassign cargo
		pr _cargo = GETV(_thisObject, "assignedCargo");
		if (!isNil "_cargo") then {
			pr _cargoThisUnit = _cargo select {_x select 0 == _unit};
			{
				_cargo deleteAt (_cargo find _x);
				OOP_INFO_0("unassigned cargo");
			} forEach _cargoThisUnit;
		};
		
		// Unassign turrets
		pr _turrets = GETV(_thisObject, "assignedTurrets");
		if (!isNil "_turrets") then {
			pr _turretsThisUnit = _turrets select {_x select 0 == _unit};
			{
				_turrets deleteAt (_turrets find _x);
				OOP_INFO_0("unassigned turret");
			} forEach _turretsThisUnit;
		};
		
	} ENDMETHOD;
	
	/*
	Method: getAssignedDriver
	Returns the <Unit> assigned as driver or "" if noone is assigned.
	
	Returns: <Unit> or ""
	*/
	METHOD("getAssignedDriver") {
		params [["_thisObject", "", [""]]];
		
		pr _driver = T_GETV("assignedDriver");
		
		if (isNil "_driver") then {
			""
		} else {
			_driver
		};		
	} ENDMETHOD;
	
	/*
	Method: getAssignedTurret
	Returns <Unit> assigned to specified turret path or "" if noone is assigned.
	
	Parameters: _turretPath
	
	_turretPath - array, turret path
	
	Returns: <Unit> or ""
	*/
	METHOD("getAssignedTurret") {
		params [["_thisObject", "", [""]], ["_turretPath", [], [[]]] ];
		pr _assignedTurrets = T_GETV("assignedTurrets");
		
		// Turret array is not initialized, therefore no turrets were assigned
		if (isNil "_assignedTurrets") exitWith {""};
		
		pr _index = _assignedTurrets findIf {(_x select 1) isEqualTo _turretPath};
		if (_index == -1) then {
			""
		} else {
			_assignedTurrets select _index select 0
		};
	} ENDMETHOD;
	
	/*
	Method: getAssignedCargo
	Returns <Unit> assigned to specified cargo index or "" if noone is assigned.
	
	Parameters: _cargoIndex
	
	_cargoIndex - number
	
	Returns: <Unit> or ""
	*/	
	METHOD("getAssignedCargo") {
		params [["_thisObject", "", [""]], ["_cargoIndex", 0, [0]] ];
		pr _assignedCargo = T_GETV("assignedCargo");
		
		// Cargo array is not initialized, therefore no turrets were assigned
		if (isNil "_assignedCargo") exitWith {""};
		
		pr _index = _assignedCargo findIf {(_x select 1) == _cargoIndex};
		if (_index == -1) then {
			""
		} else {
			_assignedCargo select _index select 0
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