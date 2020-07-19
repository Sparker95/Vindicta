#include "..\..\common.h"

params [P_ARRAY("_rows")];

private _disp = finddisplay 46;

private _wGap = safeZoneW*0.005;
private _hGap = safeZoneH/safeZoneW*_wGap;
private _hRow = safeZoneH*0.015;
private _wCol0 = safeZoneW*0.04;
private _wCol1 = safeZoneW*0.015;
private _wBarMax = safeZoneW*0.03;
private _hBar = safeZoneH*0.008;
private _wBackground = _wGap + _wCol0 + _wCol1 + _wBarMax;
private _hBackground = 2*_hGap + (count _rows)*_hRow;

private _ctrlGroup = _disp ctrlCreate ["RscControlsGroupNoScrollbars", -1];
_ctrlGroup ctrlSetPosition [0.7, 0.7, _wBackground+0.005, _hBackground+0.005];
_ctrlGroup ctrlCommit 0;

private _ctrlBackground = _disp ctrlCreate ["MUI_BG_BLACKTRANSPARENT", -1, _ctrlGroup];
_ctrlBackground ctrlSetPosition [0, 0, _wBackground, _hBackground];
_ctrlBackground ctrlSetBackgroundColor [0, 0, 0, 0.8];
_ctrlBackground ctrlCommit 0;

{
    _x params ["_name", "_amount"];
    private _i = _forEachIndex;
    
    
    private _ctrlName = _disp ctrlCreate ["MUI_BG_TRANSPARENT_LEFT", -1, _ctrlGroup];
    _ctrlName ctrlSetPosition [0, _hGap + _i*_hRow, _wCol0, _hRow];
    _ctrlName ctrlCommit 0;
    _ctrlName ctrlSetText _name;
    
    
    
    private _ctrlAmount = _disp ctrlCreate ["MUI_BG_TRANSPARENT_LEFT", -1, _ctrlGroup];
    _ctrlAmount ctrlSetPosition [ _wCol0, _hGap + _i*_hRow, _wCol1, _hRow];
    _ctrlAmount ctrlCommit 0;
    _ctrlAmount ctrlSetText (str _amount);
    

    
    private _barWidth = (_amount/10*_wBarMax) min _wBarMax;
    private _ctrlBar = _disp ctrlCreate ["RscText", -1, _ctrlGroup];
    _ctrlBar ctrlSetBackgroundColor [0, 64/256, 232/256, 1.0];
    _ctrlBar ctrlSetPosition [_wCol0 +_wCol1, _hGap + _i*_hRow + 0.5*(_hRow - _hBar), _barWidth, _hBar];
    _ctrlBar ctrlCommit 0;
    
} forEach _rows;

_ctrlGroup;