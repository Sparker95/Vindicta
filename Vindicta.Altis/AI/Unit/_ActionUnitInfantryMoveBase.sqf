#include "common.hpp"

/*
Class: ActionUnit.ActionUnitInfantryMoveBase
Base action for movement. Has only activate, terminate, process implemented.
*/

//#define TOLERANCE 1.0

#define OOP_CLASS_NAME ActionUnitInfantryMoveBase
CLASS("ActionUnitInfantryMoveBase", "ActionUnit")

	VARIABLE("targetPos");		// Last known position where to move
	VARIABLE("moveRadius");
	VARIABLE("ETA");
	VARIABLE("teleport"); // If true, unit will be teleported if ETA is exceeded
	VARIABLE("duration"); // Time to wait at the destination before considering the action complete, -1 for never complete
	VARIABLE("timeToComplete");
	VARIABLE("distRemaining"); // Remaining distance to go

	

	// ------------ N E W ------------
	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		pr _ai = T_GETV("ai");

		private _teleport = CALLSM3("Action", "getParameterValue", _parameters, TAG_TELEPORT, false);
		T_SETV("teleport", _teleport);

		private _duration = CALLSM3("Action", "getParameterValue", _parameters, TAG_DURATION_SECONDS, 0);
		T_SETV("duration", _duration);

		private _radius = CALLSM3("Action", "getParameterValue", _parameters, TAG_MOVE_RADIUS, 2); // Default tolerance
		CALLM1(_ai, "setMoveTargetRadius", _radius);
		T_SETV("moveRadius", _radius);

		private _moveTarget = GET_PARAMETER_VALUE(_parameters, TAG_MOVE_TARGET);
		private _buildingPosID = GET_PARAMETER_VALUE_DEFAULT(_parameters, TAG_BUILDING_POS_ID, -1);
		if (_buildingPosID == -1) then {
			CALLM1(_ai, "setMoveTarget", _moveTarget);
		} else {
			CALLM2(_ai, "setMoveTargetBuilding", _moveTarget, _buildingPosID);
		};

		// Update world state property related to movement
		// Because we will be using it to check if we have arrived
		CALLM0(_ai, "updatePositionWSP");

		pr _posTarget = CALLM0(_ai, "getMoveTargetPosAGL");
		T_SETV("targetPos", _posTarget);

		T_SETV("timeToComplete", 0);
		T_SETV("distRemaining", 9000);
	ENDMETHOD;

	// Returns bool: true if target pos has moved beyond moveRadius
	METHOD(updateTargetPos)
		params [P_THISOBJECT];
		pr _targetPos = T_GETV("targetPos");
		pr _ai = T_GETV("ai");
		pr _actualTargetPos = CALLM0(_ai, "getMoveTargetPosAGL");
		if ((_actualTargetPos distance _targetPos) > T_GETV("moveRadius")) then {
			T_SETV("targetPos", _targetPos);
			true;
		} else {
			false;
		};
	ENDMETHOD;

	// logic to run when the goal is activated
	METHOD(activate)
		params [P_THISOBJECT, P_BOOL("_instant")];

		// Handle AI just spawned state
		private _AI = T_GETV("AI");
		if (_instant) then {
			// Teleport the unit to where it needs to be
			private _hO = T_GETV("hO");
			pr _ai = T_GETV("ai");
			CALLM0(_ai, "instantMoveToTarget");
			doStop _hO;

			// Set state
			pr _ws = GETV(_ai, "worldState");
			WS_SET(_ws, WSP_UNIT_HUMAN_AT_TARGET_POS, true);
			T_SETV("state", ACTION_STATE_COMPLETED);

			// Return completed state
			ACTION_STATE_COMPLETED
		} else {
			private _hO = T_GETV("hO");
			private _targetPos = T_GETV("targetPos");

			// Order to move
			private _ai = T_GETV("ai");
			CALLM0(_ai, "orderMoveToTarget");

			// Set ETA
			private _dist = _hO distance2D _targetPos;
			private _ETA = GAME_TIME + 3*_dist + 60;
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
			private _dist = _hO distance _pos;
			private _ai = T_GETV("ai");
			private _ws = GETV(_ai, "worldState");
			private _atTargetPos = WS_GET(WSP_UNIT_HUMAN_AT_TARGET_POS);
			T_SETV("distRemaining", _dist);

			// Check if target pos has changed
			pr _targetPosChanged = T_CALLM0("updateTargetPos");
			pr _targetPos = T_GETV("targetPos");

			// Bail if target is invalid (wtf?)
			if (_targetPos isEqualTo [0,0,0]) exitWith {
				// Target is invalid!
				T_SETV("state", ACTION_STATE_FAILED);
				_state = ACTION_STATE_FAILED;
			};

			// Order to move to new pos if pos has changed much
			if (_targetPosChanged) then {
				T_CALLM0("activate"); // Reactivate
				_state = ACTION_STATE_ACTIVE;
			} else {
				switch true do {
					// We have arrived
					case (_timeToComplete == 0 && _atTargetPos): {
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
						CALLM0(_ai, "instantMoveToTarget");
						doStop _hO;
					};
					// We passed the wait time, so complete now
					case (_timeToComplete > 0 && { GAME_TIME > _timeToComplete }): {
						OOP_INFO_1("MOVE COMPLETED for infantry: %1", _thisObject);
						_state = ACTION_STATE_COMPLETED;
					};
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

	METHOD(getDebugUIVariableNames)
		["pos", "ETA", "timeToComplete", "distRemaining"]
	ENDMETHOD;

ENDCLASS;