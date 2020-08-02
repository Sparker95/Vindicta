#include "common.hpp"

/*
Class: ActionUnit.ActionUnitSurrender
*/

#define pr private

#define OOP_CLASS_NAME ActionUnitSurrender
CLASS("ActionUnitSurrender", "ActionUnit")
		
	// logic to run when the goal is activated
	protected override METHOD(activate)
		params [P_THISOBJECT];

		private _hO = T_GETV("hO");
		_hO spawn{
			sleep random 6;
			doStop _this;
			_this call misc_fnc_actionDropAllWeapons;
			_this action ["Surrender", _this];
		};

		// Set state
		T_SETV("state", ACTION_STATE_ACTIVE);

		// Return ACTIVE state
		ACTION_STATE_ACTIVE
	ENDMETHOD;
	
	// logic to run each update-step
	public override METHOD(process)
		params [P_THISOBJECT];
		T_CALLM0("activateIfInactive");
		
		ACTION_STATE_COMPLETED
	ENDMETHOD;

	public override METHOD(terminate)
		params [P_THISOBJECT];

		// TODO: when side system will be done need to check if unit is friendly or ennemy
		private _hO = T_GETV("hO");
		[_hO, {
			if (!hasInterface) exitWith {};
			params ["_hO"];
			private _id = _hO addAction [(("<img image='a3\ui_f\data\GUI\Rsc\RscDisplayMain\profile_player_ca.paa' size='1' color = '#FFFFFF'/>") + ("<t size='1' color = '#FFFFFF'> Recruit</t>")), "SideStat\askSurrenderedUnitToJoin.sqf", "", 1, true, true];
		}] remoteExec ["spawn", 0, false];
	ENDMETHOD;
	
ENDCLASS;
