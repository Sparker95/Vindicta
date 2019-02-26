/*
Used to find a unit with given category, subcategory and classID in garrison's database.
_classID can be -1 if you don't care which exactly class it is.
Return value:
an array of:
[_catID, _subcatID, _unitID] - for each found unit to satisfy this criteria
or [] if nothing found
*/

params ["_lo", "_catID", "_subcatID", ["_debug", true]];

private _cat = [];
switch (_catID) do
{
	case T_INF:
	{
		_cat = _lo getVariable ["g_inf", []];
	};
	case T_VEH:
	{
		_cat = _lo getVariable ["g_veh", []];
	};
	case T_DRONE:
	{
		_cat = _lo getVariable ["g_drone", []];
	};
};

private _subcat = _cat select _subcatID;
private _count = count _subcat;
private _i = 0;
private _unit = [];
private _return = [];
while{_i < _count} do
{
	_unit = _subcat select _i;
	_return pushBack [_catID, _subcatID, _unit select 2];
	_i = _i + 1;
};

_return
