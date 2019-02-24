/*
Makes all units in the garrison rejoin the group they have been assigned to.

Return value:
	number - the amount of units which had wrong group
*/

params ["_gar"];

private _allGroupIDs = _gar call gar_fnc_getAllGroups;

private _counter = 0;

for "_i" from 0 to ((count _allGroupIDs) - 1) do
{
	private _groupID = _allGroupIDs select _i;
	private _groupHandle = [_gar, _groupID] call gar_fnc_getGroupHandle;
	private _groupUnits = [_gar, _groupID] call gar_fnc_getGroupAliveUnits;
	for "_j" from 0 to ((count _groupUnits) - 1) do
	{
		private _unitData = _groupUnits select _j;
		if (_unitData select 0 != T_VEH) then
		{
			private _unitHandle = [_gar, _unitData] call gar_fnc_getUnitHandle;
			if (!((group _unitHandle) isEqualTo _groupHandle)) then
			{
				[_unitHandle] join _groupHandle;
				_counter = _counter + 1;
			};
		};
	};
};

_counter