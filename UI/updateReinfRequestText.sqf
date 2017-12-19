//todo redo this

#include "UICommanderIDC.hpp"

disableSerialization;
private _displayMap = findDisplay 12; //Map display
private _selectedLocation = player getVariable ["ui_selectedLocation", objNull];
private _gar = [_selectedLocation] call loc_fnc_getMainGarrison;


//Request data of this location from the server


//Set text for IDCs
private _IDC_COUNTER = IDC_REINF_REQ_BUTTON_0;
//Tanks
private _count = [_gar, [[T_VEH, T_VEH_MBT]], -1] call gar_fnc_countUnits;
(_displayMap displayCtrl _IDC_COUNTER) ctrlSetText (format ["%1x Tank", _count]);

//APCs
_IDC_COUNTER = _IDC_COUNTER + 1;
_count = [_gar, [[T_VEH, T_VEH_APC]], -1] call gar_fnc_countUnits;
(_displayMap displayCtrl _IDC_COUNTER) ctrlSetText (format ["%1x APC", _count]);

//IFVs
_IDC_COUNTER = _IDC_COUNTER + 1;
_count = [_gar, [[T_VEH, T_VEH_IFV]], -1] call gar_fnc_countUnits;
(_displayMap displayCtrl _IDC_COUNTER) ctrlSetText (format ["%1x IFV", _count]);

//MRAPs
_IDC_COUNTER = _IDC_COUNTER + 1;
_count = [_gar, [[T_VEH, T_VEH_MRAP_unarmed], [T_VEH, T_VEH_MRAP_HMG], [T_VEH, T_VEH_MRAP_GMG]], -1] call gar_fnc_countUnits;
(_displayMap displayCtrl _IDC_COUNTER) ctrlSetText (format ["%1x MRAP", _count]);

//Helicopters
_IDC_COUNTER = _IDC_COUNTER + 1;
_count = [_gar, T_PL_helicopters, -1] call gar_fnc_countUnits;
(_displayMap displayCtrl _IDC_COUNTER) ctrlSetText (format ["%1x Helicopter", _count]);

//Planes
_IDC_COUNTER = _IDC_COUNTER + 1;
_count = [_gar, T_PL_planes, -1] call gar_fnc_countUnits;
(_displayMap displayCtrl _IDC_COUNTER) ctrlSetText (format ["%1x Plane", _count]);

//Infantry (crew)
_IDC_COUNTER = _IDC_COUNTER + 1;
_count = [_gar, T_PL_INF_main, G_GT_veh_static] call gar_fnc_countUnits;
_count = _count + ([_gar, T_PL_INF_main, G_GT_veh_non_static] call gar_fnc_countUnits);
(_displayMap displayCtrl _IDC_COUNTER) ctrlSetText (format ["%1x Infantry (crew)", _count]);

//Infantry (patrol)
_IDC_COUNTER = _IDC_COUNTER + 1;
_count = [_gar, T_PL_INF_main, G_GT_patrol] call gar_fnc_countUnits;
(_displayMap displayCtrl _IDC_COUNTER) ctrlSetText (format ["%1x Infantry (patrol)", _count]);

//Infantry (idle)
_IDC_COUNTER = _IDC_COUNTER + 1;
_count = [_gar, T_PL_INF_main, G_GT_idle] call gar_fnc_countUnits;
(_displayMap displayCtrl _IDC_COUNTER) ctrlSetText (format ["%1x Infantry (idle)", _count]);

//Artillery
_IDC_COUNTER = _IDC_COUNTER + 1;
_count = [_gar, [[T_VEH, T_VEH_stat_mortar_heavy], [T_VEH, T_VEH_stat_mortar_light]], G_GT_veh_static] call gar_fnc_countUnits;
(_displayMap displayCtrl _IDC_COUNTER) ctrlSetText (format ["%1x Artillery", _count]);