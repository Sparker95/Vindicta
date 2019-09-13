params [["_className", "", ["0"]]];

#ifdef _SQF_VM
if (true) exitWith {0}; // In SQF VM we don't have CBA functions and don't have the hashmap global variable :( just return 0
#endif

// Try to get number from the hashmap
private _num = t_classnames_hashmap getVariable [_className, -1];

// If it's not added yet, then add it to the hashmap
if (_num == -1) then {
	_num = t_classnames_array pushBack _className;
	t_classnames_hashmap setVariable [_className, _num];
};

_num