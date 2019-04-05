/*
Gets edge detection direction
parameters: [_xPosID, _yPosID]
returns: value
*/

params ["_gridArray", "_xID", "_yID"];

if(_xID < 0 || _yID < 0 || _xID > ws_gridSizeX-1 || _yID > ws_gridSizeY-1) exitWith {0};

private _mul = [[-0.25, -0.5, -0.25], [0.0, 0.0, 0.0], [0.25, 0.5, 0.25]]; //horizontal edge detection

private _mulX = 0;
private _mulY = 0;
private _acc = 0;

//Detect horizontal edge
_mulX = 0;
for [{private _i = _xID-1}, {_i <= _xID+1}, {_i = _i + 1}] do //_i is x-pos
{
	_mulY = 0;
	for [{private _j = _yID-1}, {_j <= _yID+1}, {_j = _j + 1}] do //_j is y-pos
	{
		private _v = 0;
		if(!(_i < 0 || _j < 0 || _i > ws_gridSizeX-1 || _j > ws_gridSizeY-1)) then //Check if we are not out of bounds
		{
			_v = _gridArray select _i select _j;
		};
		_acc = _acc + (_mul select _mulX select _mulY) * _v;
		_mulY = _mulY + 1;
	};
	_mulX = _mulX + 1;
};
private _edge_x = _acc;

_acc = 0;
_mul = [[-0.25, 0.0, 0.25], [-0.5, 0.0, 0.5], [-0.25, 0.0, 0.25]]; //vertical edge detection

//Detect vertical edge
_mulX = 0;
for [{private _i = _xID-1}, {_i <= _xID+1}, {_i = _i + 1}] do //_i is x-pos
{
	_mulY = 0;
	for [{private _j = _yID-1}, {_j <= _yID+1}, {_j = _j + 1}] do //_j is y-pos
	{
		private _v = 0;
		if(!(_i < 0 || _j < 0 || _i > ws_gridSizeX-1 || _j > ws_gridSizeY-1)) then //Check if we are not out of bounds
		{
			_v = _gridArray select _i select _j;
		};
		_acc = _acc + (_mul select _mulX select _mulY) * _v;
		_mulY = _mulY + 1;
	};
	_mulX = _mulX + 1;
};
private _edge_y = _acc;

private _angleEdge = 666; //Just a constant to show that there's no rotation here
if(!(_edge_y == 0 && _edge_x == 0)) then
{
	_angleEdge = (_edge_x atan2 _edge_y);
};
_angleEdge