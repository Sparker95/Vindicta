#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\Action\Action.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"
#include "..\Stimulus\Stimulus.hpp"
#include "..\WorldFact\WorldFact.hpp"
#include "..\stimulusTypes.hpp"
#include "..\worldFactTypes.hpp"
#include "vehicleRoles.hpp"

/*
Class: ActionUnit.ActionUnitGetInVehicle
Makes a unit get into a specific vehicle.
Assumes the unit is on foot already.

Author: Sparker
*/

#define pr private

//#define DEBUG
#define CLASS_NAME "ActionUnitGetInVehicle"

#ifdef DEBUG
#define INFO_0(str) diag_log format ["[%1.%2] Info: %3", CLASS_NAME, _thisObject, str];
#define INFO_1(str, a) diag_log format ["[%1.%2] Info: %3", CLASS_NAME, _thisObject, format [str, a]];
#define INFO_2(str, a) diag_log format ["[%1.%2] Info: %3", CLASS_NAME, _thisObject, format [str, a, b]];
#define INFO_3(str, a) diag_log format ["[%1.%2] Info: %3", CLASS_NAME, _thisObject, format [str, a, b, c]];
#define INFO_4(str, a) diag_log format ["[%1.%2] Info: %3", CLASS_NAME, _thisObject, format [str, a, b, c, d]];
#define INFO_5(str, a) diag_log format ["[%1.%2] Info: %3", CLASS_NAME, _thisObject, format [str, a, b, c, d, e]];
#else
#define INFO_0(str)
#define INFO_1(str, a)
#define INFO_2(str, a)
#define INFO_3(str, a)
#define INFO_4(str, a)
#define INFO_5(str, a)
#endif

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
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_parameters", [], [[]]] ];
		
		pr _veh = (_parameters select {_x select 0 == "vehicle"}) select 0 select 1;
		pr _vehRole = (_parameters select {_x select 0 == "vehicleRole"}) select 0 select 1;
		pr _turretPath = (_parameters select {_x select 0 == "turretPath"}) select 0 select 1;
		
		// Is _veh an object handle or a Unit?
		if (_veh isEqualType objNull) then {
			SETV(_thisObject, "hVeh", _veh);
			pr _unitVeh = CALL_STATIC_METHOD("Unit", "getUnitFromObjectHandle", [_veh]);
			SETV(_thisObject, "unitVeh", _unitVeh);
		} else {
			SETV(_thisObject, "unitVeh", _veh);
			pr _hVeh = CALLM0(_veh, "getObjectHandle");
			SETV(_thisObject, "hVeh", _hVeh);
		};
		SETV(_thisObject, "vehRole", _vehRole);
		if (_vehRole == "TURRET") then {
			SETV(_thisObject, "turretPath", _turretPath);
		};
	} ENDMETHOD;
	
	
	/*
	Method: assignVehicle
	Description
	
	Access: private
	
	Returns: bool
	*/
	METHOD("assignVehicle") {
		params [["_thisObject", "", [""]]];
		
		pr _vehRole = GETV(_thisObject, "vehRole");
		pr _AI = GETV(_thisObject, "AI");
		pr _unitVeh = GETV(_thisObject, "unitVeh");
		
		OOP_INFO_2("Asigning vehicle: %1, role: %2", _unitVeh, _vehRole);
		
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
				pr _turretPath = GETV(_thisObject, "turretPath");
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
				
				pr _hVeh = GETV(_thisObject, "hVeh");
				pr _hO = GETV(_thisObject, "hO");
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
				pr _chosenCargoSeat = GETV(_thisObject, "chosenCargoSeat");
				
				// Choose a new cargo seat
				if (count _freeSeats == 0) then {
					// No room for this soldier in the vehicle
					// Mission failed
					// We are dooomed!
					
					// Return
					false
				} else { // if count free seats == 0
					pr _chosenSeat = selectRandom _freeSeats;
					_chosenSeat params ["_seatUnit", "_seatRole", "_seatCargoIndex", "_seatTurretPath"]; //, "_seatPersonTurret"];
					if (_seatRole == "cargo") then {
						SETV(_thisObject, "chosenCargoSeat", _seatCargoIndex);
						pr _success = CALLM2(_AI, "assignAsCargoIndex", _unitVeh, _seatCargoIndex);
						
						// Return
						_success
					} else {
						SETV(_thisObject, "chosenCargoSeat", _seatTurretPath);
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
		
	} ENDMETHOD;
	
	/*
	Method: seatIsOccupied
	Returns true if the chosen cargo seat is occupied by a different unit
	
	Access: private
	
	Returns: bool
	*/
	METHOD("seatIsOccupied") {
		params [["_thisObject", "", [""]]];
		
		pr _vehRole = GETV(_thisObject, "vehRole");
		pr _hVeh = GETV(_thisObject, "hVeh");
		pr _hO = GETV(_thisObject, "hO");
		
		switch (_vehRole) do {	
			case "DRIVER": {
				pr _driver = driver _hVeh;
				if (!(isNull _driver) && !(_driver isEqualTo _hO)) then {
					// Return
					true
				} else {
					// Return
					false
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
				pr _turretPath = GETV(_thisObject, "turretPath");
				pr _turretSeat = (fullCrew [_hVeh, "", true]) select {_x select 3 isEqualTo _turretPath};
				pr _turretOperator = _turretSeat select 0 select 0;
				if ((alive _turretOperator) && !(_turretOperator isEqualTo _hO)) then {
					// Return
					true
				} else {
					// Return
					false
				};
			};
			case "CARGO" : {
				/* FulLCrew output: Array - format:
				0: <Object>unit
				1: <String>role
				2: <Number>cargoIndex (see note in description)
				3: <Array>turretPath
				4: <Boolean>personTurret */
				
				pr _chosenCargoSeat = GETV(_thisObject, "chosenCargoSeat");
				if (_chosenCargoSeat isEqualType 0) then { // If it's a cargo index
					pr _cargoIndex = _chosenCargoSeat;
					pr _cargoSeat = (fullCrew [_hVeh, "cargo", true]) select {_x select 2 isEqualTo _cargoIndex};
					pr _cargoOperator = _cargoSeat select 0 select 0;
					if ((alive _cargoOperator) && !(_cargoOperator isEqualTo _hO)) then {
						// Return
						true
					} else {
						// Return
						false
					};
				} else { // If it's an FFV turret path
					pr _turretPath = _chosenCargoSeat;
					pr _turretSeat = (fullCrew [_hVeh, "Turret", true]) select {_x select 3 isEqualTo _turretPath};
					pr _turretOperator = _turretSeat select 0 select 0;
					if ((alive _turretOperator) && !(_turretOperator isEqualTo _hO)) then {
						// Return
						true
					} else {
						// Return
						false
					};
				};
			}; // case
			
			default {
				diag_log format ["[ActionUnitGetInVehicle] Error: unknown vehicle role: %1", _vehRole];
				false
			};
		}; // switch
		
	} ENDMETHOD;
	
	
	/*
	Method: atAssignedSeat
	Checks if the unit is currently at the assigned vehicle seat
	
	Access: private
	
	Returns: bool
	*/
	METHOD("isAtAssignedSeat") {
		params [["_thisObject", "", [""]]];
		
		pr _vehRole = GETV(_thisObject, "vehRole");
		pr _hVeh = GETV(_thisObject, "hVeh");
		pr _hO = GETV(_thisObject, "hO");
		
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
				pr _turretPath = GETV(_thisObject, "turretPath");
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
				
				pr _chosenCargoSeat = GETV(_thisObject, "chosenCargoSeat");
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
	} ENDMETHOD;
	
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];
		
		pr _hO = GETV(_thisObject, "hO");
		pr _hVeh = GETV(_thisObject, "hVeh");
		
		// Insta-fail if vehicle is destroyed
		if (!alive _hVeh) exitWith {
			INFO_0("Failed to ACTIVATE: vehicle is destroyed");
			SETV(_thisObject, "state", ACTION_STATE_FAILED);
			ACTION_STATE_FAILED
		};
		
		/*
		if ((vehicle _hO isEqualTo _hVeh) && (CALLM0(_thisObject, "isAtAssignedSeat"))) then {
			// We are done here
			SETV(_thisObject, "state", ACTION_STATE_COMPLETED);
			ACTION_STATE_COMPLETED
		} else {
		*/
			// Assign vehicle
			pr _success = CALLM0(_thisObject, "assignVehicle");
			if (_success) then {
				INFO_0("ACTIVATEd successfully");
				
				// Calculate ETA
				pr _hO = T_GETV("hO");
				pr _hVeh = T_GETV("hVeh");
				pr _ETA = time + ((_hO distance _hVeh)/1.4 + 40);
				INFO_1("Set ETA: %1", _ETA);
				T_SETV("ETA", _ETA);
				
				SETV(_thisObject, "state", ACTION_STATE_ACTIVE);
				// Return ACTIVE state
				ACTION_STATE_ACTIVE
			} else {
				INFO_0("Failed to ACTIVATE");
				
				// Failed to assign vehicle
				SETV(_thisObject, "state", ACTION_STATE_FAILED);
				ACTION_STATE_FAILED
			};
		//};
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		pr _AI = GETV(_thisObject, "AI");
		pr _state = CALLM(_thisObject, "activateIfInactive", []);
		
		if (_state == ACTION_STATE_ACTIVE) then {
			
			pr _hVeh = GETV(_thisObject, "hVeh");
			pr _hO = GETV(_thisObject, "hO");
			pr _vehRole = GETV(_thisObject, "vehRole");
			pr _unitVeh = T_GETV("unitVeh");
			
			INFO_2("PROCESS: State is ACTIVE. Assigned vehicle: %1, role: %2", _unitVeh, _vehRole);
			
			// Check if the seat is occupied by someone else
			if (CALLM0(_thisObject, "seatIsOccupied")) then {
				INFO_0("Seat is occupied");
				if (_vehRole == "CARGO") then {// If it's cargo seat, try to chose a new one
					pr _success = CALLM0(_thisObject, "assignVehicle");
					if (_success) then {
						INFO_0("Assigned new seat");
						// Execute vehicle assignment
						CALLM0(_AI, "executeVehicleAssignment");
						// If the unit is already in the new vehicle, move him instantly
						if (vehicle _hO isEqualTo _hVeh) then {
							CALLM0(_AI, "moveInAssignedVehicle");
						} else {
							// Order get in
							[_hO] orderGetIn true;
						};
					
						SETV(_thisObject, "state", ACTION_STATE_ACTIVE);
						// Return ACTIVE state
						ACTION_STATE_ACTIVE
					} else {
						// Failed to assign vehicle
						INFO_0("Failed to assign a new seat");
						SETV(_thisObject, "state", ACTION_STATE_FAILED);
						ACTION_STATE_FAILED
					};
				} else {
					// Can't choose another driver or turret or gunner seat
					// Action is failed
					INFO_0("Failed to assign a new seat");
					SETV(_thisObject, "state", ACTION_STATE_FAILED);
					ACTION_STATE_FAILED
				};
			} else { // if seat is occupied
				// Assigned seat is not occupied
				
				INFO_0("Assigned seat is FREE");
				
				// Check if the unit is already in the required vehicle
				if (vehicle _hO isEqualTo _hVeh) then {
					INFO_0("Inside assigned vehicle");
				
					// Execute vehicle assignment
					CALLM0(_AI, "executeVehicleAssignment");
				
					// Check if the unit is in the required seat
					if (CALLM0(_thisObject, "isAtAssignedSeat")) then {
						INFO_0("Arrived at assigned seat");
						
						// We're done here
						SETV(_thisobject, "state", ACTION_STATE_COMPLETED);
						ACTION_STATE_COMPLETED
					} else {
						INFO_0("Sitting at wrong seat. Changine seats.");
						// We're in the right vehicle but at the wrong seat
						// Just swap seats instantly
						CALLM0(_AI, "moveInAssignedVehicle");
						ACTION_STATE_ACTIVE
					};
				} else {
					// If the unit is on foot now
					if (vehicle _hO isEqualTo _hO) then {						
						INFO_0("Not in vehicle yet. Going on ...");
					
						// Execute vehicle assignment
						CALLM0(_AI, "executeVehicleAssignment");
						// Order get in
						[_hO] orderGetIn true;
						
						// Check ETA
						pr _ETA = T_GETV("ETA");
						INFO_2("Time: %1, ETA: %2", time, _ETA);
						if(time > _ETA) then {
							// FFS why did you get stuck again??
							// When are BIS going to repair their fucking AIs stucking in the middle of fucking nowhere?
							// Let's just teleport you, buddy :/
							INFO_0("Exceeded ETA. Teleporting unit.");
							CALLM0(_AI, "moveInAssignedVehicle");
						};
					} else {
						INFO_0("In WRONG vehicle. Getting out.");
						doGetOut _hO;
					};
					
					ACTION_STATE_ACTIVE
				};
			}; // else
		} else { // state == active
			_state
		};
	} ENDMETHOD;
	
	// logic to run when the goal is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
	} ENDMETHOD; 

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