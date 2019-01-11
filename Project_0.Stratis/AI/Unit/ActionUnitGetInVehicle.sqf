#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\Action\Action.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"
#include "..\Stimulus\Stimulus.hpp"
#include "..\WorldFact\WorldFact.hpp"
#include "..\stimulusTypes.hpp"
#include "..\worldFactTypes.hpp"

/*
Makes a unit get into a specific vehicle.
Assumes the vehicle is on foot already.
*/

#define pr private

CLASS("ActionUnitGetInVehicle", "ActionUnit")

	VARIABLE("hVeh");
	VARIABLE("vehRole");
	VARIABLE("turretPath");
	
	// Cargo index or turret path array
	VARIABLE("chosenCargoSeat");
	
	// ------------ N E W ------------
	// _vehHandle - objectHandle of the vehicle to get in
	// _vehRole - one of "DRIVER", "GUNNER", "COMMANDER", "TURRET", "CARGO_OR_FFV"
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_vehHandle", objNull, [objNull]], ["_vehRole", "", [""]], ["_turretPath", []] ];
		SETV(_thisObject, "hVeh", _vehHandle);
		SETV(_thisObject, "vehRole", _vehRole);
		if (_vehRole == "TURRET") then {
			SETV(thisObject, "turretPath", _turretPath);
		};
	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];
		
		pr _hO = GETV(_thisObject, "hO");
		pr _hVeh = GETV(_thisObject, "hVeh");
		
		if (vehicle _hO isEqualTo _hVeh) then {
			// We are done here
			SETV(_thisObject, "state", ACTION_STATE_COMPLETED);
			ACTION_STATE_COMPLETED
		} else {
			// Unassign vehicle
			unassignvehicle _hO;
			// Set state
			SETV(_thisObject, "state", ACTION_STATE_ACTIVE);
			// Return ACTIVE state
			ACTION_STATE_ACTIVE
		};
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		pr _state = CALLM(_thisObject, "activateIfInactive", []);
		
		if (_state == ACTION_STATE_ACTIVE) then {
			pr _hVeh = GETV(_thisObject, "hVeh");
			pr _hO = GETV(_thisObject, "hO");
			
			if (vehicle _hO isEqualTo _vehRole) then {
				SETV(_thisobject, "state", ACTION_STATE_COMPLETED);
				ACTION_STATE_COMPLETED
			} else {
				pr _vehRole = GETV(_thisObject, "vehRole");
				switch (_vehRole) do {	
				/*
				[[hemttD,"driver",-1,[],false],
				[B Alpha 1-1:5,"cargo",0,[],false],[B Alpha 1-1:4,"cargo",1,[],false],[B Alpha 1-1:6,"cargo",2,[],false],[B Alpha 1-1:2,"Turret",7,[0],true],[B Alpha 1-1:3,"Turret",15,[1],true]]
				
				[[B Alpha 1-1:5,"cargo",0,[],false],[B Alpha 1-1:4,"cargo",1,[],false],[B Alpha 1-1:6,"cargo",2,[],false],[<NULL-object>,"cargo",3,[],false],[<NULL-object>,"cargo",4,[],false],[<NULL-object>,"cargo",5,[],false],[<NULL-object>,"cargo",6,[],false],[<NULL-object>,"cargo",8,[],false],[<NULL-object>,"cargo",9,[],false],[<NULL-object>,"cargo",10,[],false],[<NULL-object>,"cargo",11,[],false],[<NULL-object>,"cargo",12,[],false],[<NULL-object>,"cargo",13,[],false],[<NULL-object>,"cargo",14,[],false],[<NULL-object>,"cargo",16,[],false]]
				
				[[B Alpha 1-1:5,"cargo",0,[],false],[B Alpha 1-1:4,"cargo",1,[],false],[B Alpha 1-1:6,"cargo",2,[],false],[<NULL-object>,"cargo",3,[],false],[<NULL-object>,"cargo",4,[],false],[<NULL-object>,"cargo",5,[],false],[<NULL-object>,"cargo",6,[],false],[<NULL-object>,"cargo",8,[],false],[<NULL-object>,"cargo",9,[],false],[<NULL-object>,"cargo",10,[],false],[<NULL-object>,"cargo",11,[],false],[<NULL-object>,"cargo",12,[],false],[<NULL-object>,"cargo",13,[],false],[<NULL-object>,"cargo",14,[],false],[<NULL-object>,"cargo",16,[],false]]
				*/
				
				
					case "DRIVER": {
						_hO assignAsDriver _hVeh;
						[_hO] orderGetIn true;
					};
					case "GUNNER" : {
						_hO assignAsGunner _hVeh;
						[_hO] orderGetIn true;					
					};
					case "COMMANDER" : {
						_hO assignAsCommander _hVeh; // todo
						[_hO] orderGetIn true;	
					};
					/*
					case "CARGO" : {
						_hO assignAsCargo _hVeh;
						[_hO] orderGetIn true;	
					};
					*/
					case "TURRET" : {
					};
					case "CARGO_OR_FFV" : {
						// FulLCrew output: Array - format [[<Object>unit,<String>role,<Number>cargoIndex (see note in description),<Array>turretPath,<Boolean>personTurret], ...]
						pr _freeCargoSeats = (fullCrew [_hVeh, "cargo", true]) select {isNull (_x select 0)};
						pr _freeFFVSeats = (fullCrew [_hVeh, "Turret", true]) select {(isNull {_x select 0}) && (_x select 4)}; // empty and person turret
						pr _freeSeats = _freeCargoSeats + _freeFFVSeats;
						pr _chosenCargoSeat = GETV(_thisObject, "chosenCargoSeat");
						
						// Do we need to choose a new cargo seat?
						pr _chooseNewSeat = false;
						if (isNil "_chosenCargoSeat") then { // If it's not chosen yet at all
							_chooseNewSeat = true;
						} else {
							// Check if the chosen seat is already occupied
							pr _alreadyOccupied = false;
							if (_chosenCargoSeat isEqualType []) then { // If it's turret
								if ((_freeFFVSeats findIf {(_x select 3) == _chosenCargoSeat}) == -1) then {
									_alreadyOccupied = true;
								};
							} else { // If it's cargo
								if ((_freeCargoSeats findIf {(_x select 2) == _chosenCargoSeat}) == -1) then {
									_alreadyOccupied = true;
								};
							};
							if (_alreadyOccupied) then {_chooseNewSeat = true;};
						};
						
						if (_chooseNewSeat) then {
							// Choose a new cargo seat
							if (count _freeSeats == 0) then {
								// No room for this soldier in the vehicle
								// Mission failed
								// We are dooomed!
								SETV(_thisObject, "state", ACTION_STATE_FAILED);
								ACTION_STATE_FAILED
							} else { // if count free seats == 0
								pr _chosenSeat = selectRandom _freeSeats;
								_chosenSeat params ["_seatUnit", "_seatRole", "_seatCargoIndex", "_seatTurretPath"]; //, "_seatPersonTurret"];
								if (_seatRole == "cargo") then {
									SETV(_thisObject, "chosenCargoSeat", _seatCargoIndex);
									_hO assignAsCargoIndex [_hVeh, _seatCargoIndex];
								} else {
									SETV(_thisObject, "chosenCargoSeat", _seatTurretPath);
									_hO assignAsTurret [_hVeh, _seatTurretPath];
								};
								
								[_hO] orderGetIn true;
								ACTION_STATE_ACTIVE
							}; // else
						} else { // isNil chosen cargo seat
							// Just order the unit to board his vehicle again
							if (_chosenCargoSeat isEqualType []) then { // If it's turret
								_hO assignAsTurret [_hVeh, _chosenCargoSeat];
							} else { // If it's cargo
								_hO assignAsCargoIndex [_hVeh, _chosenCargoSeat];
							};
							[_hO] orderGetIn true;
						};
					}; // case
				}; // switch
			};
		} else { // state == active
			_state
		};
	} ENDMETHOD;
	
	// logic to run when the goal is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
	} ENDMETHOD; 

ENDCLASS;