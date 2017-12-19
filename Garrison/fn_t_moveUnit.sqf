/*
Used inside the garrison thread to move a unit from one garrison to another
*/

params ["_lo", "_requestData"];

private _lo_dst = _requestData select 0;
private _unitData = _requestData select 1;

private _catID = _unitData select 0;
private _subcatID = _unitData select 1;
private _unitID = _unitData select 2;
private _cat = [];
switch (_catID) do
{
	case T_INF: //Remove infantry
	{
		_cat = _lo getVariable ["g_inf", []];
	};
	case T_VEH: //Remove a vehicle
	{
		_cat = _lo getVariable ["g_veh", []];
	};
	case T_DRONE: //Remove a drone
	{
		_cat = _lo getVariable ["g_drone", []];
	};
};

//Find this unit in source garrison
private _subcat = _cat select _subcatID;
private _count = count _subcat;
private _i = 0;
private _unit = [];
while{_i < _count} do
{
	_unit = _subcat select _i;
	if(_unit select 2 == _unitID) exitWith {};
	_i = _i + 1;
};

if(_i == _count) exitWIth //Error: unit with this ID not found
{
	diag_log format ["fn_t_moveUnit.sqf: garrison: %1, unit not found: %2", _lo getVariable ["g_name", ""], _unitData];
};

private _objectHandle = _unit select 1;
private _classID = _unit select 0;
//First remove the unit from source garrison
//Note that a thread-function is used here, so it will remove the unit from garrison right now
[_lo, _unitData] call gar_fnc_t_removeUnit;
//Then add the unit to the destination garrison
//Note that a non-thread function is used here, it will only add the request to the queue, the actual addition of the unit will happen later
[_lo_dst, [_catID, _subcatID, _classID, _objectHandle]] call gar_fnc_addExistingUnit;