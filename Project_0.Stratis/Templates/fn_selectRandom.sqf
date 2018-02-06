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
		private _classID = floor (random (count _subcat));
		[_subcat select _classID, _classID]
	};
};