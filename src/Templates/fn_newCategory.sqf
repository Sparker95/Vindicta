/*
Makes a new category array according to provided category id.
*/

params ["_catID"];

_a = [];
switch (_catID) do {
	case T_INF: {
		_a resize T_INF_size;
		_a = _a apply {[]};
	};

	case T_VEH: {
		_a resize T_VEH_size;
		_a = _a apply {[]};
	};

	case T_DRONE: {
		_a resize T_DRONE_size;
		_a = _a apply {[]};
	};

	case T_CARGO: {
		_a resize T_CARGO_size;
		_a = _a apply {[]};
	};

	case T_GROUP: {
		_a resize T_GROUP_size;
		_a = _a apply {[]};
	};

	case T_INV: {
		_a resize T_INV_size;
		_a = _a apply {[]};
	};

	default {
		"ERROR"
	};
};

_a