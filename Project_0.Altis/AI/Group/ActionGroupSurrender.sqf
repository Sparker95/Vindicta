#include "common.hpp"

/*
Class: ActionGroup.ActionGroupSurrender
*/

CLASS("ActionGroupSurrender", "ActionGroup")

	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];

		private _hG = GETV(_thisObject, "hG");

		_hG setBehaviour "CARELESS";
		_hG setCombatMode "BLUE"; // Never fire, engage at will
		{ [_x] spawn misc_fnc_actionDropAllWeaponsAndSurrender; } forEach (units _hG);

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
