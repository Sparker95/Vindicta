// Called on client when he is aiming at a civ
params ["_civ", "_threat"]; // Both are object handles

//remember that the player scared a civilin, used for dialogue
_civ setVariable ["dialog_aimed_at",true];

[_civ, _threat] remoteExecCall ["pr0_fnc_cp_aimAtCivilianServer", 2, false];