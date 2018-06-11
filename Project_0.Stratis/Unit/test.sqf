#include "..\OOP_Light\OOP_Light.h"

[] spawn {
	private _group = NEW("Group", [WEST]);
	sleep 2;
	private _n = 10;
	for "_i" from 0 to _n do {
		private _args = [tNato, 0, 1, 0, _group];
		private _unit = NEW("Unit", _args);
		private _valid = CALL_METHOD(_unit, "isValid", []);
		if (!_valid) then {
			DELETE(_unit);
			diag_log format ["Created invalid unit!"];
		} else {
			private _args = [getPos player, 0];
			CALL_METHOD(_unit, "spawn", _args);
		};
	};
	
	sleep 1;
	private _allUnits = GET_STATIC_VAR("Unit", "all");
	{
		CALL_METHOD(_x, "despawn", []);
	} forEach _allUnits;
};