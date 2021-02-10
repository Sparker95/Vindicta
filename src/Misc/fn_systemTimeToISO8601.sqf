/*
Function: misc_fnc_systemTimeToISO8601

Converts a date into an ISO8601 string representation of the date.

Arguments: date in format returned by systemTime or systemTimeUTC SQF command

Returns: string

Example:
[2020, 11, 23, 13, 37, 42, 123] call misc_fnc_systemTimeToISO8601;
Return value: "2020-11-23T13:37:42.123"
*/

_date = _this;
private _year4 = [_date#0, 4] call misc_fnc_numberToStringZeroPad;
private _ms = [_date#6, 3] call misc_fnc_numberToStringZeroPad; // Zero-pad numbers below 100
_date = _date apply { [_x, 2] call misc_fnc_numberToStringZeroPad }; // Zero-pad numbers below 10
_date params ["_year", "_month", "_day", "_h", "_m", "_s"];
format ["%1-%2-%3T%4:%5:%6.%7", _year4, _month, _day, _h, _m, _s, _ms]