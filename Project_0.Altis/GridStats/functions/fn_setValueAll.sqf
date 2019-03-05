/*
Sets value to all elements
*/

params ["_gridArray", ["_value", 0]];

for [{private _i = 0}, {_i < ws_gridSizeX}, {_i = _i + 1}] do //_i is x-pos
{
	_column = _gridArray select _i;
	for [{private _j = 0}, {_j < ws_gridSizeY}, {_j = _j + 1}] do //_j is y-pos
	{
		_column set [_j, _value];
	};
};