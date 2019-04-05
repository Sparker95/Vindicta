/*
Gets zero detection value of element specified by ID of grid element. It checks 3x3 square of elements surrounding given element, then if this square has all negatives or all positives, the value returned is zero; If the grid has 4,5 or 5,4 negative-positive values, the returned value is 1.0;
parameters: [_xPosID, _yPosID]
returns: value
*/

params ["_gridArray", "_xID", "_yID", ["_offset", 0]];

if(_xID == 0 || _yID == 0 || _xID >= ws_gridSizeX-1 || _yID >= ws_gridSizeY-1) exitWith {0};

private _numPositive = 0;
private _numNegative = 0;
private _value = 0;
for [{private _i = _xID-1}, {_i <= _xID+1}, {_i = _i + 1}] do //_i is x-pos
{
	for [{private _j = _yID-1}, {_j <= _yID+1}, {_j = _j + 1}] do //_j is y-pos
	{
		_value = ([_gridArray, _i, _j] call ws_fnc_getValueID) + _offset;
		if(_value > 0) then
		{
			_numPositive = _numPositive + 1;
		}
		else
		{
			if (_value < 0) then
			{
				_numNegative = _numNegative + 1;
			};
		};
	};
};

private _return =
if(_numPositive != 0 && _numNegative != 0) then
{
	(4.5-abs(_numPositive-4.5))/4
}
else
{
	0
};
_return