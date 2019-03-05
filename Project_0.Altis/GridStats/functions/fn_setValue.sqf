/*
Sets value of element specified by world coordinates
parameters: [_xPos, _yPos, _value]
returns: nothing
*/

params ["_gridArray", "_xPos", "_yPos", "_newValue"];

private _xID = floor((_xPos - ws_gridStartX) / ws_squareSize);
private _yID = floor((_yPos - ws_gridStartY) / ws_squareSize);

if(_xID < 0 || _yID < 0 || _xID > ws_gridSizeX-1 || _yID > ws_gridSizeY-1) exitWith {0};

//ws_grid select _xID select _yID = _newValue;
_col = _gridArray select _xID;
_col set [_yid, _newValue];
_gridArray set [_xID, _col];