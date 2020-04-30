#include "common.hpp"

// How much time it's allowed to stand at one place without being considered 'stuck'
#define TIMER_STUCK_THRESHOLD 30

#define SEPARATION 18

#define OOP_CLASS_NAME ActionUnitFollow
CLASS("ActionUnitFollow", "ActionUnit")

	VARIABLE("expectedDistance");
	VARIABLE("lastPos");
	VARIABLE("stuckTimer");
	VARIABLE("stuckCounter");
	VARIABLE("hTarget");

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		private _hTarget = CALLSM3("Action", "getParameterValue", _parameters, TAG_TARGET, objNull);
		T_SETV("hTarget", _hTarget);
	ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD(activate)
		params [P_THISOBJECT];

		private _hO = T_GETV("hO");
		private _hTarget = T_GETV("hTarget");
		if(isNull _hTarget) then {
			_hTarget = leader group _hO;
		};

		// Order to follow target
		_hO stop false;
		_hO doFollow _hTarget;

		// Get unit index in drivers list to determine expected distance we should be from the leader
		private _expectedDistance = if(vehicle _hO != _hO) then {
			private _index = 1 max (units group _hO select { vehicle _x != _x && { driver vehicle _x == _x } } find { _hO });
			SEPARATION * _index
		} else {
			30
		};

		T_SETV("expectedDistance", _expectedDistance);
		T_SETV("stuckTimer", GAME_TIME + TIMER_STUCK_THRESHOLD);
		T_SETV("lastPos", position _hO);
		T_SETV("stuckCounter", 0);

		T_SETV("state", ACTION_STATE_ACTIVE);
		ACTION_STATE_ACTIVE
	ENDMETHOD;

	// logic to run each update-step
	METHOD(process)
		params [P_THISOBJECT];

		private _hO = T_GETV("hO");
		private _hVeh = vehicle _hO;
		private _isInVehicle = _hVeh != _hO;

		// In a vehicle but not a driver so we don't need to do anything
		// We assume the vehicle driver is following the correct target
		if(_isInVehicle && {driver _hVeh != _hO}) exitWith {
			T_SETV("state", ACTION_STATE_ACTIVE);
			ACTION_STATE_ACTIVE
		};

		// This action isn't valid on leader, he can't follow himself
		if(leader _hO == _hO) exitWith {
			T_SETV("state", ACTION_STATE_FAILED);
			ACTION_STATE_FAILED
		};

		private _state = T_CALLM0("activateIfInactive");

		if (GAME_TIME > T_GETV("stuckTimer")) then {

			private _hTarget = T_GETV("hTarget");
			if(isNull _hTarget) then {
				_hTarget = leader group _hO;
			};
			private _lastPos = T_GETV("lastPos");
			T_SETV("lastPos", position _hVeh);

			// Are we making progress?
			private _expectedDistanceTravelled = if(_isInVehicle) then {
				TIMER_STUCK_THRESHOLD
			} else {
				3
			};

			private _expectedDistance = T_GETV("expectedDistance");
			if(_lastPos distance2D _hVeh < _expectedDistanceTravelled && _hVeh distance2D _hTarget > _expectedDistance * 2) then {
				if(_isInVehicle) then {
					T_CALLM1("bumpVehicle", _hVeh);
				};

				// Reissue the follow command
				_hO doFollow _hTarget;

				private _stuckCounter = T_GETV("stuckCounter");
				switch true do {
					case (_stuckCounter > 3): {
						// Try to doMove to position of the target (follow should resume afterwards)
						_hO doMove (position _hTarget);
					};
					case (_stuckCounter > 6): {
						// Teleport to target
						private _targetVehicle = vehicle _hTarget;
						private _newPos = if(_isInVehicle) then {
							private _defaultPos = position _targetVehicle vectorAdd (_targetVehicle modelToWorldWorld [0, -_expectedDistance, 0]);
							[_hVeh, 0, 50, 7, 0, 100, 0, [], [_defaultPos, _defaultPos]] call BIS_fnc_findSafePos
						} else {
							position _hTarget;
						};
						_hVeh setPos _newPos;
						_hVeh setDir direction _targetVehicle;

						// Reset stuck counter
						_stuckCounter = -1;
					};
				};

				T_SETV("stuckCounter", _stuckCounter + 1);
			};
			T_SETV("stuckTimer", GAME_TIME + TIMER_STUCK_THRESHOLD);
		};

		T_SETV("state", _state);
		_state
	ENDMETHOD;

	// logic to run when the goal is satisfied
	METHOD(terminate)
		params [P_THISOBJECT];

		// Stop moving
		doStop T_GETV("hO");
	ENDMETHOD;

ENDCLASS;