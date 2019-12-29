/*
Select a subcategory from a category from a template array
parameters:
return value: array with classnames, nil if value not found
*/

params ["_template", "_catID", "_subcatID"];

private _cat = [];

if(count _template <= _catID) then
{
	diag_log format ["fn_select.sqf: Template: category not found: %1", _catID];
	nil
}
else
{
	private _cat = _template select _catID;
	if (isNil "_cat") then
	{
		diag_log format ["fn_select.sqf: Template: category not found: %1", _catID];
		nil
	}
	else
	{
		private _subcat = _cat select _subcatID;
		if(isNil "_subcat") then
		{
			diag_log format ["fn_select.sqf: Template: subcategory not found: %1 in category: %2", _subcatID, _catID];
			_subcat = _cat select 0; //Return default value
		};
		_subcat;
	};
};
