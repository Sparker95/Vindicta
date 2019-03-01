#include "common.hpp"

/*
Class: ActionGroup.ActionGroupSurrender
*/

CLASS("ActionGroupSurrender", "ActionGroup")

	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];

		private _hG = GETV(_thisObject, "hG");
		OOP_DEBUG_1("activate _thisObject: %1", _thisObject);

		// Set behaviour
		_hG setBehaviour "CARELESS";

		// Set combat mode
		_hG setCombatMode "BLUE"; // Never fire, engage at will

		// Surrender (leave weapon and animation surrender)
		{
			OOP_DEBUG_1("_unit: %1", _x);
			[_x] call misc_fnc_actionDropWeapon;
			sleep 1;
			_x action ["Surrender", _x];
		} forEach (units _hG);


		// Set state
		T_SETV("state", ACTION_STATE_ACTIVE);

		// Return ACTIVE state
		ACTION_STATE_ACTIVE

	} ENDMETHOD;

	// Logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		CALLM(_thisObject, "activateIfInactive", []);

		// Make sure they have no weapon and surrender animation
		private _state = T_GETV("state");
		_state;

		ACTION_STATE_COMPLETED
	} ENDMETHOD;

ENDCLASS;
