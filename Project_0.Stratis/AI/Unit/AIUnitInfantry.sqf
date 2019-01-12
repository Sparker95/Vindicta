#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\..\MessageTypes.hpp"
#include "unitWorldStateProperties.hpp"
#include "..\..\GlobalAssert.hpp"
#include "vehicleRoles.hpp"

/*
Class: AI.AIUnitInfantry

Author: Sparker 12.11.2018
*/

#define pr private

CLASS("AIUnitInfantry", "AI")

	// Object handle of the unit
	VARIABLE("hO");

	// Vehicle assignment variables
	VARIABLE("assignedVehicle");
	VARIABLE("assignedVehicleRole");
	VARIABLE("assignedCargoIndex");
	VARIABLE("assignedTurretPath");

	METHOD("new") {
		params [["_thisObject", "", [""]], ["_agent", "", [""]]];
		
		// Make sure that the needed MessageLoop exists
		ASSERT_GLOBAL_OBJECT(gMessageLoopGroupAI);
		
		// Set variables
		pr _hO = CALLM0(_agent, "getObjectHandle");
		SETV(_thisObject, "hO", _hO);
		
		// Initialize the world state
		//pr _ws = [WSP_GAR_COUNT] call ws_new; // todo WorldState size must depend on the agent
		//[_ws, WSP_GAR_AWARE_OF_ENEMY, false] call ws_setPropertyValue;
		
		// Initialize sensors
		pr _sensorSalute = NEW("SensorUnitSalute", [_thisObject]);
		CALLM(_thisObject, "addSensor", [_sensorSalute]);
		
		pr _sensorCivNear = NEW("SensorUnitCivNear", [_thisObject]);
		CALLM(_thisObject, "addSensor", [_sensorCivNear]);
		
		//SETV(_thisObject, "worldState", _ws);
	} ENDMETHOD;
	
	
	/*
	Method: assignAsDriver
	
	Parameters: _veh
	
	_veh - string, vehicle <Unit>
	
	Returns: nil
	*/
	METHOD("assignAsDriver") {
		params [ ["_thisObject", "", [""]], ["_veh", "", [""]] ];

		// Unassign this inf unit from its current vehicle
		pr _assignedVehicle = GETV(_thisObject, "assignedVehicle");
		if (!isNil "_assignedVehicle") then {
			pr _assignedVehAI = CALLM0(_assignedVehicle, "getAI");
			CALLM0(_assignedVehAI, "unassignUnit", _thisObject); 
		};
		
		pr _vehAI = CALLM0(_veh, "getAI");
		SETV(_vehAI, "assignedDriver", _thisObject);
		SETV(_thisObject, "assignedVehicle", _veh);
		SETV(_thisObject, "assignedVehicleRole", VEHICLE_ROLE_DRIVER);
		SETV(_thisObject, "assignedCargoIndex", nil);
		SETV(_thisObject, "assignedTurretPath", nil);
	} ENDMETHOD;
	
	/*
	Method: assignAsGunner
	
	Parameters: _veh
	
	_veh - string, vehicle <Unit>
	
	Returns: nil
	*/
	METHOD("assignAsGunner") {
		params [ ["_thisObject", "", [""]], ["_veh", "", [""]] ];
		
		// Unassign this inf unit from its current vehicle
		pr _assignedVehicle = GETV(_thisObject, "assignedVehicle");
		if (!isNil "_assignedVehicle") then {
			pr _assignedVehAI = CALLM0(_assignedVehicle, "getAI");
			CALLM0(_assignedVehAI, "unassignUnit", _thisObject); 
		};
		
		pr _vehAI = CALLM0(_veh, "getAI");
		SETV(_vehAI, "assignedGunner", _thisObject);
		SETV(_thisObject, "assignedVehicle", _veh);
		SETV(_thisObject, "assignedVehicleRole", VEHICLE_ROLE_GUNNER);
		SETV(_thisObject, "assignedCargoIndex", nil);
		SETV(_thisObject, "assignedTurretPath", nil);
	} ENDMETHOD;
	
	/*
	Method: assignAsTurret
	
	Parameters: _veh, _turretPath
	
	_veh - string, vehicle <Unit>
	_turretPath - array, turret path
	
	Returns: nil
	*/
	METHOD("assignAsTurret") {
		params [ ["_thisObject", "", [""]], ["_veh", "", [""]], ["_turretPath", [], [[]]] ];
		
		// Unassign this inf unit from its current vehicle
		pr _assignedVehicle = GETV(_thisObject, "assignedVehicle");
		if (!isNil "_assignedVehicle") then {
			pr _assignedVehAI = CALLM0(_assignedVehicle, "getAI");
			CALLM0(_assignedVehAI, "unassignUnit", _thisObject); 
		};
		
		pr _vehAI = CALLM0(_veh, "getAI");
		pr _vehTurrets = GETV(_vehAI, "assignedTurrets");
		if (isNil "_vehTurrets") then {_vehTurrets = []; SETV(_vehAI, "assignedTurrets", _vehTurrets); };
		_vehTurrets pushBack [GETV(_thisObject, "agent"), _turretPath];
		SETV(_thisObject, "assignedVehicle", _veh);
		SETV(_thisObject, "assignedVehicleRole", VEHICLE_ROLE_TURRET);
		SETV(_thisObject, "assignedCargoIndex", nil);
		SETV(_thisObject, "assignedTurretPath", _turretPath);
	} ENDMETHOD;
	
	/*
	Method: assignAsCargoIndex
	
	Parameters: _veh
	
	_veh - string, vehicle <Unit>
	
	Returns: nil
	*/
	METHOD("assignAsCargoIndex") {
		params [ ["_thisObject", "", [""]], ["_veh", "", [""]], ["_cargoIndex", 0, [0]] ];
		
		// Unassign this inf unit from its current vehicle
		pr _assignedVehicle = GETV(_thisObject, "assignedVehicle");
		if (!isNil "_assignedVehicle") then {
			pr _assignedVehAI = CALLM0(_assignedVehicle, "getAI");
			CALLM0(_assignedVehAI, "unassignUnit", _thisObject); 
		};
		
		pr _vehAI = CALLM0(_veh, "getAI");
		pr _vehCargo = GETV(_vehAI, "assignedCargo");
		if (isNil "_vehCargo") then {_vehCargo = []; SETV(_vehAI, "assignedCargo", _vehCargo); };
		_vehCargo pushBack [GETV(_thisObject, "agent"), _cargoIndex];
		SETV(_thisObject, "assignedVehicle", _veh);
		SETV(_thisObject, "assignedVehicleRole", VEHICLE_ROLE_CARGO);
		SETV(_thisObject, "assignedCargoIndex", _cargoIndex);
		SETV(_thisObject, "assignedTurretPath", nil);
	} ENDMETHOD;
	
	/*
	Method: executeVehicleAssignment
	Runs ARMA assignAs* commands on this unit.
	
	Returns: nil
	*/
	
	METHOD("executeVehicleAssignment") {
		params [ ["_thisObject", "", [""]] ];
		pr _veh = GETV(_thisObject, "assignedVehicle");
		if (!isNil "_veh") then {
			pr _vehRole = GETV(_thisObject, "assignedVehicleRole");
			pr _hVeh = CALLM0(_veh, "getObjectHandle");
			pr _hO = GETV(_thisObject, "hO"); // Object handle of this unit
			switch (_vehRole) do {
				case VEHICLE_ROLE_DRIVER: {
					_hO assignAsDriver _hVeh;
				};
				
				case VEHICLE_ROLE_GUNNER: {
					_hO assignAsGunner _hVeh;
				};
				
				case VEHICLE_ROLE_TURRET: {
					pr _turretPath = GETV(_thisObject, "assignedTurretPath");
					_hO assignAsTurret [_hVeh, _turretPath];
				};
				
				case VEHICLE_ROLE_CARGO: {
					pr _cargoIndex = GETV(_thisObject, "assignedCargoIndex");
					_hO assignAsCargoIndex [_hVeh, _cargoIndex];
					ade_dumpCallstack;
				};
			};
		};
	} ENDMETHOD;
	
	/*
	Method: moveInAssignedVehicle
	Instantly moves unit into assigned vehicle
	
	Returns: bool, true if the moveIn* command was executed
	*/
	
	METHOD("moveInAssignedVehicle") {
		params [ ["_thisObject", "", [""]] ];
		pr _veh = GETV(_thisObject, "assignedVehicle");
		if (!isNil "_veh") then {
			pr _vehRole = GETV(_thisObject, "assignedVehicleRole");
			pr _hVeh = CALLM0(_veh, "getObjectHandle");
			pr _hO = GETV(_thisObject, "hO"); // Object handle of this unit
			switch (_vehRole) do {
				case VEHICLE_ROLE_DRIVER: {
					_hO moveInDriver _hVeh;
					true
				};
				
				case VEHICLE_ROLE_GUNNER: {
					_hO moveInGunner _hVeh;
					true
				};
				
				case VEHICLE_ROLE_TURRET: {
					pr _turretPath = GETV(_thisObject, "assignedTurretPath");
					_hO moveInTurret [_hO, _turretPath];
					true
				};
				
				case VEHICLE_ROLE_CARGO: {
					pr _cargoIndex = GETV(_thisObject, "assignedCargoIndex");
					_hO moveInCargo [_hO, _cargoIndex];
					true
				};
			};
		} else {
			false
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