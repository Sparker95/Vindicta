/*
Gets value of element specified by ID of grid element
parameters: [_xPosID, _yPosID]
returns: value
*/

params ["_gridArray", "_xID", "_yID"];

if(_xID < 0 || _yID < 0 || _xID > ws_gridSizeX-1 || _yID > ws_gridSizeY-1) exitWith {0};

_return = _gridArray select _xID select _yID;
_return