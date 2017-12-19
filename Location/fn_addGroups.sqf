/*
Used to add infantry groups from template. Same as fn_addUnits, but for groups.

_groups - array of [_subcatID, _groupType, _proportion]

_proportion defines the proportion of units of this group in the whole infantry garrison. Units are added by whole groups, not by single units.
*/
params ["_loc", "_gar", "_groups", "_occupyCoef"];

private _template = _loc getVariable ["l_template_main", []];
private _subcatID = 0;
private _classID = 0;
//Select random groups from template. Calculate the group size of each group.
private _groupTemplateAndClass = [];
private _groupTemplate = [];
private _groupsToDelete = [];
{
	_subcatID = _x select 0;
	_groupTemplateAndClass = [_template, T_GROUP, _subcatID] call t_fnc_selectRandom;
	_groupTemplate = _groupTemplateAndClass select 0;
	_classID = _groupTemplateAndClass select 1;
	if(_classID == -1) then
	{
		diag_log format ["fn_addGroups.sqf: Error: group is not defined in template: %1", _x];
		_groupsToDelete pushBack _x;
	}
	else
	{
		_x pushBack _classID;
		//The group from the template can be an array or a config
		if(_groupTemplate isEqualType []) then //If it's an array
		{
			_x pushBack (count _groupTemplate);
		}
		else
		{
			_x pushBack (count ("true" configClasses _groupTemplate));
		};
		//[_subcatID, _groupType, _proportion, _classID, _nrOfUnitsInGroup]
	};
}forEach _groups;

//Delete groups that don't exist in the template
_groups = _groups - _groupsToDelete;

//Normalize the proportions, so that the sum of all _proportions is 1.0
private _sum = 0;
{
	_sum = _sum + (_x select 2);
} forEach _groups;

private _proportion = 0;
{
	_proportion = _x select 2;
	_proportion = _proportion / _sum;
	_x set [2, _proportion];
}forEach _groups;

private _maxCapacity = [_loc] call loc_fnc_getMaxInfantryCapacity;
private _capacity = _maxCapacity * _occupyCoef;
diag_log format ["fn_addGroups.sqf: groups: %1", _groups];
diag_log format ["fn_addGroups.sqf: maxInfantryCapacity: %1, infantryCapacity: %2", _maxCapacity, _capacity];

//Add the groups to the garrison
private _amount = 0;
private _amountInt = 0;
private _chance = 0;
private _groupType = 0;
private _i = 0;
{
	_subcatID = _x select 0;
	_groupType = _x select 1;
	_classID = _x select 3;
	_amount = (_capacity * (_x select 2)) / (_x select 4); //_capacity*_proportion / _amountOfUnitsInGroup
	_amountInt = floor _amount;
	_chance = _amount - _amountInt; //The chance that an extra group will be added.
	if((random 1) < _chance) then
	{
		_amountInt = _amountInt + 1;
	};
	_i = 0;
	diag_log format ["fn_addGroups.sqf: group: %1, amount: %2", _x, _amountInt];
	while {_i < _amountInt} do
	{
		[_gar, _template, _subcatID, _classID, _groupType] call gar_fnc_addNewGroup;
		_i = _i + 1;
	};
} forEach _groups;