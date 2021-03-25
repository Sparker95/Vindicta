/*
Function: misc_fnc_dateToISO8601

Converts a date into an ISO8601 string representation of the date.

Arguments: date in format returned by date SQF command

Returns: string

Example:
[2035, 6, 24, 9, 13] call misc_fnc_dateToISO8601;
Return value: "2035-6-24 09:13"
*/

_date = _this;
_date = _date apply {[_x, 2] call misc_fnc_numberToStringZeroPad}; // We zero-pad all numbers below 10
_date params ["_year", "_month", "_day", "_h", "_m", "_s"];
format ["%1-%2-%3 %4:%5", _year, _month, _day, _h, _m]