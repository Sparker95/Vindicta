/*
Validates that specified class names are not wrong in a template array
*/

params ["_t", "_factionType"];

private _errorCount = 0;

// Iterate all array elements, find nil-values

_validateArray = {
	params ["_array", ["_path", []], "_warnOrError"];
	private _errors = 0;
	{
		private _path0 = _path + [_forEachIndex];
		if (!isNil "_x") then {
			if (_x isEqualType []) then {
				//diag_log format ["Validating: %1", _path0];
				_errors = _errors + ([_x, _path0, _warnOrError] call _validateArray);
			};
		} else {
			([_path0] call t_fnc_getMetadata) params ["_catName", "_entryName", "_required"];
			if (_warnOrError) then {
				diag_log format ["validateTemplate: error: value is nil, category: %1, id: %2, required: %3", _catName, _entryName, str _required ];
				_errors = _errors + 1;
			} else {
				if(({_x == _factionType} count _required) > 0) then {
					diag_log format ["validateTemplate: warning: value is nil, category: %1, id: %2, required: %3", _catName, _entryName, str _required ];
				};
			};
		};
	} forEach _array;
	_errors
};

// Some categories are validates strict (nils will cause total failure)
private _categoriesToValidateStrict = [T_NAME];
{
	_errorCount = _errorCount + ( [[_t select _x], [_x], true] call _validateArray);
} forEach _categoriesToValidateStrict;

// Other categories are validated non-strict, nils will result in a warning if that subcat is required
private _categoriesToValidateEasy = [T_GROUP, T_INF, T_VEH, T_DRONE];
{
	_errorCount = _errorCount + ( [[_t select _x], [_x], false] call _validateArray);
} forEach _categoriesToValidateEasy;

#ifdef _SQF_VM
if (true) exitWith {_errorCount}; // Return no errors with SQF VM, since we can't check anything from VM anyway
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
		} forEach (_classArray select { _x isEqualType "" }); // Weighted arrays contain numbers as well, so we ignore them
	} forEach (_t#_catID);
} forEach [[T_INF, T_INF_SIZE], [T_VEH, T_VEH_SIZE]];

_errorCount