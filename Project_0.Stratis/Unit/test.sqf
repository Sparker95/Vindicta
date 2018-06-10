#include "..\OOP_Light\OOP_Light.h"

[] spawn {
	for "_i" from 0 to 10000 do {
		private _args = [tNato, 0, 1, 0];
		private _unit = NEW("Unit", _args);
		private _valid = CALL_METHOD(_unit, "isValid", []);
		if (!_valid) then {
			DELETE(_unit);
			diag_log format ["Created invalid unit!"];
		};
	};
};