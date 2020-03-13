/*
Select a class from a subcategory from a category from a template array
parameters:
return value: array with classnames, nil if value not found

_subcatID can be -1 for a random class

*/

params ["_template", "_catID", "_subcatID", "_classID"];

private _cat = [];
private _class = "";
private _return = nil;

if(count _template <= _catID) then
{
	diag_log format ["fn_select.sqf: Template/Category not found: %1, _tpl: %2", _catID, _template];
	nil
}
else
{
	private _cat = _template select _catID;
	if (isNil "_cat") then
	{
		diag_log format ["fn_select.sqf: Template: category is Nil : %1", _catID];
	}
	else
	{
		private _subcat = _cat select _subcatID;
		if(isNil "_subcat") then
		{
			diag_log format ["fn_select.sqf: Template: subcategory not found: %1 in category: %2", _subcatID, _catID];
			_return = _cat select 0; //Return default value
		}
		else
		{
			if (_classID != -1) then {
				_class = _subcat select _classID;
			} else {
				if(count _subcat > 1 && {_subcat#1 isEqualType 0}) then {
					_class = selectRandomWeighted _subcat;
				} else {
					_class = selectRandom _subcat;
				}
			};
			if(isNil "_class") then
			{
				diag_log format ["fn_select.sqf: Template: class not found: %1 in subcategory: %2 in category: %3", _classID, _subcatID, _catID];
				_return = _subcat select 0;
			}
			else
			{
				_return = _class;
			};
		};
	};
};

_return
