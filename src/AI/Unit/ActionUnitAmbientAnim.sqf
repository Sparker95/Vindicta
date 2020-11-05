#include "common.hpp"
FIX_LINE_NUMBERS()

#define OOP_CLASS_NAME ActionUnitAmbientAnim
CLASS("ActionUnitAmbientAnim", "ActionUnit")

	VARIABLE("target");
	VARIABLE("anims");
	VARIABLE("duration");
	VARIABLE("spawnHandle");
	VARIABLE("savedInventory");

	public override METHOD(getPossibleParameters)
		[
			[ [TAG_TARGET_AMBIENT_ANIM, [[], objNull]] ],	// Required parameters
			[ [TAG_DURATION_SECONDS, [0]], [TAG_ANIM, [""]] ]	// Optional parameters
		]
	ENDMETHOD;

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		private _target = CALLSM3("Action", "getParameterValue", _parameters, TAG_TARGET_AMBIENT_ANIM, []);
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

	protected override METHOD(activate)
		params [P_THISOBJECT, P_BOOL("_instant")];

		OOP_INFO_0("ACTIVATE");

		private _hO = T_GETV("hO");
		private _target = T_GETV("target");

		private _ai = T_GETV("AI");
		if (_target isEqualType objNull) then {
			SETV(_ai, "interactionObject", _target);
		} else {
			SETV(_ai, "interactionObject", _hO);		// Interacting with self
		};

		// We are not in formation any more
		// Reset world state property
		private _ws = GETV(T_GETV("ai"), "worldState");
		WS_SET(_ws, WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, false);

		// Fail if occupied
		if (_target isEqualType objNull && {_target getVariable ["vin_occupied", false]}) exitWith {
			OOP_INFO_0("Failed: target is occupied");
			T_SETV("state", ACTION_STATE_FAILED);
			ACTION_STATE_FAILED;
		};

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

		// Do these things here, to keep all in sync
		// If it's in spawned code, We don't know if vin_fnc_ambientAnim
		// has already run by the time we terminate the action 
		doStop _hO;
		_hO setPos _targetPos;
		//[_hO, [_hO, "vin_savedInventory"], [], false ] call BIS_fnc_saveInventory;
		//[[_hO, selectRandom _anims, "ASIS", _target], vin_fnc_ambientAnim] remoteExec ["call"];
		[_hO, selectRandom _anims, _target] call vin_fnc_ambientAnim;

		private _spawnHandle = [_hO, _target, _targetPos, _duration, _anims] spawn {
			params ["_hO", "_target", "_targetPos", "_duration", "_anims"];

			/*
			// Makes no sense any more, because movement is precondition ot this action
			private _moveTimeOut = GAME_TIME + 120;
			waitUntil {
				sleep 0.1;
				_hO distance _targetPos <= 3 || GAME_TIME > _moveTimeOut
			};
			*/
			
			private _endTime = GAME_TIME + _duration;

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
			//[_hO, [_hO, "vin_savedInventory"]] call BIS_fnc_loadInventory;
			//[_hO, [_hO, "vin_savedInventory"]] call BIS_fnc_deleteInventory;
		};

		T_SETV("spawnHandle", _spawnHandle);

		T_SETV("state", ACTION_STATE_ACTIVE);
		ACTION_STATE_ACTIVE
	ENDMETHOD;

	// logic to run each update-step
	public override METHOD(process)
		params [P_THISOBJECT];

		OOP_INFO_0("PROCESS");

		private _state = T_CALLM0("activateIfInactive");
		if(_state == ACTION_STATE_ACTIVE) then {
			if (scriptDone T_GETV("spawnHandle")) then {
				OOP_INFO_0("Script is done, action completed");
				CALLM1(T_GETV("ai"), "setHasInteractedWSP", true);
				_state = ACTION_STATE_COMPLETED;
			} else {
				_state = ACTION_STATE_ACTIVE;
			};
		};

		T_SETV("state", _state);
		_state
	ENDMETHOD;

	 public override METHOD(terminate)
	 	params [P_THISOBJECT];
		
		OOP_INFO_0("TERMINATE");

		// Mark the target as free for use
		private _target = T_GETV("target");
		if(_target isEqualType objNull) then {
			_target setVariable ["vin_occupied", false];
			_target setVariable ["vin_preoccupied", false];
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

		private _ai = T_GETV("ai");
		SETV(_ai, "interactionObject", objNull);
	 ENDMETHOD;
ENDCLASS;
