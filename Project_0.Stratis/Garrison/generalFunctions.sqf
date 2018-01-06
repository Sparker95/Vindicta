/*
Functions like set- or get-value stay here.
*/

#include "garrison.hpp"

gar_fnc_setName =
{
	/*
	Sets the name of this garrison. Currently name is used only for debug.
	*/
	params ["_lo", "_name"];
	_lo setVariable ["g_name", _name];
};

gar_fnc_setSide =
{
	/*
	Sets the side of this garrison
	*/
	params ["_lo", "_side"];
	_lo setVariable ["g_side", _side];
};

gar_fnc_getSide =
{
	params ["_lo"];
	private _return = _lo getVariable ["g_side", []];
	_return
};

gar_fnc_setLocation =
{
	/*
	Sets the location object of this garrison
	*/
	params ["_lo", "_location"];
	_lo setVariable ["g_location", _location];
};

gar_fnc_getLocation =
{
	/*
	Gets the location object of this garrison
	*/
	params ["_lo"];
	private _return = _lo getVariable ["g_location", objNull];
	_return
};

gar_fnc_isSpawned =
{
	params ["_lo"];
	private _return = _lo getVariable ["g_spawned", []];
	_return
};

gar_fnc_findUnits =
{
	/*
	Used to find a unit with given category, subcategory and classID in garrison's database.
	_classID can be -1 if you don't care which exactly class it is.
	Return value:
	an array of:
	[_catID, _subcatID, _unitID] - for each found unit to satisfy this criteria
	or [] if nothing found
	*/
	params [["_lo", objNull, [objNull]], ["_catID", 0, [0]], ["_subcatID", 0, [0]], ["_debug", true]];

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
};

gar_fnc_countUnits =
{
	/*
	Counts units that have their [_catID, _subcatID] in _types and have specified _groupType.
	_types - array of:
		[_catID, _subcatID]
	_groupType - the group type, or:
		-1 to ignore _groupType.
	return value: number
	*/

	params [["_lo", objNull, [objNull]], ["_types", [], [[]]], "_groupType"];

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
};

gar_fnc_findGroups =
{
	/*
	Used to find groups of given group type in garrison's database.
	_groupType can be -1 if you need to get all the groups.
	
	Parameters:
		[_gar, _groupType]
	
	Return value:
		an array of:
		[_groupID] - for each found group
		or [] if nothing found
	*/
	params [["_lo", objNull, [objNull]], ["_groupType", -1, [0]]];
	private _gt = 0;
	private _gid = 0;
	private _groups = _lo getVariable ["g_groups", []];
	private _groupsReturn = [];
	{
		_gt = _x select 3; //Group type
		_gid = _x select 2; //Group ID
		if((_groupType == -1) || (_groupType == _gt)) then
		{
			_groupsReturn pushBack _gid;
		};
	}forEach _groups;
	_groupsReturn
};

gar_fnc_findGroupHandles =
{
	/*
	Returns group handles of groups having specific group type, or any group type if _groupType = -1;
	*/
	params [["_lo", objNull, [objNull]], ["_groupType", -1, [0]]];
	private _hGs = [];
	private _hG = grpNull;
	private _gt = 0;
	private _groups = _lo getVariable ["g_groups", []];
	{
		_hG = _x select 1;
		_gt = _x select 3; //group type
		if(!(_hG isEqualTo grpNull) && ((_groupType == -1) || (_groupType == _gt))) then
		{
			_hGs pushback _hG;
		};
	}forEach _groups;
	_hGs
};

gar_fnc_getGroupHandle =
{
	/*
	Returns the group handle of specified group.
	*/
	params [["_lo", objNull, [objNull]], ["_groupID", 0, [0]]];
	private _group = [_lo, _groupID, 0] call gar_fnc_getGroup;
	_group select G_GROUP_HANDLE
};

gar_fnc_getGroup =
{
	/*
	Get the group with specified _groupID.

	Parameters:
	_returnType:
		0 - return only the group array
		1 - return only the group's index in the group array
		2 - return [_groupArray, _groupIndex]
		_groupIndex = -1 if group not found
	*/

	params [["_lo", objNull, [objNull]], ["_groupID", 0, [0]], ["_returnType", 0]];

	private _groups = _lo getVariable ["g_groups", []];

	private _group = [];
	private _foundGroup = [];
	private _count = count _groups;
	private _i = 0;
	while{_i < _count} do
	{
		_group = _groups select _i;
		//diag_log format ["current group: %1", _group];
		if(_group select 2 == _groupID) exitWith {_foundGroup = _group};
		_i = _i + 1;
	};

	if(_foundGroup isEqualTo []) then
	{
		_i = -1;
	};

	switch (_returnType) do
	{
		case 0:
		{
			_foundGroup
		};
		case 1:
		{
			_i
		};
		case 2:
		{
			[_foundGroup, _i]
		};
	};
};

gar_fnc_getGroupUnits =
{
	/*
	Returns the list of units in group specified by groupID.
	The units are returned as an array: [_catID, _subcatID, _unitID]
	*/
	params [["_lo", objNull, [objNull]], ["_groupID", 0, [0]]];
	private _group = [_lo, _groupID, 0] call gar_fnc_getGroup;
	private _groupUnits = _group select G_GROUP_UNITS;
	private _return = [];
	{
		if ((_x select 0 select 2) != -1) then //If the unit is alive
		{
			_return pushback (_x select 0);
		};
	} forEach _groupUnits;
	_return
};

gar_fnc_getGroupAliveUnits =
{
	params [["_lo", objNull, [objNull]], ["_groupID", 0, [0]]];
	private _units = [_lo, _groupID] call gar_fnc_getGroupUnits;
	_units select {(_x select 2) != -1}
};

gar_fnc_getUnitGroupID =
{
	/*
	Returns the group ID of the unit with specified _unitData
	*/
	params [["_lo", objNull, [objNull]], ["_unitData", [0, 0, 0], [[]]]];
	private _unit = [_lo, _unitData] call gar_fnc_getUnit;
	_unit select G_UNIT_GROUP_ID
};

gar_fnc_getUnitHandle =
{
	/*
	Returns the handle of the unit with specified _unitData
	*/
	params ["_lo", "_unitData"];
	private _unit = [_lo, _unitData] call gar_fnc_getUnit;
	_unit select 1
};

gar_fnc_getUnit =
{
	/*
	Get the unit with specified _unitData.
	_unitData is: [_catID, _subcatID, _unitID]

	Parameters:
	_returnType:
		0 - return only the unit array
		1 - return only the unit's [_subcat, _index]
		2 - return [_unitArray, [_subcat, _index]]

	*/

	params [["_lo", objNull, [objNull]], ["_unitData", [0, 0, 0], [[]]], ["_returnType", 0]];

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
};