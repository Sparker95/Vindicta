/*
Adds value to element specified by x, y IDs
parameters: [_xPos, _yPos, _value]
returns: nothing
*/

params ["_gridArray", "_xID", "_yID", "_addValue"];

if(_xID < 0 || _yID < 0 || _xID > ws_gridSizeX-1 || _yID > ws_gridSizeY-1) exitWith {};
_newValue = _addValue + (_gridArray select _xID select _yID);
_col = _gridArray select _xID;
_col set [_yid, _newValue];
_gridArray set [_xID, _col];