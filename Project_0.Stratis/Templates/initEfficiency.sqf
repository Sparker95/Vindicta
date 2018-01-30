/*
These arrays represent the efficiency  of all units in the templates.
*/

private _eff = [];

private _eff_inf = [];
_eff_inf set [T_INF_default,	[1, 2, 3, 4]];
_eff_inf set [T_INF_SL,			[1, 2, 4, 5]];
_eff set [T_INF, _eff_inf];


private _eff_veh = [];
_eff_veh set [T_VEH_default,	[1, 3, 4, 0]];
_eff_veh set [T_VEH_car_unarmed,[1, 6, 7, 8]];

_eff set [T_VEH, _eff_veh];


private _eff_drone = [];

_eff set [T_DRONE, _eff_drone];

T_efficiency = +_eff;