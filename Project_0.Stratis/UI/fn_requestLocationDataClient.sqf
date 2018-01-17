#include "UICommanderIDC.hpp"

params ["_dataArray"];

diag_log "client function!!";

private _displayMap = findDisplay 12; //Map display

//Set text for IDCs
private _IDC_COUNTER = IDC_REINF_REQ_BUTTON_0;
private _c = 0;

//Tanks
(_displayMap displayCtrl _IDC_COUNTER) ctrlSetText (format ["%1x Tank", _dataArray select _c]);
_c = _c + 1;

//APCs
_IDC_COUNTER = _IDC_COUNTER + 1;
(_displayMap displayCtrl _IDC_COUNTER) ctrlSetText (format ["%1x APC", _dataArray select _c]);
_c = _c + 1;

//IFVs
_IDC_COUNTER = _IDC_COUNTER + 1;
(_displayMap displayCtrl _IDC_COUNTER) ctrlSetText (format ["%1x IFV", _dataArray select _c]);
_c = _c + 1;

//MRAPs
_IDC_COUNTER = _IDC_COUNTER + 1;
(_displayMap displayCtrl _IDC_COUNTER) ctrlSetText (format ["%1x MRAP", _dataArray select _c]);
_c = _c + 1;

//Helicopters
_IDC_COUNTER = _IDC_COUNTER + 1;
//_count = [_gar, T_PL_helicopters, -1] call gar_fnc_countUnits;
(_displayMap displayCtrl _IDC_COUNTER) ctrlSetText (format ["%1x Helicopter", _dataArray select _c]);
_c = _c + 1;

//Planes
_IDC_COUNTER = _IDC_COUNTER + 1;
(_displayMap displayCtrl _IDC_COUNTER) ctrlSetText (format ["%1x Plane", _dataArray select _c]);
_c = _c + 1;

//Infantry (crew)
_IDC_COUNTER = _IDC_COUNTER + 1;
(_displayMap displayCtrl _IDC_COUNTER) ctrlSetText (format ["%1x Infantry (crew)", _dataArray select _c]);
_c = _c + 1;

//Infantry (patrol)
_IDC_COUNTER = _IDC_COUNTER + 1;
(_displayMap displayCtrl _IDC_COUNTER) ctrlSetText (format ["%1x Infantry (patrol)", _dataArray select _c]);
_c = _c + 1;

//Infantry (idle)
_IDC_COUNTER = _IDC_COUNTER + 1;
(_displayMap displayCtrl _IDC_COUNTER) ctrlSetText (format ["%1x Infantry (idle)", _dataArray select _c]);
_c = _c + 1;

//Artillery
_IDC_COUNTER = _IDC_COUNTER + 1;
(_displayMap displayCtrl _IDC_COUNTER) ctrlSetText (format ["%1x Lawn Mower", _dataArray select _c]);
_c = _c + 1;
