/*
Counts units that have their [_catID, _subcatID] in _types and havespecified _groupType.
_types - array of:
	[_catID, _subcatID]
_groupType - the group type, or:
	-1 to ignore _groupType.
return value: number
*/

params ["_lo", "_types", "_groupType"];

private _count = 0;
private _searchInf = false;
private _searchVeh = false;
private _searchDrone = false;

//Check if we need to search specific categories
{
	call
	{
		if(_x select 0 == T_INF) exitWith {_searchInf = true;};
		if(_x select 0 == T_VEH) exitWith {_searchVeh = true;};
		if(_x select 0 == T_DRONE) exitWith {_searchDrone = true;};
	};
} forEach _types;

private _g_inf = if(_searchInf) then {_lo getVariable ["g_inf", []]} else {[]};
private _g_veh = if(_searchVeh) then {_lo getVariable ["g_veh", []]} else {[]};
private _g_drone = if(_searchDrone) then {_lo getVariable ["g_drone", []]} else {[]};

//diag_log format ["inf: %1, veh: %2, drone: %3", _g_inf, _g_veh, _g_drone];
//diag_log format ["Searching in categories [0, 1, 2]: %1", [_searchInf, _searchVeh, _searchDrone]];

//Find units

private _catID = 0;
private _subcatID = 0;
private _subcat = [];
private _groupID = 0;
private _group = [];
private _groupID = 0;
{
	_catID = _x select 0;
	_subcatID = _x select 1;
	switch (_catID) do //Get the units in this subcategory
	{
		case T_INF:
		{
			_subcat = _g_inf select _subcatID;
		};
		case T_VEH:
		{
			_subcat = _g_veh select _subcatID;
		};
		case T_DRONE:
		{
			_subcat = _g_drone select _subcatID;
		};
	};
	//Count only units that have specified groupType or ignore the group type
	if(_groupType == -1) then //If groupType is ignored, just count units in this subcategory
	{
		_count = _count + (count _subcat);
	}
	else
	{
		{
			_groupID = _x select 3;
			if(_groupID != -1) then //If this unit belongs to a group
			{
				_group = [_lo, _groupID] call gar_fnc_getGroup; //Get the group of this unit
				if((_group select 3) == _groupType) then //If the groupTypes are equal
				{
					_count = _count + 1;
				};
			};
		}forEach _subcat;
	};
}forEach _types;

_count