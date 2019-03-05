/*
Gets smoothed value of element specified by ID of grid element
parameters: [_xPosID, _yPosID]
returns: value
*/

params ["_gridArray", "_xID", "_yID"];

if(_xID < 0 || _yID < 0 || _xID > ws_gridSizeX-1 || _yID > ws_gridSizeY-1) exitWith {0};

_mul = [[0.2, 0.4, 0.2], [0.4, 1.0, 0.4], [0.2, 0.4, 0.2]];

private _mulX = 0;
private _mulY = 0;
private _return = 0;

_a = [[0, 0, 0], [0, 0, 0], [0, 0, 0]];

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
		_return = _return + (_mul select _mulX select _mulY) * _v;
		_mulY = _mulY + 1;
	};
	_mulX = _mulX + 1;
};

_return = _return / 3.4;
_return