/*
Checks the template array for not initialized values and reports them
*/

params ["_template"];

private _c1 = 0;
private _c2 = 0;
private _count2 = 0;
private _cat = [];
private _subcat = [];

while {_c1 < T_SIZE} do
{
	_cat = _template select _c1;
	if (isNil "_cat") then
	{
		diag_log format ["fn_checkNil: Template: category not found: %1", _c1];
	}
	else
	{
		_count2 = count _cat;
		_c2 = 0;
		while {_c2 < _count2} do
		{
			_subcat = _cat select _c2;
			if(isNil "_subcat") then
			{
				diag_log format ["fn_checkNil: Template: subcategory not found: %1 in category: %2", _c2, _c1];
			};
			_c2 = _c2 + 1;
		};
	};
	_c1 = _c1 + 1;
};
