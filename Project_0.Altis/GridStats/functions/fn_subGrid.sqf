/*
Subs array 0 from array 1
input: [_gridArray0, _gridArray1]
return: [_gridArray] - the resulting array
*/

params ["_gridArray0", "_gridArray1"];

private _gridArray = call ws_fnc_newGridArray;

private _newValue = 0;
for [{private _i = 0}, {_i < ws_gridSizeX}, {_i = _i + 1}] do //_i is x-pos
{
	for [{private _j = 0}, {_j < ws_gridSizeY}, {_j = _j + 1}] do //_j is y-pos
	{
		_newValue = ([_gridArray0, _i, _j] call ws_fnc_getValueID) - ([_gridArray1, _i, _j] call ws_fnc_getValueID);
		[_gridArray, _i, _j, _newValue] call ws_fnc_setValueID;
	};
};

_gridArray;