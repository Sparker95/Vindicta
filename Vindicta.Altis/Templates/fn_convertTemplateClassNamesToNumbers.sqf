/*
Calls classNameToNumber on each class name found in the template.
*/

params ["_t"];

// Validate infantry and vehicles
{ // forEach [[T_INF, T_INF_SIZE], [T_VEH, T_VEH_SIZE]]
	_x params ["_catID", "_catSize"];
	{ // forEach (_t#_catID);
		private _classArray = _x;
		{ // forEach (_classArray);
			private _classOrLoadout = _x;
			[_classOrLoadout] call t_fnc_classNameToNumber;
		} forEach (_classArray select { _x isEqualType "" }); // Weighted array can have numbers in it
	} forEach (_t#_catID);
} forEach [[T_INF, T_INF_SIZE], [T_VEH, T_VEH_SIZE], [T_DRONE, T_DRONE_SIZE], [T_CARGO, T_CARGO_SIZE]];