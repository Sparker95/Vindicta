#include "common.hpp"

/*
Class: ActionUnit.ActionUnitInfantryMoveBase
Base action for movement. Has only activate, terminate, process implemented.
*/

//#define TOLERANCE 1.0

#define OOP_CLASS_NAME ActionUnitInfantryMoveBase
CLASS("ActionUnitInfantryMoveBase", "ActionUnit")

	VARIABLE("pos");
	VARIABLE("ETA");
	VARIABLE("tolerance"); // completion radius
	VARIABLE("teleport"); // If true, unit will be teleported if ETA is exceeded
	VARIABLE("duration"); // Time to wait at the destination before considering the action complete, -1 for never complete
	VARIABLE("timeToComplete");

	// ------------ N E W ------------
	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		T_SETV("tolerance", 1.0); // Default tolerance value

		private _teleport = CALLSM3("Action", "getParameterValue", _parameters, "teleport", false);
		T_SETV("teleport", _teleport);

		private _duration = CALLSM3("Action", "getParameterValue", _parameters, TAG_DURATION_SECONDS, 0);
		T_SETV("duration", _duration);

		T_SETV("timeToComplete", 0);
	ENDMETHOD;

	// logic to run when the goal is activated
	METHOD(activate)
		params [P_THISOBJECT, P_BOOL("_instant")];

		// Handle AI just spawned state
		private _AI = T_GETV("AI");
		if (_instant) then {
			// Teleport the unit to where it needs to be
			private _hO = T_GETV("hO");
			private _pos = T_GETV("pos");
			_ho setPos _pos;
			doStop _hO;

			// Set state
			T_SETV("state", ACTION_STATE_COMPLETED);

			// Return completed state
			ACTION_STATE_COMPLETED
		} else {
			private _hO = T_GETV("hO");
			private _pos = T_GETV("pos");
			_hO doMove _pos;

			// Set ETA
			private _dist = _hO distance2D _pos;
			private _ETA = GAME_TIME + _dist + 60;
			T_SETV("ETA", _ETA);

			// Set state
			T_SETV("state", ACTION_STATE_ACTIVE);

			// Return ACTIVE state
			ACTION_STATE_ACTIVE
		};

	ENDMETHOD;
	
	// logic to run each update-step
	METHOD(process)
		params [P_THISOBJECT];
		
		private _state = T_CALLM0("activateIfInactive");
		
		if (_state == ACTION_STATE_ACTIVE) then {
			// Check if we have arrived
			private _hO = T_GETV("hO");
			private _pos = T_GETV("pos");

			private _timeToComplete = T_GETV("timeToComplete");
			switch true do {
				// We have arrived
				case (_timeToComplete == 0 && { (_hO distance _pos) < T_GETV("tolerance") }): {
					// If duration is < 0 then we never complete this action
					doStop _hO;
					private _duration = T_GETV("duration");
					switch true do {
						case (_duration > 0): {
							// Wait around until the requested wait duration has passed
							T_SETV("timeToComplete", GAME_TIME + T_GETV("duration"))
						};
						case (_duration == 0): {
							// Complete immediately as no wait time was requested
							_state = ACTION_STATE_COMPLETED;
						};
						case (_duration < 0): {
							// Set state so that no condition in the switch statement will fire again
							T_SETV("timeToComplete", -1);
						};
					};
				};
				// Teleport the unit if ETA is exceeded and teleportation is allowed
				case (_timeToComplete == 0 && { GAME_TIME > T_GETV("ETA") && T_GETV("teleport") }): {
					OOP_WARNING_2("MOVE FAILED for infantry unit: %1, position: %2", _thisObject, _pos);
					_ho setPos _pos;
					doStop _hO;
				};
				// We passed the wait time, so complete now
				case (_timeToComplete > 0 && { GAME_TIME > _timeToComplete }): {
					OOP_INFO_1("MOVE COMPLETED for infantry: %1", _thisObject);
					_state = ACTION_STATE_COMPLETED;
				};
			};
		};

		T_SETV("state", _state);
		_state
	ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD(terminate)
		params [P_THISOBJECT];
	ENDMETHOD;

ENDCLASS;