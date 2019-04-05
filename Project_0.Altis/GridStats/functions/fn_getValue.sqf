/*
Gets value of element specified by world coordinates
parameters: [_xPos, _yPos]
returns: value
*/

params ["_gridArray", "_xPos", "_yPos"];

private _xID = floor((_xPos - ws_gridStartX) / ws_squareSize);
private _yID = floor((_yPos - ws_gridStartY) / ws_squareSize);

if(_xID < 0 || _yID < 0 || _xID > ws_gridSizeX-1 || _yID > ws_gridSizeY-1) exitWith {0};

[_gridArray, _xID, _yID] call ws_fnc_getValueID;