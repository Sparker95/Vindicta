/*
Validates that specified class names are not wrong in a template array
*/

params ["_t"];

private _errorCount = 0;

#ifdef _SQF_VM
if (true) exitWith {0}; // Return no errors with SQF VM, since we can't check anything from VM anyway
#endif

// Validate infantry and vehicles
{ // forEach [[T_INF, T_INF_SIZE], [T_VEH, T_VEH_SIZE]]
	_x params ["_catID", "_catSize"];
	{ // forEach (_t#_catID);
		private _classArray = _x;
		{ // forEach (_classArray);
			private _classOrLoadout = _x;
			private _isClass = isClass (configFile >> "cfgVehicles" >> _classOrLoadout);
			private _isLoadout = [_classOrLoadout] call t_fnc_isLoadout;
			if ((!_isClass) && (!_isLoadout)) then {
				diag_log format ["validateTemplate: error: class or loadout %1 was not resolved", _classOrLoadout];
				_errorCount = _errorCount + 1;
			};
		} forEach (_classArray);
	} forEach (_t#_catID);
} forEach [[T_INF, T_INF_SIZE], [T_VEH, T_VEH_SIZE]];

_errorCount