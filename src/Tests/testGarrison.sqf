#include "common.h"

[] spawn {
	private _group = NEW("Group", [WEST]);
	private _garrison = NEW("Garrison", [GARRISON_TYPE_GENERAL ARG WEST]);
	CALLM(_garrison, "setName", ["noname"]);
	private _n = 10;
	for "_i" from 0 to _n do {
		private _args = [tNato, 0, 1, _group];
		private _unit = NEW("Unit", _args);
		private _valid = CALLM0(_unit, "isValid");
		if (!_valid) then {
			DELETE(_unit);
			diag_log format ["Created an invalid unit!"];
		};
	};

	// Add the group to the garrison
	private _args = ["addGroup", [_group]];
	CALLM(_garrison, "postMethodSync", _args);

	// Spawn the garrison
	_args = ["spawn", []];
	CALLM(_garrison, "postMethodSync", _args);
	CALLM(_garrison, "postMethodSync", _args);
	CALLM(_garrison, "postMethodSync", _args);

	sleep 2;

	// Despawn the garrison
	_args = ["despawn", []];
	CALLM(_garrison, "postMethodSync", _args);
};
