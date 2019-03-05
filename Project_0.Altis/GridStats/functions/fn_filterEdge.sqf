/*
Detects edges in input array
Input: [_sourceArray]
Return: a new array with detected edges
*/

params ["_gridArray", ["_destArray", []]];

if(_destArray isEqualTo []) then
{
	_destArray = call ws_fnc_newGridArray;
};

if(!isNil "_gridArray") then
{
	for [{private _i = 0}, {_i < ws_gridSizeX}, {_i = _i + 1}] do //_i is x-pos
	{
		for [{private _j = 0}, {_j < ws_gridSizeY}, {_j = _j + 1}] do //_j is y-pos
		{
			private _newValue = [_gridArray, _i, _j] call ws_fnc_getEdgeValueID;
			[_destArray, _i, _j, _newValue] call ws_fnc_setValueID;
		};
	};
};

_destArray