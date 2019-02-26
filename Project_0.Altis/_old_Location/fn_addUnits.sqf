/*
Adds specified units to the garrison.
Units must share the same kind of spawn positions, for example (tanks, APCs, trucks) or (high HMG, high GMG), or infantry, etc.
First the function gets the available spawn positions for units of this type. Then it is multiplied by the occupy coefficient(0...1). The resulting amount of spawn positions is occupied by units with proportion based on the provided _proportion number of each unit.

_loc - the location object
_gar - the garrison object
_units - array of [_catID, _subcatID, _proportion]
_groupType - the type of the group
_occupyCoef - number from 0 to 1.0
*/

params ["_loc", "_gar", "_units", "_groupType", "_occupyCoef"];

private _catID = _units select 0 select 0;
private _subcatID = _units select 0 select 1;
private _maxCapacity = [_loc, _catID, _subcatID, _groupType] call loc_fnc_getMaxCapacity;
private _capacity = _maxCapacity * _occupyCoef;
if(_capacity == 0) exitWith {};

private _singleGroup = false; //If units will be added as one group
if(_catID == T_INF || ([_catID, _subcatID] in T_PL_HMG_GMG_high) || ([_catID, _subcatID] in T_PL_HMG_GMG_low)) then
{
	_singleGroup = true;
};

//Check if the units are defined in the template
private _template = _loc getVariable ["l_template_main", []];
private _unitsToDelete = [];
{
	_catID = _x select 0;
	_subcatID = _x select 1;
	if(!([_template, _catID, _subcatID, 0] call t_fnc_isValid)) then
	{
		_unitsToDelete pushBack _x;
		diag_log format ["fn_addUnits.sqf: error: unit is not defined in template: %1", _x select [0, 2]];
	};
}forEach _units;
_units = _units - _unitsToDelete;

//Calculate the sum
private _sum = 0;
{
	_sum = _sum + (_x select 2);
}forEach _units;

//Normalize the _proportion of each unit
private _proportion = 0;
{
	_proportion = _x select 2;
	_proportion = _proportion / _sum;
	_x set [2, _proportion];
}forEach _units;

diag_log format ["fn_addUnits.sqf: _units: %1", _units];
diag_log format ["fn_addUnits.sqf: maxCapacity: %1, capacity: %2", _maxCapacity, _capacity];

//Add the units
private _i = 0;
private _occupiedNr = 0; //Number of already occupied spawn positions
private _chance = 0;
private _amount = 0;
private _amountInt = 0;
private _singleGroupUnits = [];
{
	_catID = _x select 0;
	_subcatID = _x select 1;
	_amount = (_x select 2) * _capacity;
	_amountInt = floor _amount;
	_chance = _amount - _amountInt; //The chance that an additional unit will be spawned.
	if((random 1) < _chance) then
	{
		_amountInt = _amountInt + 1;
	};
	diag_log format ["fn_addUnits.sqf: unit: %1, amount: %2", _x, _amountInt];
	_i = 0;
	while {(_i < _amountInt) && (_occupiedNr < _maxCapacity)} do
	{
		if(_singleGroup) then //Infantry, HMGs and GMGs, are added as one group
		{
			_singleGroupUnits pushBack [_catID, _subcatID, -1];
		}
		else
		{	//For vehicles we need to check if they require any crew or not. Those with crew should be added as groups, gar_fnc_addNewGroup will add the crew.
			if((_subcatID in T_VEH_need_basic_crew) || {_subcatID in T_VEH_need_crew} || {_subcatID in T_VEH_need_heli_crew} || {_subcatID in T_VEH_need_plane_crew}) then
			{
				[_gar, _template, [[_catID, _subcatID, -1]], -1, _groupType] call gar_fnc_addNewGroup;
			}
			else
			{	//Vehicles that don't need special crew will be added without a group
				[_gar, _template, _catID, _subcatID, -1, -1] call gar_fnc_addNewUnit;
			};
		};
		_occupiedNr = _occupiedNr + 1;
		_i = _i + 1;
	};
} forEach _units;

if(_singleGroup) then
{
	[_gar, _template, _singleGroupUnits, -1, _groupType] call gar_fnc_addNewGroup;
};
