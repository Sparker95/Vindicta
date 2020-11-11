#define OOP_INFO
#include "common.hpp"

/*
Class: ActionUnit.ActionUnitGetInVehicle
Makes a unit get into a specific vehicle.
Assumes the unit is on foot already.

Author: Sparker
*/

#define pr private

#define CLASS_NAME "ActionUnitGetInVehicle"

#define OOP_CLASS_NAME ActionUnitGetInVehicle
CLASS("ActionUnitGetInVehicle", "ActionUnit")

	VARIABLE("hVeh");
	VARIABLE("unitVeh");
	VARIABLE("vehRole");
	VARIABLE("turretPath");

	// Time when unit is expected to get into vehicle
	VARIABLE("ETA");

	public override METHOD(getPossibleParameters)
		[
			// We allow only unit OOP objects as target
			[ [TAG_TARGET_VEHICLE_UNIT, [NULL_OBJECT]],  [TAG_VEHICLE_ROLE, [""]] ],	// Required parameters
			[ [TAG_TURRET_PATH, [[]]] ]	// Optional parameters
		]
	ENDMETHOD;

	// ------------ N E W ------------
	/*
	Method: new
	Description
	
	Parameters: _AI, _parameters
	
	_AI - <AI>
	_parameters - array with parameters: "vehicle", "vehicleRole", "turretPath"
	"vehicle" - <Unit> or object handle which has a <Unit> attached to it.
	"vehicleRole" - one of "DRIVER", "TURRET", "CARGO". Cargo will also mean FFV cargo seats.
	"turretPath" - Array, turret path is _vehRole is "TURRET"
	*/
	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		
		pr _veh = CALLSM2("Action", "getParameterValue", _parameters, TAG_TARGET_VEHICLE_UNIT);
		pr _vehRole = CALLSM2("Action", "getParameterValue", _parameters, TAG_VEHICLE_ROLE);
		pr _turretPath = CALLSM3("Action", "getParameterValue", _parameters, TAG_TURRET_PATH, []);
		
		// Is _veh an object handle or a Unit?
		if (_veh isEqualType objNull) then {
			T_SETV("hVeh", _veh);
			pr _unitVeh = CALLSM("Unit", "getUnitFromObjectHandle", [_veh]);
			T_SETV("unitVeh", _unitVeh);
		} else {
			T_SETV("unitVeh", _veh);
			pr _hVeh = CALLM0(_veh, "getObjectHandle");
			T_SETV("hVeh", _hVeh);
		};
		T_SETV("vehRole", _vehRole);
		if (_vehRole == "TURRET") then {
			T_SETV("turretPath", _turretPath);
		};
	ENDMETHOD;

	/*
	Method: seatOccupiedByAnother
	Returns handle to current occupier of the desired seat, if it isn't us
	
	Access: private
	
	Returns: object handle
	*/
	METHOD(seatOccupiedByAnother)
		params [P_THISOBJECT];
		
		pr _vehRole = T_GETV("vehRole");
		pr _hVeh = T_GETV("hVeh");
		pr _hO = T_GETV("hO");
		
		switch (_vehRole) do {	
			case "DRIVER": {
				pr _driver = driver _hVeh;
				if (!isNull _driver && { alive _driver && !(_driver isEqualTo _hO) }) then {
					// Return
					_driver
				} else {
					// Return
					objNull
				};
			};
			case "TURRET" : {
				pr _turretPath = T_GETV("turretPath");
				pr _turretSeat = (fullCrew [_hVeh, "", true]) select {_x#3 isEqualTo _turretPath};
				pr _turretOperator = _turretSeat#0#0;
				if (!isNil "_turretOperator" && { alive _turretOperator && !(_turretOperator isEqualTo _hO) }) then {
					// Return
					_turretOperator
				} else {
					// Return
					objNull
				};
			};
			case "CARGO" : {
				/* FulLCrew output: Array - format:
				0: <Object>unit
				1: <String>role
				2: <Number>cargoIndex (see note in description)
				3: <Array>turretPath
				4: <Boolean>personTurret */
				
				pr _assignedParameters = CALLM0(_ai, "getAssignedVehicleParameters");
				_assignedParameters params ["_cargoIndex", "_turretPath"];

				if (_cargoIndex != -1) then { // If it's a cargo index
					pr _cargoSeat = (fullCrew [_hVeh, "cargo", true]) select {_x#2 isEqualTo _cargoIndex};
					pr _cargoOperator = _cargoSeat#0#0;
					if (!isNil "_cargoOperator" && { alive _cargoOperator && !(_cargoOperator isEqualTo _hO) }) then {
						// Return
						_cargoOperator
					} else {
						// Return
						objNull
					};
				} else { // If it's an FFV turret path
					pr _turretSeat = (fullCrew [_hVeh, "Turret", true]) select {_x#3 isEqualTo _turretPath};
					pr _turretOperator = _turretSeat#0#0;
					if (!isNil "_turretOperator" && {alive _turretOperator && !(_turretOperator isEqualTo _hO)}) then {
						// Return
						_turretOperator
					} else {
						// Return
						objNull
					};
				};
			}; // case
			
			default {
				OOP_ERROR_1("Unknown vehicle role: %1", _vehRole);
				objNull
			};
		}; // switch
		
	ENDMETHOD;

	// logic to run when the goal is activated
	protected override METHOD(activate)
		params [P_THISOBJECT, P_BOOL("_instant")];

		pr _hO = T_GETV("hO");
		pr _hVeh = T_GETV("hVeh");
		pr _AI = T_GETV("ai");

		// Insta-fail if vehicle is destroyed
		if (!alive _hVeh) exitWith {
			OOP_INFO_0("Failed to ACTIVATE: vehicle is destroyed");
			T_SETV("state", ACTION_STATE_FAILED);
			ACTION_STATE_FAILED
		};

		// Set the vehicle upright if its a static
		pr _unitVeh = T_GETV("unitVeh");
		if (CALLM0(_unitVeh, "isStatic")) then {
			if ((vectorUp _hVeh) select 2 < 0.5) then {	//0.5 roughly 45 degrees of tilt
				private _posASL = getPosASL _hVeh;
				private _heightAboveGround = (_posASL#2) - (getTerrainHeightASL _posASL);
				
				if (_heightAboveGround > 1.5) then {
					// If static gun is on a building
					_hVeh setVectorUp [0, 0, 1];
					_hVeh setPosASL [_posASL#0, _posASL#1, (_posASL#2) + 0.3];
				} else {
					// If static gun is on the ground
					_hVeh setVectorUp surfaceNormal position _hVeh;
					_terrainHeight = getTerrainHeightASL position _hVeh; 
					_position = [(getPosASL _hVeh) select 0,(getPosASL _hVeh) select 1, _terrainHeight];
					_hVeh setPosASL _position;
				};
			};
		};

		// Assign vehicle
		pr _vehRole = T_GETV("vehRole");
		pr _turretPath = T_GETV("turretPath");
		pr _success = CALLM3(_ai, "_assignVehicle", _vehRole, _turretPath, _unitVeh);
		if (_success) then {
			OOP_INFO_0("ACTIVATEd successfully");
			// If we were just spawned, just teleport into the vehicle
			pr _AI = T_GETV("AI");
			if (_instant) then {
				// Execute vehicle assignment
				CALLM0(_AI, "executeVehicleAssignment");
				CALLM0(_AI, "moveInAssignedVehicle");
				T_SETV("state", ACTION_STATE_COMPLETED);
				ACTION_STATE_COMPLETED
			} else {
				// Calculate ETA
				pr _hO = T_GETV("hO");
				pr _hVeh = T_GETV("hVeh");
				pr _ETA = GAME_TIME + ((_hO distance _hVeh)/1.4 + 40);
				OOP_INFO_1("Set ETA: %1", _ETA);
				T_SETV("ETA", _ETA);

				T_SETV("state", ACTION_STATE_ACTIVE);
				ACTION_STATE_ACTIVE
			};
		} else {
			OOP_INFO_0("Failed to ACTIVATE");
			T_SETV("state", ACTION_STATE_FAILED);
			ACTION_STATE_FAILED
		};
	ENDMETHOD;

	// logic to run each update-step
	public override METHOD(process)
		params [P_THISOBJECT];

		pr _AI = T_GETV("AI");
		pr _state = T_CALLM0("activateIfInactive");

		if (_state == ACTION_STATE_ACTIVE) then {

			pr _hVeh = T_GETV("hVeh");
			pr _hO = T_GETV("hO");
			pr _vehRole = T_GETV("vehRole");
			pr _unitVeh = T_GETV("unitVeh");

			OOP_INFO_2("PROCESS: State is ACTIVE. Assigned vehicle: %1, role: %2", _unitVeh, _vehRole);

			// Check if the seat is occupied by someone else
			pr _occupier = T_CALLM0("seatOccupiedByAnother");
			if (!isNull _occupier) then {
				// Order them out of the seat
				unassignVehicle _occupier;
				[_occupier] allowGetIn false;
				[_occupier] orderGetIn false;
			} else {
				// Assigned seat is not occupied
				OOP_INFO_0("Assigned seat is FREE");

				// Check if the unit is already in the required vehicle
				pr _ws = GETV(_ai, "worldState");
				pr _atRightVeh = WS_GET(_ws, WSP_UNIT_HUMAN_AT_ASSIGNED_VEHICLE);
				pr _atRightRole = WS_GET(_ws, WSP_UNIT_HUMAN_AT_ASSIGNED_VEHICLE_ROLE);
				pr _atAnyVeh = WS_GET(_ws, WSP_UNIT_HUMAN_AT_VEHICLE);
				if (_atRightVeh) then {
					OOP_INFO_0("Inside assigned vehicle");
				
					// Execute vehicle assignment
					CALLM0(_AI, "executeVehicleAssignment");

					// Order get in
					[_hO] allowGetIn true;
					[_hO] orderGetIn true;
				
					// Check if the unit is in the required seat
					if (_atRightRole) then {
						OOP_INFO_0("Arrived at assigned seat");
						
						// Tell the driver to stop or he'll start driving around like an insane
						if (_vehRole == "DRIVER") then {
							dostop _hO;
						};
						
						// We're done here
						_state = ACTION_STATE_COMPLETED
					} else {
						OOP_INFO_0("Sitting at wrong seat. Changine seats.");
						// We're in the right vehicle but at the wrong seat
						// Just swap seats instantly
						CALLM0(_AI, "moveInAssignedVehicle");
						
						// Wait until we are at proper place anyway
						
						// Fuck this shit, sometimes you can't move unit from one seat to another
						// _state = ACTION_STATE_COMPLETED
					};
				} else {
					// If the unit is on foot now
					if (!_atAnyVeh) then {						
						OOP_INFO_0("Not in vehicle yet. Going on ...");
					
						// Execute vehicle assignment
						CALLM0(_AI, "executeVehicleAssignment");
						// Order get in
						[_hO] allowGetIn true;
						[_hO] orderGetIn true;
						
						// Check ETA
						pr _ETA = T_GETV("ETA");
						OOP_INFO_2("Time: %1, ETA: %2", GAME_TIME, _ETA);
						if(GAME_TIME > _ETA) then {
							// FFS why did you get stuck again??
							// When are BIS going to repair their fucking AIs stucking in the middle of fucking nowhere?
							// Let's just teleport you, buddy :/
							OOP_INFO_0("Exceeded ETA. Teleporting unit.");
							CALLM0(_AI, "moveInAssignedVehicle");
						};
					} else {
						OOP_INFO_0("In WRONG vehicle. Getting out.");
						doGetOut _hO;
					};
				};
			}; // else
		};
		T_SETV("state", _state);
		_state
	ENDMETHOD;
	
	// logic to run when the goal is satisfied
	public override METHOD(terminate)
		params [P_THISOBJECT];

		// If the action is active, unassign the unit from the vehicle
		pr _state = T_GETV("state");
		if (_state == ACTION_STATE_ACTIVE || _state == ACTION_STATE_FAILED) then {
			pr _AI = T_GETV("AI");
			CALLM0(_AI, "unassignVehicle");
		};

	ENDMETHOD;

ENDCLASS;