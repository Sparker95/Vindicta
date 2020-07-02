/*
Checks if specified category, subcategory and classID are valid in the template
Return value: true - valid, false - invalid
*/

params ["_template", "_catID", "_subcatID", "_classID"];

private _count = count _template;

if(_catID >= _count) exitWith {false};

private _cat = _template select _catID;

if(isNil "_cat") exitWith {false};

_count = count _cat;

if(_subCatID >= _count) exitWith {false};

private _subCat = _cat select _subCatID;

if(isNil "_subCat") exitWith {false};

_count = count _subCat;

if(_classID >= _count) exitWith {false};

true
