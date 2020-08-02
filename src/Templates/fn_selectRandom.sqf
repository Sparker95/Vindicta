#include "..\common.h"
/*
Select a random classname from subcategory from a category from a template array
parameters:
return value: [_className, _classID]
_className - string, random classname
_classID - number, the ID of the classname.
[, -1] if nothing found
*/

params ["_template", "_catID", "_subcatID"];

private _cat = [];

if(count _template <= _catID) then
{
	diag_log format ["fn_selectRandom.sqf: Template: category not found: %1", _catID];
	[configNull, -1] //Not found
}
else
{
	private _cat = _template select _catID;
	if (isNil "_cat") then
	{
		diag_log format ["fn_selectRandom.sqf: Template: category not found: %1", _catID];
		[configNull, -1] //Not found
	}
	else
	{
		private _subcat = _cat select _subcatID;
		if(isNil "_subcat") then
		{
			diag_log format ["fn_selectRandom.sqf: Template: subcategory not found: %1 in category: %2", _subcatID, _catID];
			_subcat = _cat select 0; //Return default value
		};
		private _weightsCat = if(count _template > (_catID+T_WEIGHTS_OFFSET)) then {
			_template select (_catID+T_WEIGHTS_OFFSET)
		} else {
			nil
		};
		private _weightsSubcat = if(isNil "_weightsCat") then { nil } else { _weightsCat select _subcatID };
		private _classID = if(isNil "_weightsSubcat") then 
		{
			floor (random (count _subcat))
		}
		else
		{
			_subcat find (_subcat selectRandomWeighted _weightsSubcat)
		};
		if(_classID == -1) then {
			DUMP_CALLSTACK;
			diag_log format["RANDOM %1", _this];
		};
		private _class = _subcat select _classID;
		if(isNil "_class") then {
			DUMP_CALLSTACK;
			diag_log format["RANDOM %1", _this];
		};
		// private _classID = floor (random (count _subcat));
		[_subcat select _classID, _classID]
	};
};
