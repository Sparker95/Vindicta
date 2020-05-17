/*
Creates a string or returns an existing string variable if it already exists.
Parameters: _str - string
Returns: string
*/
params ["_str"];
private _strFound = gStaticStringHashmap getVariable [_str, ""];
if (_strFound == "") then {
	gStaticStringHashmap setVariable [_str, _str];
	_str
} else {
	_strFound
};