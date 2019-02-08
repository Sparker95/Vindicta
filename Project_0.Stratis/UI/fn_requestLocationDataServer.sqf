params ["_owner", "_loc"];

private _gar = [_loc] call loc_fnc_getMainGarrison;

private _returnData = [];
_returnData set [15, nil];
private _i = 0;


//Tanks
_returnData set [_i, ([_gar, [[T_VEH, T_VEH_MBT]], -1] call gar_fnc_countUnits)];
_i = _i + 1;

//APCs
_returnData set [_i, ([_gar, [[T_VEH, T_VEH_APC]], -1] call gar_fnc_countUnits)];
_i = _i + 1;

//IFVs
_returnData set [_i, ([_gar, [[T_VEH, T_VEH_IFV]], -1] call gar_fnc_countUnits)];
_i = _i + 1;

//MRAPs
_returnData set [_i, ([_gar, [[T_VEH, T_VEH_MRAP_unarmed], [T_VEH, T_VEH_MRAP_HMG], [T_VEH, T_VEH_MRAP_GMG]], -1] call gar_fnc_countUnits)];
_i = _i + 1;

//Helicopters
_returnData set [_i, ([_gar, T_PL_helicopters, -1] call gar_fnc_countUnits)];
_i = _i + 1;

//Planes
_returnData set [_i, ([_gar, T_PL_planes, -1] call gar_fnc_countUnits)];
_i = _i + 1;

//Infantry (crew)
_returnData set [_i, ([_gar, T_PL_INF_main, G_GT_veh_static] call gar_fnc_countUnits) + ([_gar, T_PL_INF_main, G_GT_veh_non_static] call gar_fnc_countUnits)];
_i = _i + 1;

//Infantry (patrol)
_returnData set [_i, ([_gar, T_PL_INF_main, G_GT_patrol] call gar_fnc_countUnits)];
_i = _i + 1;

//Infantry (idle)
_returnData set [_i, ([_gar, T_PL_INF_main, G_GT_idle] call gar_fnc_countUnits)];
_i = _i + 1;

//Artillery
_returnData set [_i, ([_gar, [[T_VEH, T_VEH_stat_mortar_heavy], [T_VEH, T_VEH_stat_mortar_light]], G_GT_veh_static] call gar_fnc_countUnits)];
_i = _i + 1;

[_returnData] remoteExecCall ["ui_fnc_requestLocationDataClient", _owner];
