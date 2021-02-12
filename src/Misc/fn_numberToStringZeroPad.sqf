/*
Function: misc_fnc_numberToStringZeroPad

Pads an integer with zeros until a certain length is reached.

Parameters: _number, _padding

_number - the number that is to be padded
_padding - the maximum amount of padding

Returns: zero padded string

Example:
[123, 4] call misc_fnc_numberToStringZeroPad;
Return value: "0123"
*/

params ["_number", "_padding"];

private _numStr = str (floor _number);
private _length = count _numStr;

if (_length < _padding) then {
	private _paddedNumStr = _numStr;
	for [{private _i = 0}, {_i < _padding - _length}, {_i = _i + 1}] do {
		_paddedNumStr = "0" + _paddedNumStr;
	}; 
	_paddedNumStr
} else {
	_numStr
};