
#define OOP_INFO
#define OOP_ERROR
#define OOP_WARNING
#define OOP_DEBUG
#define IS_TARGET_ARRESTED_UNCONSCIOUS_DEAD !(alive _target) || (animationState _target == "unconsciousoutprone") || (animationState _target == "unconsciousfacedown") || (animationState _target == "unconsciousfaceup") || (animationState _target == "Acts_ExecutionVictim_Loop")
#include "common.hpp"

/*
Class: Action.ActionUnitShootLegTarget
Makes a single unit shoot near a target like a warning shot with a chance of hitting leg

Parameters:
"target" - object handle of the target to shoot near
*/
#define pr private

CLASS("ActionUnitShootLegTarget", "ActionUnit")

	VARIABLE("target");
	VARIABLE("objectHandle");
	VARIABLE("countAmmo");

	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_target", objNull, [objNull]] ];

		pr _a = GETV(_AI, "agent");
		pr _oh = CALLM0(_a, "getObjectHandle");
		pr _count = _oh ammo primaryWeapon _oh;

		T_SETV("objectHandle", _oh);
		T_SETV("countAmmo", _count);
		T_SETV("target", _target);
	} ENDMETHOD;

	METHOD("activate") {
		params [["_thisObject", "", [""]]];
		
		pr _oh = T_GETV("objectHandle");
		pr _target = T_GETV("target");
		pr _posUnit = getPos _oh;

		_oh reveal _target;
		_oh setSpeedMode "FULL";
		_oh setBehaviour "CARELESS";
		
		T_SETV("state", ACTION_STATE_ACTIVE);
		ACTION_STATE_ACTIVE
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];

		CALLM0(_thisObject, "activateIfInactive");

		pr _oh = T_GETV("objectHandle");
		pr _oldCount = T_GETV("countAmmo");
		pr _count = _oh ammo primaryWeapon _oh;

		if (_count < _oldCount - 1) exitWith {
			T_SETV("state", ACTION_STATE_COMPLETED);
			ACTION_STATE_COMPLETED
		};

		pr _target = T_GETV("target");
		pr _posUnit = getPos _oh;
		pr _posTarget = getPos _target;

		if (IS_TARGET_ARRESTED_UNCONSCIOUS_DEAD) exitWith {
			T_SETV("state", ACTION_STATE_COMPLETED);
			ACTION_STATE_COMPLETED
		};

		if ((_posUnit distance2D _posTarget) < 50) then {
			pr _fakeTarget = "FireSectorTarget" createVehicle (getpos _target);
			_fakeTarget attachto [_target, [0, 0, 0], "leftleg"];
			_fakeTarget hideObject true;

			_oh disableAI "autotarget";
			_oh disableAI "target";
			_oh setBehaviour "combat";
			_oh reveal [_fakeTarget, 1];
			_oh doTarget _fakeTarget;
			sleep 0.5;
			// add check to not fire GL or anything other than bullets
			_oh doFire _fakeTarget;
			sleep 0.5;
			_oh forceWeaponFire [weaponState _oh select 1, weaponState _oh select 2];

			waitUntil { 
				_oldCount - 1 >= (_oh ammo primaryWeapon _oh) ||
				(_posUnit distance2D _posTarget) > 150 ||
				!(alive _target) ||
				IS_TARGET_ARRESTED_UNCONSCIOUS_DEAD
			};

			deleteVehicle _fakeTarget;
			_oh enableAI "target";
			_oh enableAI "autotarget";
			
			if (_oldCount - 1 <= (_oh ammo primaryWeapon _oh)) exitWith {
				T_SETV("state", ACTION_STATE_COMPLETED);
				ACTION_STATE_COMPLETED
			};
		} else {
			_oh doMove _posTarget;
		};

		ACTION_STATE_ACTIVE
	} ENDMETHOD;
ENDCLASS;