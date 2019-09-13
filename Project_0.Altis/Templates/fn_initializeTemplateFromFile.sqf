params [["_filePath", "", [""]]];

// Call compile the file as usual...
_t = call compile preprocessFileLineNumbers _filePath;

// Check for errors, inexistent class names or loadouts, etc
private _errorCount = [_t] call t_fnc_validateTemplate;
if (_errorCount > 0) exitWith {
	_t = []; // Break it completely so that whole scenario fails horribly and we can see the errors in RPT
	diag_log format ["TEMPLATE ERROR: %1", _filePath];
};

#ifndef _SQF_VM
// Convert class names to numbers, so that t_fnc_numberToClassName can work later
// Makes no use for tests with SQF VM
[_t] call t_fnc_convertTemplateClassNamesToNumbers;
#endif

// Return the array
_t