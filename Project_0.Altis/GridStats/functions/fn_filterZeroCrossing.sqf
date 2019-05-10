/*
Detects zero crossing in the input array
Input: [_sourceArray]
Return: a new array
*/

params ["_gridArray", "_offset", ["_destArray", []]];

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
			private _newValue = [_gridArray, _i, _j, _offset] call ws_fnc_getZeroCrossingValueID;
			[_destArray, _i, _j, _newValue] call ws_fnc_setValueID;
		};
	};
};

_destArray