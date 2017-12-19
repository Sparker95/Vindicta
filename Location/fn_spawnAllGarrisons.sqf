params ["_loc"];

private _garMain = [_loc] call loc_fnc_getMainGarrison;

[_garMain] call gar_fnc_spawnGarrison;