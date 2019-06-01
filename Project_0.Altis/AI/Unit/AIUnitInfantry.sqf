#include "common.hpp"

/*
Class: AI.AIUnitInfantry

Author: Sparker 12.11.2018
*/

#define pr private

CLASS("AIUnitInfantry", "AI_GOAP")

	// Object handle of the unit
	VARIABLE("hO");

	// Vehicle assignment variables
	VARIABLE("assignedVehicle");
	VARIABLE("assignedVehicleRole");
	VARIABLE("assignedCargoIndex");
	VARIABLE("assignedTurretPath");
	
	// Sentry position
	VARIABLE("sentryPos");

	// Indicates that this AI is new and was created recently
	// This flag aids acceleration of actions that were given to AI when it was just spawned
	VARIABLE("new");

	METHOD("new") {
		params [["_thisObject", "", [""]], ["_agent", "", [""]]];
		
		// Make sure arguments are of proper classes
		ASSERT_OBJECT_CLASS(_agent, "Unit");
		
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
		
		// Set "new" flag
		T_SETV("new", true);

		//SETV(_thisObject, "worldState", _ws);
	} ENDMETHOD;
	
	METHOD("delete") {
		params [["_thisObject", "", [""]]];
		
		OOP_INFO_1("DELETE %1", _thisObject);
		
		// Unassign this unit from its assigned vehicle
		CALLM0(_thisObject, "unassignVehicle");
	} ENDMETHOD;
	
	/*
	Method: unassignVehicle
	Unassigns unit from the vehicle it was assigned to
	
	Returns: nil
	*/
	METHOD("unassignVehicle") {
		params [ ["_thisObject", "", [""]]];

		OOP_INFO_1("unassigning vehicle of %1", _thisObject);

		// Unassign this inf unit from its current vehicle
		pr _assignedVehicle = T_GETV("assignedVehicle");
		if (!isNil "_assignedVehicle") then {
			OOP_INFO_1("previously assigned vehicle: %1", _assignedVehicle);
			
			pr _assignedVehAI = CALLM0(_assignedVehicle, "getAI");
			if (_assignedVehAI != "") then { // sanity checks
				pr _unit = T_GETV("agent");
				CALLM1(_assignedVehAI, "unassignUnit", _unit);
			} else {
				OOP_WARNING_1("AI of assigned vehicle %1 doesn't exist", _assignedVehicle);
			};
			
			T_SETV("assignedVehicle", nil);
			T_SETV("assignedVehicleRole", VEHICLE_ROLE_NONE);
		};
		pr _hO = GETV(_thisObject, "hO");
		unassignVehicle _hO;
		[_hO] orderGetIn false;
		_hO action ["getOut", vehicle _hO];
	} ENDMETHOD;
	
	/*
	Method: assignAsDriver
	
	Parameters: _veh
	
	_veh - string, vehicle <Unit>
	
	Returns: true if assignment was successful, false otherwise
	*/
	METHOD("assignAsDriver") {
		params [ ["_thisObject", "", [""]], ["_veh", "", [""]] ];

		ASSERT_OBJECT_CLASS(_veh, "Unit");

		OOP_INFO_2("Assigning %1 as a DRIVER of %2", _thisObject, _veh);

		// Unassign this inf unit from its current vehicle
		pr _assignedVeh = T_GETV("assignedVehicle");			if (isNil "_assignedVeh") then {_assignedVeh = ""; };
		pr _assignedVehRole = T_GETV("assignedVehicleRole");	if (isNil "_assignedVehRole") then {_assignedVehRole = VEHICLE_ROLE_NONE; };
		//pr _assignedCargoIndex = T_GETV("assignedCargoIndex");	if (isNil "_assignedCargoIndex") then {_assignedCargoIndex = -1; };
		//pr _assignedTurretPath = T_GETV("assignedTurretPath");	if (isNil "_assignedTurretPath") then {_assignedTurretPath = -1; };

		if (! ((_assignedVeh == _veh) && (_assignedVehRole == VEHICLE_ROLE_DRIVER)) ) then {
			CALLM0(_thisObject, "unassignVehicle");
		};
		
		pr _vehAI = CALLM0(_veh, "getAI");
		// Check if someone else is assigned already
		pr _driver = CALLM0(_vehAI, "getAssignedDriver");
		pr _unit = T_GETV("agent");
		if (_driver != "" && _driver != _unit) then {
			false
		} else {
			SETV(_vehAI, "assignedDriver", _unit);
			SETV(_thisObject, "assignedVehicle", _veh);
			SETV(_thisObject, "assignedVehicleRole", VEHICLE_ROLE_DRIVER);
			SETV(_thisObject, "assignedCargoIndex", nil);
			SETV(_thisObject, "assignedTurretPath", nil);
			true
		};
	} ENDMETHOD;
	
	/*
	Method: assignAsGunner
	Disabled for now! Use assignAsTurret instead.
	
	Parameters: _veh
	
	_veh - string, vehicle <Unit>
	
	Returns: nil
	*/
	/*
	METHOD("assignAsGunner") {
		params [ ["_thisObject", "", [""]], ["_veh", "", [""]] ];
		
		// Unassign this inf unit from its current vehicle
		CALLM0(_thisObject, "unassignVehicle");
		
		pr _vehAI = CALLM0(_veh, "getAI");
		SETV(_vehAI, "assignedGunner", _thisObject);
		SETV(_thisObject, "assignedVehicle", _veh);
		SETV(_thisObject, "assignedVehicleRole", VEHICLE_ROLE_GUNNER);
		SETV(_thisObject, "assignedCargoIndex", nil);
		SETV(_thisObject, "assignedTurretPath", nil);
	} ENDMETHOD;
	*/
	
	/*
	Method: assignAsTurret
	
	Parameters: _veh, _turretPath
	
	_veh - string, vehicle <Unit>
	_turretPath - array, turret path
	
	Returns: true if assignment was successful, false otherwise
	*/
	METHOD("assignAsTurret") {
		params [ ["_thisObject", "", [""]], ["_veh", "", [""]], ["_turretPath", [], [[]]] ];
		
		OOP_INFO_3("Assigning %1 as a TURRET %2 of %3", _thisObject, _turretPath, _veh);

		ASSERT_OBJECT_CLASS(_veh, "Unit");
		
		// Unassign this inf unit from its current vehicle
		pr _assignedVeh = T_GETV("assignedVehicle");			if (isNil "_assignedVeh") then {_assignedVeh = ""; };
		pr _assignedVehRole = T_GETV("assignedVehicleRole");	if (isNil "_assignedVehRole") then {_assignedVehRole = VEHICLE_ROLE_NONE; };
		//pr _assignedCargoIndex = T_GETV("assignedCargoIndex");	if (isNil "_assignedCargoIndex") then {_assignedCargoIndex = -1; };
		pr _assignedTurretPath = T_GETV("assignedTurretPath");	if (isNil "_assignedTurretPath") then {_assignedTurretPath = -1; };

		if (! ((_assignedVeh == _veh) && (_assignedVehRole == VEHICLE_ROLE_TURRET) && (_assignedTurretPath isEqualTo _turretPath)) ) then {
			CALLM0(_thisObject, "unassignVehicle");
		};
		
		pr _vehAI = CALLM0(_veh, "getAI");
		pr _unit = T_GETV("agent");
		// Check if someone else is already assigned
		pr _turretOperator = CALLM1(_vehAI, "getAssignedTurret", _turretPath);
		if (_turretOperator != "" && _turretOperator != _unit) then {
			false
		} else {
			pr _vehTurrets = GETV(_vehAI, "assignedTurrets");
			if (isNil "_vehTurrets") then {_vehTurrets = []; SETV(_vehAI, "assignedTurrets", _vehTurrets); };
			_vehTurrets pushBack [_unit, _turretPath];
			T_SETV("assignedVehicle", _veh);
			T_SETV("assignedVehicleRole", VEHICLE_ROLE_TURRET);
			T_SETV("assignedCargoIndex", nil);
			T_SETV("assignedTurretPath", _turretPath);
			true
		};
	} ENDMETHOD;
	
	/*
	Method: assignAsCargoIndex
	
	Parameters: _veh
	
	_veh - string, vehicle <Unit>
	
	Returns: true if assignment was successful, false otherwise
	*/
	METHOD("assignAsCargoIndex") {
		params [ ["_thisObject", "", [""]], ["_veh", "", [""]], ["_cargoIndex", 0, [0]] ];
		
		ASSERT_OBJECT_CLASS(_veh, "Unit");
		
		OOP_INFO_3("Assigning %1 as CARGO INDEX %2 of %3", _thisObject, _cargoIndex, _veh);

		// Unassign this inf unit from its current vehicle
		pr _assignedVeh = T_GETV("assignedVehicle");			if (isNil "_assignedVeh") then {_assignedVeh = ""; };
		pr _assignedVehRole = T_GETV("assignedVehicleRole");	if (isNil "_assignedVehRole") then {_assignedVehRole = VEHICLE_ROLE_NONE; };
		pr _assignedCargoIndex = T_GETV("assignedCargoIndex");	if (isNil "_assignedCargoIndex") then {_assignedCargoIndex = -1; };
		//pr _assignedTurretPath = T_GETV("assignedTurretPath");	if (isNil "_assignedTurretPath") then {_assignedTurretPath = -1; };

		if (! ((_assignedVeh == _veh) && (_assignedVehRole == VEHICLE_ROLE_TURRET) && (_assignedCargoIndex == _cargoIndex)) ) then {
			CALLM0(_thisObject, "unassignVehicle");
		};
		
		pr _vehAI = CALLM0(_veh, "getAI");
		pr _unit = T_GETV("agent");
		// Check if someone else is already assigned
		pr _cargoPassenger = CALLM1(_vehAI, "getAssignedCargo", _cargoIndex);
		if (_cargoPassenger != "" && _cargoPassenger != _unit) then {
			false
		} else {
			pr _vehCargo = GETV(_vehAI, "assignedCargo");
			if (isNil "_vehCargo") then {_vehCargo = []; SETV(_vehAI, "assignedCargo", _vehCargo); };
			_vehCargo pushBack [GETV(_thisObject, "agent"), _cargoIndex];
			SETV(_thisObject, "assignedVehicle", _veh);
			SETV(_thisObject, "assignedVehicleRole", VEHICLE_ROLE_CARGO);
			SETV(_thisObject, "assignedCargoIndex", _cargoIndex);
			SETV(_thisObject, "assignedTurretPath", nil);
			true
		};
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
				
				/*
				case VEHICLE_ROLE_GUNNER: {
					_hO assignAsGunner _hVeh;
				};
				*/
				
				case VEHICLE_ROLE_TURRET: {
					pr _turretPath = GETV(_thisObject, "assignedTurretPath");
					_hO assignAsTurret [_hVeh, _turretPath];
				};
				
				case VEHICLE_ROLE_CARGO: {
					pr _cargoIndex = GETV(_thisObject, "assignedCargoIndex");
					_hO assignAsCargoIndex [_hVeh, _cargoIndex];
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
					_hO setPosWorld (getPosWorld _hO);
					_hO moveInDriver _hVeh;
					true
				};
				
				/*
				case VEHICLE_ROLE_GUNNER: {
					_hO moveInGunner _hVeh;
					true
				};
				*/
				
				case VEHICLE_ROLE_TURRET: {
					pr _turretPath = GETV(_thisObject, "assignedTurretPath");
					_hO setPosWorld (getPosWorld _hO);
					_hO moveInTurret [_hVeh, _turretPath];
					true
				};
				
				case VEHICLE_ROLE_CARGO: {
					pr _cargoIndex = GETV(_thisObject, "assignedCargoIndex");
					_hO setPosWorld (getPosWorld _hO);
					_hO moveInCargo [_hVeh, _cargoIndex];
					true
				};
			};
		} else {
			false
		};
	} ENDMETHOD;
	
	/*
	Method: getAssignedVehicleRole
	Returns assigned vehicle role of the unit
	
	Returns: "DRIVER", "TURRET", "CARGO" or "" if the unit is not assigned anywhere
	*/
	
	METHOD("getAssignedVehicleRole") {
		params [ ["_thisObject", "", [""]] ];
		
		pr _vehRole = GETV(_thisObject, "assignedVehicleRole");
		
		// If nothing is assigned
		if (isNil "_vehRole") exitWith {""};
		
		switch (_vehRole) do {
			case VEHICLE_ROLE_DRIVER: {
				"DRIVER"
			};
			
			case VEHICLE_ROLE_TURRET: {
				"TURRET"
			};
			
			case VEHICLE_ROLE_CARGO: {
				"CARGO"
			};
			
			default {""};
		};
	} ENDMETHOD;
	
		/*
	Method: getAssignedVehicle
	Returns assigned vehicle or "" if the unit is not assigned to a vehicle
	
	Returns: vehicle's <Unit> object or "" if the unit is not assigned anywhere
	*/
	
	METHOD("getAssignedVehicle") {
		params [ ["_thisObject", "", [""]] ];
		
		pr _veh = GETV(_thisObject, "assignedVehicle");
		
		// If nothing is assigned
		if (isNil "_veh") exitWith {""};
		
		_veh
	} ENDMETHOD;
	
	/*
	Method: setSentryPos
	Sets the sentry position, which may be later retrieved by actions.
	
	Parameters: _pos
	
	_pos - position
	
	Returns: nil
	*/
	
	METHOD("setSentryPos") {
		params [ ["_thisObject", "", [""]], ["_pos", [], [[]]] ];
		T_SETV("sentryPos", _pos);
	} ENDMETHOD;
	
	/*
	Method: getSentryPos
	Getter for setSentryPos
	
	Returns: position or [] if no position was assigned
	*/
	
	METHOD("getSentryPos") {
		params [ ["_thisObject", "", [""]]];
		pr _pos = T_GETV("sentryPos");
		if (isNil "_pos") then {
			[]
		} else {
			_pos
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