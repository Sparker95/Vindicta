/*
Get the unit with specified _unitData.
_unitData is: [_catID, _subcatID, _unitID]

Parameters:
_returnType:
	0 - return only the unit array
	1 - return only the unit's [_subcat, _index]
	2 - return [_unitArray, [_subcat, _index]]

*/

params ["_lo", "_unitData", ["_returnType", 0]];

private _catID = _unitData select 0;
private _subcatID = _unitData select 1;
private _unitID = _unitData select 2;
private _cat = [];
switch (_catID) do
{
	case T_INF: //Infantry
	{
		_cat = _lo getVariable ["g_inf", []];
	};
	case T_VEH: //Vehicle
	{
		_cat = _lo getVariable ["g_veh", []];
	};
	case T_DRONE: //Drone
	{
		_cat = _lo getVariable ["g_drone", []];
	};
};

private _subcat = _cat select _subcatID;
private _count = count _subcat;
private _i = 0;
private _unit = [];
private _foundUnit = [];
while{_i < _count} do
{
	_unit = _subcat select _i;
	if((_unit) select 2 == _unitID) exitWith {_foundUnit = _unit};
	_i = _i + 1;
};

if(_foundUnit isEqualTo []) then
{
	_i = -1;
};

switch (_returnType) do
{
	case 0:
	{
		_foundUnit
	};
	case 1:
	{
		[_subcat, _i]
	};
	case 2:
	{
		[_foundUnit, [_subcat, _i]]
	};
};
