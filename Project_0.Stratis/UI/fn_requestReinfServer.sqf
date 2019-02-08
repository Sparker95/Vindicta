params ["_owner", "_loc", "_type"];

private _gar = [_loc] call loc_fnc_getMainGarrison;

private _units = [];
switch(_type) do
{
	case 'ifv':
	{
		_units = [_gar, T_VEH, T_VEH_IFV] call gar_fnc_findUnits;
	};

	case 'apc':
	{
		_units = [_gar, T_VEH, T_VEH_APC] call gar_fnc_findUnits;
	};

	case 'tank':
	{
		_units = [_gar, T_VEH, T_VEH_MBT] call gar_fnc_findUnits;
	};

	case 'mrap':
	{
		_units = ([_gar, T_VEH, T_VEH_MRAP_HMG] call gar_fnc_findUnits) + ([_gar, T_VEH, T_VEH_MRAP_GMG] call gar_fnc_findUnits);
	};
};

if(count _units > 0) then
{
	[_owner, _gar, _loc, _units select 0] spawn compile preprocessfilelinenumbers "UI\transferUnitsToHC.sqf";
};
