#include "common.hpp"
FIX_LINE_NUMBERS()

#define OOP_CLASS_NAME ActionUnitAmbientAnim
CLASS("ActionUnitAmbientAnim", "ActionUnit")

	VARIABLE("target");
	VARIABLE("anims");
	VARIABLE("duration");
	VARIABLE("spawnHandle");
	VARIABLE("savedInventory");

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		private _target = CALLSM3("Action", "getParameterValue", _parameters, TAG_TARGET, []);
		T_SETV("target", _target);
		private _defaultAnims = [_target getVariable ["vin_anim", "SIT_LOW"]];
		private _anims = CALLSM3("Action", "getParameterValue", _parameters, TAG_ANIM, _defaultAnims);
		T_SETV("anims", _anims);
		private _defaultDuration = selectRandom [5, 10, 20] * 60;
		private _duration = CALLSM3("Action", "getParameterValue", _parameters, TAG_DURATION_SECONDS, _defaultDuration);
		T_SETV("duration", _duration);
		T_SETV("spawnHandle", scriptNull);
		T_SETV("savedInventory", []);
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];
		
		// Mark the target as free for use
		private _target = T_GETV("target");
		if(_target isEqualType objNull) then {
			_target setVariable ["vin_occupied", false];
		};

		// Terminate the script
		private _spawnHandle = T_GETV("spawnHandle");
		if(!isNull _spawnHandle) then {
			terminate _spawnHandle;
		};

		// Reset the unit
		private _hO = T_GETV("hO");
		if(!isNull _hO) then {
			//[hO, vin_fnc_ambientAnim__terminate] remoteExec ["call"];

			_hO call vin_fnc_ambientAnim__terminate;

			private _savedInventory = T_GETV("savedInventory");
			if(!(_savedInventory isEqualTo [])) then {
				_hO setUnitLoadout _savedInventory;
			};
			// [_hO, [_hO, "vin_savedInventory"]] call BIS_fnc_loadInventory;
			// [_hO, [_hO, "vin_savedInventory"]] call BIS_fnc_deleteInventory;
		};
	ENDMETHOD;

	METHOD(activate)
		params [P_THISOBJECT, P_BOOL("_instant")];

		private _hO = T_GETV("hO");
		private _target = T_GETV("target");

		private _targetPos = switch true do {
			case (_target isEqualTo []): {
				position _hO
			};
			case (_target isEqualType []): {
				ZERO_HEIGHT(_target)
			};
			case (_target isEqualType objNull): {
				_target setVariable ["vin_occupied", true];
				position _target;
			};
		};

		private _duration = T_GETV("duration");
		if(_instant) then {
			_hO setPos _targetPos;
		} else {
			_hO doMove _targetPos;
		};

		private _anims = T_GETV("anims");

		T_SETV("savedInventory", getUnitLoadout _hO);
		private _spawnHandle = [_hO, _target, _targetPos, _duration, _anims] spawn {
			params ["_hO", "_target", "_targetPos", "_duration", "_anims"];

			private _moveTimeOut = GAME_TIME + 120;
			waitUntil {
				sleep 0.1;
				_hO distance _targetPos <= 3 || GAME_TIME > _moveTimeOut
			};
			doStop _hO;
			_hO setPos _targetPos;

			private _endTime = GAME_TIME + _duration;

			//[_hO, [_hO, "vin_savedInventory"], [], false ] call BIS_fnc_saveInventory;
			//[[_hO, selectRandom _anims, "ASIS", _target], vin_fnc_ambientAnim] remoteExec ["call"];
			[_hO, selectRandom _anims, _target] call vin_fnc_ambientAnim;

			waitUntil {
				sleep 0.1;
				_hO getVariable ["BIS_EhAnimDone", -1] > -1
			};

			waitUntil {
				sleep 0.1;
				_hO getVariable ["BIS_EhAnimDone", -1] == -1
					|| behaviour _hO == "combat"
					|| damage _hO > 0
					|| { _hO call BIS_fnc_enemyDetected }
			};
			//[_hO, vin_fnc_ambientAnim__terminate] remoteExec ["call"];
			_hO call vin_fnc_ambientAnim__terminate;
			//[_hO, [_hO, "vin_savedInventory"]] call BIS_fnc_loadInventory;
			//[_hO, [_hO, "vin_savedInventory"]] call BIS_fnc_deleteInventory;
		};

		T_SETV("spawnHandle", _spawnHandle);

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

	// METHOD(terminate)
	// 	params [P_THISOBJECT];
	// ENDMETHOD;
ENDCLASS;
