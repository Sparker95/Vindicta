#include "common.hpp"

/*
Class: ActionUnit.ActionUnitInfantryMoveBase
Base action for movement. Has only activate, terminate, process implemented.
*/

#define pr private

//#define TOLERANCE 1.0

CLASS("ActionUnitInfantryMoveBase", "ActionUnit")
	
	VARIABLE("pos");
	VARIABLE("ETA");	
	VARIABLE("tolerance"); // completion radius
	VARIABLE("teleport"); // If true, unit will be teleported if ETA is exceeded
	
	// ------------ N E W ------------
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_parameters", [], [[]]] ];
		
		T_SETV("tolerance", 1.0); // Default tolerance value

		pr _teleport = CALLSM2("Action", "getParameterValue", _parameters, "teleport");
		if (isNil "_teleport") then {
			_teleport = false;
		};
		T_SETV("teleport", _teleport);
		
	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];
		
		// Handle AI just spawned state
		pr _AI = T_GETV("AI");
		if (GETV(_AI, "new")) then {
			// Teleport the unit to where it needs to be
			pr _hO = T_GETV("hO");
			pr _pos = T_GETV("pos");
			_ho setPos _pos;
			doStop _hO;

			// Set state
			SETV(_thisObject, "state", ACTION_STATE_COMPLETED);

			SETV(_AI, "new", false);

			// Return completed state
			ACTION_STATE_COMPLETED
		} else {
			pr _hO = T_GETV("hO");
			pr _pos = T_GETV("pos");
			_hO doMove _pos;
			
			// Set ETA
			// Use manhattan distance
			pr _posStart = ASLTOAGL (getPosASL _hO);
			pr _dist = (abs ((_pos select 0) - (_posStart select 0)) ) + (abs ((_pos select 1) - (_posStart select 1))) + (abs ((_pos select 2) - (_posStart select 2)));
			pr _ETA = time + (_dist/1.4 + 40);
			T_SETV("ETA", _ETA);
			
			// Set state
			SETV(_thisObject, "state", ACTION_STATE_ACTIVE);
			
			// Return ACTIVE state
			ACTION_STATE_ACTIVE
		};
		
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		pr _state = CALLM0(_thisObject, "activateIfInactive");
		
		if (_state == ACTION_STATE_ACTIVE) then {
		
			// Check if we have arrived
			pr _hO = T_GETV("hO");
			pr _pos = T_GETV("pos");
			
			if ((_hO distance _pos) < T_GETV("tolerance")) then {
				OOP_INFO_1("MOVE COMPLETED for infantry: %1", _thisObject);
			
				doStop _hO;
				
				T_SETV("state", ACTION_STATE_COMPLETED);
				ACTION_STATE_COMPLETED
			} else {
				// Check ETA
				pr _ETA = T_GETV("ETA");
				// Teleport the unit if ETA is exceeded and teleportation is allowed
				if ((time > _ETA) && T_GETV("teleport")) then {
					OOP_INFO_2("MOVE FAILED for infantry unit: %1, position: %2", _thisObject, _pos);
				
					// Should we teleport him or someone will blame AI for cheating??
					_ho setPos _pos;
					doStop _hO;
					
					ACTION_STATE_ACTIVE
				} else {
					ACTION_STATE_ACTIVE
				};
			};
			
		};
		_state
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
	} ENDMETHOD;

ENDCLASS;