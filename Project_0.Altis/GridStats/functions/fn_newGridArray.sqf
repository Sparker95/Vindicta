//Initialize the array
private _gridArray = [];
for [{private _i = 0}, {_i < ws_gridSizeX}, {_i = _i + 1}] do //_i is x-pos
{
	_column = [];
	for [{private _j = 0}, {_j < ws_gridSizeY}, {_j = _j + 1}] do //_j is y-pos
	{
		_column pushBack 0;
	};
	_gridArray pushback _column;
};
_gridArray