/*
Select a class from a subcategory from a category from a template array
parameters:
return value: array with classnames, nil if value not found

_subcatID can be -1 for a random class

*/

params ["_template", "_catID", "_subcatID", "_classID"];

if(count _template <= _catID) exitWith {
	diag_log format ["fn_select.sqf: Template/Category not found: %1, _tpl: %2", _catID, _template];
	nil
};

private _cat = _template select _catID;
if (isNil "_cat") exitWith {
	diag_log format ["fn_select.sqf: Template: category is Nil : %1", _catID];
	nil
};

private _subcat = _cat select _subcatID;
if(isNil "_subcat" || { count _subcat == 0 }) then {
	// Fall back to default subcategory
	_subcat = _cat select 0;
};

switch true do {
	case (_classID != -1): { _subcat select _classID };
	// A weighted array has the form [value, weight, value, weight, ...]
	case (count _subcat > 1 && {_subcat#1 isEqualType 0}): {
		#ifndef _SQF_VM
		selectRandomWeighted _subcat
		#else
		_subcat#0
		#endif
	};
	// Normal non-empty array
	case (count _subcat > 0): { selectRandom _subcat };
	default { 
		diag_log format ["fn_select.sqf: Template: class not found: %1 in subcategory: %2 in category: %3", _classID, _subcatID, _catID];
		nil
	};
};
