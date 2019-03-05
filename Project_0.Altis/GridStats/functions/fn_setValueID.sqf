/*
Sets value of element specified by xID, yID
parameters: [_xPos, _yPos, _value]
returns: nothing
*/

params ["_gridArray", "_xID", "_yID", "_newValue"];

if(_xID < 0 || _yID < 0 || _xID > ws_gridSizeX-1 || _yID > ws_gridSizeY-1) exitWith {0};

//ws_grid select _xID select _yID = _newValue;
_col = _gridArray select _xID;
_col set [_yid, _newValue];
_gridArray set [_xID, _col];