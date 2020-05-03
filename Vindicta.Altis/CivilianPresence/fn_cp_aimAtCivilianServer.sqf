// Called on server when someone is aiming at a civilian

params ["_civ", "_threat"]; // Both are object handles

// Just set variable, FSM will do the rest
_civ setVariable ["#aimedAt", true];