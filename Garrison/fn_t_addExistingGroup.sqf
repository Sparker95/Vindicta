/*
Used inside the garrison thread to add an existing group.
*/

params ["_lo", "_requestData", "_spawned"];

private _unitsFullData = _requestData select 0;
private _oldGroupData = _requestData select 1;

//Add the group to the groups array of the garrison
//Assign a group ID
private _groupID = _lo getVariable ["g_unitIDCounter", nil];
_lo setVariable ["g_unitIDCounter", _groupID + 1];
//Add the group to the array
private _groups = _lo getVariable ["g_groups", []];
private _newGroupUnits = [];
private _groupHandle = _oldGroupData select 1;
private _group = [_newGroupUnits, _groupHandle, _groupID, _oldGroupData select 3];
_groups pushBack _group; //Units, groupHandle, groupID, groupType

private _oldGroupUnits = _oldGroupData select 0;
//diag_log format ["Old group units: %1", _oldGroupUnits];
private _oldGroupUnit = [];
private _catID = 0;
private _subcatID = 0;
private _classID = 0;
private _objectHandle = objNull;
private _i = 0;
private _unitFullData = [];
{
	_oldGroupUnit = _x select 0;
	_catID = _oldGroupUnit select 0;
	_subcatID = _oldGroupUnit select 1;
	if(_oldGroupUnit select 2 == -1) then //If the unit in the group was killed, add it to the new group anyway
	{
		_newGroupUnits pushBack [[_catID, _subcatID, -1], []]; //-1 means the unit was destroyed
	}
	else
	{
		//If the unit is alive, add it with gar_fnc_t_addExistingUnit. It will also add it to the group array. A new unitID will be assigned to this unit
		_unitFullData = _unitsFullData select _i;
		_catID = _unitFullData select 0;
		_subcatID = _unitFullData select 1;
		_classID = _unitFullData select 2;
		_objectHandle = _unitFullData select 3;
		[_lo, [_catID, _subcatID, _classID, _objectHandle, _groupID], _spawned] call gar_fnc_t_addExistingUnit;
		_i = _i + 1;
	};
} forEach _oldGroupUnits;

//Set the alert state again
private _as = _lo getVariable ["g_alertState", 0];
[_lo, _as, _spawned, false] call gar_fnc_t_setAlertState;

//Assign vehicle roles again
//todo transfer vehicle roles instaead of asigning them
//Assign vehicle roles
[_lo, _groupID, _spawned, true, true, false] call gar_fnc_t_assignVehicleRoles;

//Set variables to the group object
if(_spawned && !(_groupHandle isEqualTo grpNull)) then
{
	_groupHandle setVariable ["g_garrison", _lo, false];
	_groupHandle setVariable ["g_groupID", _groupID, false];
	_groupHandle setVariable ["g_group", _group, false];
};

_groupID