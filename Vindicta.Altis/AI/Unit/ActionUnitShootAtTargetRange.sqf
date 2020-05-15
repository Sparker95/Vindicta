#include "common.hpp"

#define OOP_CLASS_NAME ActionUnitShootAtTargetRange
CLASS("ActionUnitShootAtTargetRange", "ActionUnit")

	VARIABLE("target");
	VARIABLE("duration");
	VARIABLE("spawnHandle");
	VARIABLE("safePosition");

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		private _target = CALLSM2("Action", "getParameterValue", _parameters, TAG_TARGET);
		T_SETV("target", _target);
		private _defaultDuration = selectRandom [5, 10, 20] * 60;
		private _duration = CALLSM3("Action", "getParameterValue", _parameters, TAG_DURATION_SECONDS, _defaultDuration);
		T_SETV("duration", _duration);
		T_SETV("spawnHandle", scriptNull);
	ENDMETHOD;

	METHOD(activate)
		params [P_THISOBJECT, P_BOOL("_instant")];

		private _target = T_GETV("target");
		_target setVariable ["vin_occupied", true];

		private _distDir = _target getVariable ["vin_target_range", []];

		if(!(_distDir isEqualTypeArray [0,0])) exitWith {
			OOP_ERROR_1("Target %1 does not have correct vin_target_range array (should be [distance, direction])", _target);
			T_SETV("state", ACTION_STATE_FAILED);
			ACTION_STATE_FAILED
		};
		_distDir params ["_dist", "_dir"];
		private _shootingPosition = _target getRelPos [_dist, _dir];
		private _safePosition = _target getRelPos [_dist * 1.2, _dir];
		T_SETV("safePosition", _safePosition);
		private _duration = T_GETV("duration");
		private _hO = T_GETV("hO");
		if(_instant) then {
			_hO setPos _shootingPosition;
		} else {
			_hO doMove _shootingPosition;
		};

		private _handle = [_hO, _target, _shootingPosition, _duration, _safePosition] spawn {
			params ["_hO", "_target", "_shootingPosition", "_duration", "_safePosition"];

			private _moveTimeOut = GAME_TIME + 120;
			waitUntil { _hO distance _shootingPosition <= 1 || GAME_TIME > _moveTimeOut };
			doStop _hO;

			private _fakeTarget = _target getVariable ["vin_fakeTarget", objNull];
			if(isNull _fakeTarget) then {
				private _targetCenter = getPos _target vectorAdd boundingCenter _target;
				_fakeTarget = createVehicle ["FireSectorTarget", _targetCenter, [], 0, "CAN_COLLIDE"];
				_fakeTarget hideObject true;
				_target setVariable ["vin_fakeTarget", _fakeTarget];
			};
			_hO disableAI "autotarget";
			_hO disableAI "autocombat";
			_hO disableAI "target";

			_hO reveal [_fakeTarget, 1];

			_hO setPos _shootingPosition;
			_hO setUnitPos selectRandom ["DOWN", "MIDDLE"];

			private _endTime = GAME_TIME + _duration;

			private _weaponsToUse = [];
			if(primaryWeapon _hO != "") then {
				_weaponsToUse append [primaryWeapon _hO, 4];
			};
			if(handgunWeapon _hO != "") then {
				_weaponsToUse append [handgunWeapon _hO, 1];
			};
			private _weaponToUse = selectRandomWeighted _weaponsToUse;

			// add check to not fire GL or anything other than bullets
			private _startingAmmo = _hO ammo _weaponToUse;
			while {_hO ammo _weaponToUse > 0 && GAME_TIME < _endTime} do {
				// Magic free ammo for now.
				// TODO: add rearm goal and action
				_hO setAmmo [_weaponToUse, _startingAmmo];

				_hO selectWeapon _weaponToUse;
				sleep 1;
				_hO glanceAt _fakeTarget;
				_hO lookAt _fakeTarget;
				_hO doWatch _fakeTarget;
				_hO doTarget _fakeTarget;
				sleep 0.5;
				private _shootingFromPos = _hO modelToWorldWorld (_hO selectionPosition ["head", "FireGeometry"]);
				private _stuffInTheWay = lineIntersectsSurfaces [_shootingFromPos, getPosASL _fakeTarget, _hO, _target];
				if(count _stuffInTheWay > 0) then {
					_hO playActionNow "GestureCeaseFire";
				} else {
					_hO setDir (_hO getDir _fakeTarget);
					[_hO, weaponState _hO # 1] call BIS_fnc_fire;
				};
				sleep (4 max random [-25, 5, 30]);
			};

			_hO setUnitPos "AUTO";
			_hO enableAI "autotarget";
			_hO enableAI "autocombat";
			_hO enableAI "target";
			_hO doMove _safePosition;
		};

		T_SETV("spawnHandle", _handle);

		T_SETV("state", ACTION_STATE_ACTIVE);
		ACTION_STATE_ACTIVE
	ENDMETHOD;

	// logic to run each update-step
	METHOD(process)
		params [P_THISOBJECT];

		private _state = T_CALLM0("activateIfInactive");
		if(_state == ACTION_STATE_ACTIVE) then {
			if (scriptDone T_GETV("spawnHandle")) then {
				_state = ACTION_STATE_COMPLETED;
			} else {
				_state = ACTION_STATE_ACTIVE;
			};
		};

		T_SETV("state", _state);
		_state
	ENDMETHOD;

	METHOD(terminate)
		params [P_THISOBJECT];

		// Mark the target as free for use
		private _target = T_GETV("target");
		_target setVariable ["vin_occupied", false];

		// Terminate the script
		private _spawnHandle = T_GETV("spawnHandle");
		if(!isNull _spawnHandle) then {
			terminate _spawnHandle;

			// Reset the unit
			private _hO = T_GETV("hO");
			if(!isNull _hO) then {
				_hO setUnitPos "AUTO";
				_hO enableAI "autotarget";
				_hO enableAI "autocombat";
				_hO enableAI "target";
				_hO doMove T_GETV("safePosition");
			};
		};
	ENDMETHOD;
ENDCLASS;
