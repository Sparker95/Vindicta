#include "common.hpp"
/*
The vehicle will unflip itself
Author: Sparker 14.02.2019
*/

#define pr private

#define OOP_CLASS_NAME ActionUnitVehicleUnflip
CLASS("ActionUnitVehicleUnflip", "ActionUnit")
	
	VARIABLE("torque"); // Torque which will be applied to vehicle to unflip it
	VARIABLE("time");
	VARIABLE("counter"); // Holds the amount of tries to unflip it
	
	// ------------ N E W ------------
	
	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI") ];
		
		OOP_INFO_0("NEW");
		
		pr _hO = T_GETV("hO");
		
		// Set initial value for torque
		pr _torque = (getMass _hO) * 2;
		T_SETV("torque", _torque);
		
		T_SETV("time", GAME_TIME);
		T_SETV("counter", 0);
	ENDMETHOD;
	
	// logic to run when the goal is activated
	protected override METHOD(activate)
		params [P_THISOBJECT];

		pr _hO = T_GETV("hO");
		
		pr _state = ACTION_STATE_ACTIVE;
		if (! ([_hO] call misc_fnc_isVehicleFlipped)) then {
			_state = ACTION_STATE_COMPLETED;
			OOP_INFO_0("COMPLETED IN ACTIVATE");
		};
		
		T_SETV("state", _state);
		_state
	ENDMETHOD;
	
	// logic to run each update-step
	public override METHOD(process)
		params [P_THISOBJECT];
		
		OOP_INFO_0("PROCESS");
		
		pr _state = T_CALLM0("activateIfInactive");
		
		if (_state == ACTION_STATE_ACTIVE) then {
		
			pr _time = T_GETV("time");
			if (GAME_TIME - _time > 4) then { // Make sure enough time has passed between process calls
				
				pr _hO = T_GETV("hO");
				if ([_hO] call misc_fnc_isVehicleFlipped) then {
					pr _counter = T_GETV("counter");
					if (_counter > 1) then {
						// Too many attempts already
						_hO setVectorUp [0, 0, 1];
						_hO setVehiclePosition [ZERO_HEIGHT(getPos _hO), [], 10, "NONE"];
					} else {
						pr _torque = T_GETV("torque");
						OOP_INFO_1("torque: %1", _torque);
						// Check if we need to roll the vehicle left or right
						//pr _vOrth = _hO vectorModelToWorld [1, 0, 0]; // Vector orthogonal to vectorDir and vectorUp
						//pr _rollDirection = (_vOrth select 2) > 0;
						//if (_rollDirection) then {_torque = -_torque;};
						
						// Try to roll the vehicle
						_hO addTorque (_hO vectorModelToWorld [0,_torque,0]);
						
						// Try to make it jump
						pr _mass = getMass _hO;
						_hO addForce [[0, 0, _mass*(4+random 2)], getCenterOfMass _hO];
						
						// Increase the torque if this one doesn't help
						T_SETV("torque", -3*_torque);
					};
					T_SETV("counter", _counter + 1);
				} else {
					// We have flipped the vehicle!
					_state = ACTION_STATE_COMPLETED;
				};
				
				T_SETV("time", GAME_TIME);
			};
		};
		
		T_SETV("state", _state);
		_state
	ENDMETHOD;
	
	// logic to run when the goal is satisfied
	public override METHOD(terminate)
		params [P_THISOBJECT];
	ENDMETHOD;

ENDCLASS;