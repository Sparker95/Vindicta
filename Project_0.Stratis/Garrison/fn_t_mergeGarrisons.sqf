/*
This function is uded inside the garrison thread to merge this garrison into another one.
*/

params ["_garThis", "_garDst"];

//==== First, move all the groups ====
private _groupIDs = [_garThis] call gar_fnc_findGroups; //Get group IDs of all the groups
if(count _groupIDs > 0) then
{
	private _rid = 0;
	{
		_rid = [_garThis, [_garDst, _x]] call gar_fnc_t_moveGroup;
	} forEach _groupIDs;
};

//==== Second, move all units without groups ====
private _allUnitDatas = _garThis call gar_fnc_getAllUnits;
diag_log format ["Remaining units in the garrison: %1", _allUnitDatas];
private _count = count _allUnitDatas;
for "_i" from 0 to (_count - 1) do
{
	private _unitData = _allUnitDatas select _i;
	[_garThis, [_garDst, _unitData, -1]] call gar_fnc_t_moveUnit;
};
