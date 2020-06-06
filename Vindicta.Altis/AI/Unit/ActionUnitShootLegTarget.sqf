#include "common.hpp"

#define IS_ARRESTED_UNCONSCIOUS_DEAD(target) (!alive (target) || {animationState (target) in ["unconsciousoutprone", "unconsciousfacedown", "unconsciousfaceup", "unconsciousrevivedefault", "acts_aidlpsitmstpssurwnondnon_loop", "acts_aidlpsitmstpssurwnondnon01"]})
/*
Class: Action.ActionUnitShootLegTarget
Makes a single unit shoot near a target like a warning shot with a chance of hitting leg

Parameters:
"target" - object handle of the target to shoot near
*/
#define pr private

#define OOP_CLASS_NAME ActionUnitShootLegTarget
CLASS("ActionUnitShootLegTarget", "ActionUnit")

	VARIABLE("target");
	VARIABLE("objectHandle");
	VARIABLE("countAmmo");
	VARIABLE("spawnHandle");
	VARIABLE("isHandleSpawned");
	VARIABLE("startSpawnedTime");

	public override METHOD(getPossibleParameters)
		[
			[ [TAG_TARGET_SHOOT_LEG, [objNull] ] ],	// Required parameters
			[ ]	// Optional parameters
		]
	ENDMETHOD;

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		pr _a = GETV(_AI, "agent");
		pr _oh = CALLM0(_a, "getObjectHandle");
		pr _count = _oh ammo primaryWeapon _oh;

		pr _target = CALLSM2("Action", "getParameterValue", _parameters, TAG_TARGET_SHOOT_LEG);

		T_SETV("isHandleSpawned", 0);
		T_SETV("spawnHandle", scriptNull);
		T_SETV("objectHandle", _oh);
		T_SETV("countAmmo", _count);
		T_SETV("target", _target);
	ENDMETHOD;

	protected override METHOD(activate)
		params [P_THISOBJECT];
		
		pr _oh = T_GETV("objectHandle");
		pr _target = T_GETV("target");
		pr _posUnit = getPos _oh;

		_oh reveal _target;
		_oh forceSpeed (-1);
		_oh setBehaviour "CARELESS";

		pr _ai = T_GETV("ai");
		SETV(_ai, "interactionObject", _target);

		// We are not in formation any more
		// Reset world state property
		pr _ws = GETV(T_GETV("ai"), "worldState");
		WS_SET(_ws, WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, false);

		T_SETV("state", ACTION_STATE_ACTIVE);
		ACTION_STATE_ACTIVE
	ENDMETHOD;
	
	// logic to run each update-step
	public override METHOD(process)
		params [P_THISOBJECT];

		T_CALLM0("activateIfInactive");

		pr _state = T_GETV("state");
		if (_state != ACTION_STATE_ACTIVE) exitWith {_state};

		pr _oh = T_GETV("objectHandle");
		pr _oldCount = T_GETV("countAmmo");
		pr _count = _oh ammo primaryWeapon _oh;

		if (_count < _oldCount - 1) exitWith {
			CALLM1(T_GETV("ai"), "setHasInteractedWSP", true);
			T_SETV("state", ACTION_STATE_COMPLETED);
			ACTION_STATE_COMPLETED
		};

		pr _target = T_GETV("target");
		pr _posUnit = getPos _oh;
		pr _posTarget = getPos _target;

		if (IS_ARRESTED_UNCONSCIOUS_DEAD(_target)) exitWith {
			CALLM1(T_GETV("ai"), "setHasInteractedWSP", true);
			T_SETV("state", ACTION_STATE_COMPLETED);
			ACTION_STATE_COMPLETED
		};

		if ((_posUnit distance2D _posTarget) < 40 ) then {
			if (T_GETV("isHandleSpawned") != 1) then {
				T_SETV("startSpawnedTime", GAME_TIME);
				pr _spawnedTime = T_GETV("startSpawnedTime");

				pr _handle = [_target, _oh, _oldCount, _posUnit, _posTarget, _spawnedTime] spawn {
					params ["_target", "_oh", "_oldCount", "_posUnit", "_posTarget", "_spawnedTime"];

					pr _fakeTarget = "FireSectorTarget" createVehicle (getpos _target);
					_fakeTarget attachto [_target, [0, 0, 0], "leftleg"];
					_fakeTarget hideObject true;
					doStop _oh;
					_oh disableAI "autotarget";
					_oh disableAI "target";
					_oh setBehaviour "combat";
					_oh reveal [_fakeTarget, 1];

					// add check to not fire GL or anything other than bullets
					_oh selectWeapon (primaryWeapon _oh);
					sleep 1;
					_oh doTarget _fakeTarget;
					sleep 0.5;
					_oh forceWeaponFire [weaponState _oh select 1, weaponState _oh select 2];

					waitUntil {
						_oldCount - 1 >= (_oh ammo primaryWeapon _oh) ||
						(_posUnit distance2D _posTarget) > 100 ||
						IS_ARRESTED_UNCONSCIOUS_DEAD(_target) ||
						GAME_TIME > (20 + _spawnedTime)
					};

					deleteVehicle _fakeTarget;
					_oh enableAI "target";
					_oh enableAI "autotarget";
					_oh setBehaviour "SAFE";
				};

				T_SETV("spawnHandle", _handle);
				T_SETV("isHandleSpawned", 1);
				ACTION_STATE_ACTIVE
			} else {				
				if (scriptDone T_GETV("spawnHandle")) then {
					CALLM1(T_GETV("ai"), "setHasInteractedWSP", true);
					ACTION_STATE_COMPLETED
				} else {
					ACTION_STATE_ACTIVE
				};
			};
		} else {
			_oh doMove _posTarget;
			ACTION_STATE_ACTIVE
		};
	ENDMETHOD;

	// logic to run when the goal is satisfied
	public override METHOD(terminate)
		params [P_THISOBJECT];
		pr _ai = T_GETV("AI");
		SETV(_ai, "interactionObject", objNull);
	ENDMETHOD;

ENDCLASS;
