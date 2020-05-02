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

	// Cargo index or turret path array
	VARIABLE("chosenCargoSeat");

	// Time when unit is expected to get into vehicle
	VARIABLE("ETA");

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
		
		pr _veh = CALLSM2("Action", "getParameterValue", _parameters, "vehicle");
		pr _vehRole = CALLSM2("Action", "getParameterValue", _parameters, "vehicleRole");
		pr _turretPath = CALLSM3("Action", "getParameterValue", _parameters, "turretPath", []);
		
		// Is _veh an object handle or a Unit?
		if (_veh isEqualType objNull) then {
			T_SETV("hVeh", _veh);
			pr _unitVeh = CALL_STATIC_METHOD("Unit", "getUnitFromObjectHandle", [_veh]);
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
	Method: assignVehicle
	Description
	
	Access: private
	
	Returns: bool
	*/
	METHOD(assignVehicle)
		params [P_THISOBJECT];
		
		pr _vehRole = T_GETV("vehRole");
		pr _AI = T_GETV("AI");
		pr _unitVeh = T_GETV("unitVeh");
		
		OOP_INFO_2("Assigning vehicle: %1, role: %2", _unitVeh, _vehRole);
		
		switch (_vehRole) do {	
		/*
		[[hemttD,"driver",-1,[],false],
		[B Alpha 1-1:5,"cargo",0,[],false],[B Alpha 1-1:4,"cargo",1,[],false],[B Alpha 1-1:6,"cargo",2,[],false],[B Alpha 1-1:2,"Turret",7,[0],true],[B Alpha 1-1:3,"Turret",15,[1],true]]
		
		[[B Alpha 1-1:5,"cargo",0,[],false],[B Alpha 1-1:4,"cargo",1,[],false],[B Alpha 1-1:6,"cargo",2,[],false],[<NULL-object>,"cargo",3,[],false],[<NULL-object>,"cargo",4,[],false],[<NULL-object>,"cargo",5,[],false],[<NULL-object>,"cargo",6,[],false],[<NULL-object>,"cargo",8,[],false],[<NULL-object>,"cargo",9,[],false],[<NULL-object>,"cargo",10,[],false],[<NULL-object>,"cargo",11,[],false],[<NULL-object>,"cargo",12,[],false],[<NULL-object>,"cargo",13,[],false],[<NULL-object>,"cargo",14,[],false],[<NULL-object>,"cargo",16,[],false]]
		
		[[B Alpha 1-1:5,"cargo",0,[],false],[B Alpha 1-1:4,"cargo",1,[],false],[B Alpha 1-1:6,"cargo",2,[],false],[<NULL-object>,"cargo",3,[],false],[<NULL-object>,"cargo",4,[],false],[<NULL-object>,"cargo",5,[],false],[<NULL-object>,"cargo",6,[],false],[<NULL-object>,"cargo",8,[],false],[<NULL-object>,"cargo",9,[],false],[<NULL-object>,"cargo",10,[],false],[<NULL-object>,"cargo",11,[],false],[<NULL-object>,"cargo",12,[],false],[<NULL-object>,"cargo",13,[],false],[<NULL-object>,"cargo",14,[],false],[<NULL-object>,"cargo",16,[],false]]
		*/
			case "DRIVER": {
				pr _success = CALLM1(_AI, "assignAsDriver", _unitVeh);
				
				// Return
				_success
			};
			/*
			case "GUNNER" : {
				CALLM1(_AI, "assignAsGunner", _unitVeh);
				
				// Return
				true
			};
			*/
			case "TURRET" : {
				pr _turretPath = T_GETV("turretPath");
				pr _success = CALLM2(_AI, "assignAsTurret", _unitVeh, _turretPath);
				
				// Return
				_success
			};
			case "CARGO" : {
				/* FulLCrew output: Array - format:
				0: <Object>unit
				1: <String>role
				2: <Number>cargoIndex (see note in description)
				3: <Array>turretPath
				4: <Boolean>personTurret */
				
				pr _hVeh = T_GETV("hVeh");
				pr _hO = T_GETV("hO");
				pr _vehAI = CALLM0(_unitVeh, "getAI");
				pr _unit = GETV(T_GETV("AI"), "agent");
				
				pr _freeCargoSeats = (fullCrew [_hVeh, "cargo", true]) select {
					pr _assignedPassenger = CALLM1(_vehAI, "getAssignedCargo", _x select 2);
					( (!alive (_x select 0)) ||
					  ((_x select 0) isEqualTo _hO) ) &&
					  ( _assignedPassenger == "" || _assignedPassenger == _unit)
				};
				
				pr _freeFFVSeats = (fullCrew [_hVeh, "Turret", true]) select {
					pr _assignedTurret = CALLM1(_vehAI, "getAssignedTurret", _x select 3);
					( (!alive (_x select 0)) || ((_x select 0) isEqualTo _hO)) && (_x select 4) && (_assignedTurret == "" || _assignedTurret == _unit)
				}; // empty and person turret
				
				pr _freeSeats = _freeCargoSeats + _freeFFVSeats;
				pr _chosenCargoSeat = T_GETV("chosenCargoSeat");
				
				// Choose a new cargo seat
				if (count _freeSeats == 0) then {
					// No room for this soldier in the vehicle
					// Mission failed
					// We are dooomed!
					// https://www.youtube.com/watch?v=5vSUV1nii5k
					// Return
					false
				} else { // if count free seats == 0
					pr _chosenSeat = selectRandom _freeSeats;
					_chosenSeat params ["_seatUnit", "_seatRole", "_seatCargoIndex", "_seatTurretPath"]; //, "_seatPersonTurret"];
					if (_seatRole == "cargo") then {
						T_SETV("chosenCargoSeat", _seatCargoIndex);
						pr _success = CALLM2(_AI, "assignAsCargoIndex", _unitVeh, _seatCargoIndex);
						
						// Return
						_success
					} else {
						T_SETV("chosenCargoSeat", _seatTurretPath);
						pr _success = CALLM2(_AI, "assignAsTurret", _unitVeh, _seatTurretPath);
						
						// Return
						_success
					};
				}; // else
			}; // case
			
			default {
				diag_log format ["[ActionUnitGetInVehicle] Error: unknown vehicle role: %1", _vehRole];
			};
		}; // switch
		
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
			/*
			case "GUNNER" : {
				pr _gunner = gunner _hVeh;
				if (!(isNull _gunner) && !(_gunner isEqualTo _hO)) then {
					// Return
					true
				} else {
					// Return
					false
				};
			};
			*/
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
				
				pr _chosenCargoSeat = T_GETV("chosenCargoSeat");
				if (_chosenCargoSeat isEqualType 0) then { // If it's a cargo index
					pr _cargoIndex = _chosenCargoSeat;
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
					pr _turretPath = _chosenCargoSeat;
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
				diag_log format ["[ActionUnitGetInVehicle] Error: unknown vehicle role: %1", _vehRole];
				objNull
			};
		}; // switch
		
	ENDMETHOD;

	/*
	Method: atAssignedSeat
	Checks if the unit is currently at the assigned vehicle seat
	
	Access: private
	
	Returns: bool
	*/
	METHOD(isAtAssignedSeat)
		params [P_THISOBJECT];
		
		pr _vehRole = T_GETV("vehRole");
		pr _hVeh = T_GETV("hVeh");
		pr _hO = T_GETV("hO");
		
		switch (_vehRole) do {	
			case "DRIVER": {
				pr _driver = driver _hVeh;
				pr _return = _driver isEqualTo _hO;
				_return
			};
			/*
			case "GUNNER" : {
				pr _gunner = gunner _hVeh;
				pr _return = _gunner isEqualTo _ho;
				_return
			};
			*/
			case "TURRET" : {
				pr _turretPath = T_GETV("turretPath");
				pr _turretSeat = (fullCrew [_hVeh, "", true]) select {_x select 3 isEqualTo _turretPath};
				pr _turretOperator = _turretSeat select 0 select 0;
				
				pr _return = _turretOperator isEqualTo _hO;
				_return
			};
			case "CARGO" : {
				/* FulLCrew output: Array - format:
				0: <Object>unit
				1: <String>role
				2: <Number>cargoIndex (see note in description)
				3: <Array>turretPath
				4: <Boolean>personTurret */
				
				pr _chosenCargoSeat = T_GETV("chosenCargoSeat");
				if (_chosenCargoSeat isEqualType 0) then { // If it's a cargo index
					pr _cargoIndex = _chosenCargoSeat;
					pr _cargoSeat = (fullCrew [_hVeh, "cargo", true]) select {_x select 2 isEqualTo _cargoIndex};
					pr _cargoOperator = _cargoSeat select 0 select 0;
					
					pr _return = _cargoOperator isEqualTo _hO;
					_return
				} else { // If it's an FFV turret path
					pr _turretPath = _chosenCargoSeat;
					pr _turretSeat = (fullCrew [_hVeh, "Turret", true]) select {_x select 3 isEqualTo _turretPath};
					pr _turretOperator = _turretSeat select 0 select 0;
					
					pr _return = _turretOperator isEqualTo _hO;
					_return
				};
			}; // case cargo
			
			default {
				diag_log format ["[ActionUnitGetInVehicle] Error: unknown vehicle role: %1", _vehRole];
				false
			};
		}; // switch
	ENDMETHOD;

	// logic to run when the goal is activated
	METHOD(activate)
		params [P_THISOBJECT, P_BOOL("_instant")];

		pr _hO = T_GETV("hO");
		pr _hVeh = T_GETV("hVeh");

		// Insta-fail if vehicle is destroyed
		if (!alive _hVeh) exitWith {
			OOP_INFO_0("Failed to ACTIVATE: vehicle is destroyed");
			T_SETV("state", ACTION_STATE_FAILED);
			ACTION_STATE_FAILED
		};

		// Assign vehicle
		pr _success = T_CALLM0("assignVehicle");
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
	METHOD(process)
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
				if (vehicle _hO isEqualTo _hVeh) then {
					OOP_INFO_0("Inside assigned vehicle");
				
					// Execute vehicle assignment
					CALLM0(_AI, "executeVehicleAssignment");

					// Order get in
					[_hO] allowGetIn true;
					[_hO] orderGetIn true;
				
					// Check if the unit is in the required seat
					if (T_CALLM0("isAtAssignedSeat")) then {
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
					if (vehicle _hO isEqualTo _hO) then {						
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
	METHOD(terminate)
		params [P_THISOBJECT];

		// If the action is active, unassign the unit from the vehicle
		pr _state = T_GETV("state");
		if (_state == ACTION_STATE_ACTIVE || _state == ACTION_STATE_FAILED) then {
			pr _AI = T_GETV("AI");
			CALLM0(_AI, "unassignVehicle");
		};

	ENDMETHOD;

ENDCLASS;

/*
Code to test it quickly:

// setVeh
veh = cursorObject getVariable "unit";


// GetIn
_unit = cursorObject;
_parameters = [["vehicle", veh], ["vehicleRole", "CARGO"], ["turretPath", 0]];

newAction = [_unit, "ActionUnitGetInVehicle", _parameters, 1] call AI_misc_fnc_forceUnitAction;
*/