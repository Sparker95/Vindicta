/*
Resolves if a given unit can start a new conversation.

Unit is already not dead and not null when this function is called.

Must be run at server.
Must return a bool.
*/

if (!isServer) exitWith {
	diag_log "[Dialogue] Error: dialogue_canTalk must be called on server!";
};

params [["_unit", objNull, [objNull]]];

if (_unit isKindOf "CAManBase") then {
	// We have several options
	// Units (Unit class)
	// Civilians (Civilian class)
	// ...

	private _objCivilian = CALLSM1("Civilian", "getCivilianFromObjectHandle");
	private _objUnit = CALLSM1("Unit", "getUnitFromObjectHandle");

	private _aiHuman = NULL_OBJECT;
	
	if (!IS_NULL_OBJECT(_objCivilian)) then {
		_aiHuman = CALLM0(_objCivilian, "getAI");
	};

	if (!IS_NULL_OBJECT(_objUnit)) then {
		_aiHuman = CALLM0(_objUnit, "getAI");
	};

	if (IS_NULL_OBJECT(_aiHuman)) then {
		false;
	} else {
		CALLM0(_aiHuman, "canStartNewConversation");
	};
} else {
	// WTF
	false;
};