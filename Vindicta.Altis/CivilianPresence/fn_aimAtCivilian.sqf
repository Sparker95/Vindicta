// Called on client when he is aiming at a civ
params ["_civ", "_threat"]; // Both are object handles

[_civ, _threat] remoteExecCall ["CivPresence_fnc_aimAtCivilianServer", 2, false];