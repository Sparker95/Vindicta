params [["_className", "", ["0"]]];

#ifdef _SQF_VM
if (true) exitWith {0}; // In SQF VM we don't have CBA functions and don't have the hashmap global variable :( just return 0
#endif

//diag_log format ["CLASS NAME TO NUMBER: %1", _className];

// Try to get number from the hashmap
private _num = t_classnames_hashmap getVariable [_className, -1];

//diag_log format ["  returned _num: %1", _num];

// If it's not added yet, then add it to the hashmap
if (_num == -1) then {
	_num = t_classnames_array pushBack _className;
	t_classnames_hashmap setVariable [_className, _num, true];
	// diag_log format ["[Template::classNameToNumber] Added class name: %1, id: %2", _className, _num];
};

_num