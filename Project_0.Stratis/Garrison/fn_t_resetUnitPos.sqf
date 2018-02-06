/*
Resets unit's position and rotation to its default spawn position.
*/

#include "garrison.hpp"

params ["_lo", "_unitData", "_spawned"];

private _unit = [_lo, _unitData] call gar_fnc_getUnit;

if (_unit isEqualTo []) exitWith
{
	diag_log format ["fn_t_resetUnitPos.sqf: garrison: %1, unit not found: %2", _lo getVariable ["g_name", ""], _unitData];
};

//Resetting unit's position only makes sense if the garrison is spawned
if(_spawned) then
{
	//Read soma variables
	private _objectHandle = _unit select G_UNIT_HANDLE;
	private _groupID = _unit select G_UNIT_GROUP_ID;
	private _groupType = G_GT_idle; //Default group type if the unit isn't assigned to a group
	if (_groupID != -1) then
	{
		private _group = [_lo, _groupID] call gar_fnc_getGroup;	
		_groupType = _group select G_GROUP_TYPE;
	};
	//Get garrison's location object
	_locationObject = _lo getVariable ["g_location", objNull];
	//Get spawn position
	_spawnPosAndDir = [_locationObject, _unitData select 0, _unitData select 1, _unit select G_UNIT_CLASSNAME, _groupType] call loc_fnc_getSpawnPosition;
	_spawnPos = _spawnPosAndDir select [0, 3]; //Because it also returns the direction as 4th element inside the array
	_direction = _spawnPosAndDir select 3;
	//For some time switch off damage to the unit
	_objectHandle allowDamage false;
	[_objectHandle] spawn {sleep 1; (_this select 0) allowDamage true;};
	//Finally set the new position
	_objectHandle setDir _direction;
	_objectHandle setPos _spawnPos;
};