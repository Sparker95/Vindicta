#define ASCENDING true
#define DESCENDING false

vin_fnc_sortBy = {
	params ["_arr", "_fnc", ["_dir", ASCENDING]];
	private __arr = _arr apply { [call _fnc, _x] };
	__arr sort _dir;
	__arr apply { _x#1 }
};


["vin_fnc_sortBy", {
	private _a = [1, 4, 2, 3];
	private _aa = [_a, {_x}, ASCENDING] call vin_fnc_sortBy;
	private _ad = [_a, {_x}, DESCENDING] call vin_fnc_sortBy;

	["Sort simple ascending", _aa isEqualTo [1, 2, 3, 4]] call test_Assert;
	["Sort simple descending", _ad isEqualTo [4, 3, 2, 1]] call test_Assert;

	private _positions = [[1, 0, 0], [1, 1, 0], [1, 1, 1], [2, 0, 0]];
	private _b = [0, 1, 2, 3];
	private _o = [0, 0, 0];
	private _ba = [_b, { _positions#_x distance _o }, ASCENDING] call vin_fnc_sortBy;
	
	["Sort non-simple", _ba isEqualTo [0, 1, 2, 3]] call test_Assert;
}] call test_AddTest;