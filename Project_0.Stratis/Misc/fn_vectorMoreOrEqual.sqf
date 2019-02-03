/*
Function: misc_fnc_vectorMoreOrEqual

Checks if all elements in _v0 are >= than corresponding elements in _v1.

Parameters: _v0, _v1

_v0 - first vector
_v1 - second vector

Examples:
--- Code
[[0, 1, 2], [0, 1, 1]] call misc_fnc_vectorMoreOrEqual; return: true
[[0, 1, 0], [0, 1, 1]] call misc_fnc_vectorMoreOrEqual; return: false
---
 */

params ["_v0", "_v1"];

private _i = 0;
private _c = count _v0;
private _return = true;
while {_i < _c} do {
	if ((_v0 select _i) <= (_v1 select _i)) exitWith {_return = false; };
	_i = _i + 1;
};

_return