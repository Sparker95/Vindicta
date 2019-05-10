/*
Checks elements for specified threshold. If value is higher, the returned value is 1, if value is lower, the retuurned value is 0;
Input: [_sourceArray]
Return: a new array with detected edges
*/

params ["_gridArray", "_threshold", ["_destArray", []]];

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
			private _value = [_gridArray, _i, _j] call ws_fnc_getValueID;
			if(_value > _threshold) then
			{
				[_destArray, _i, _j, 1] call ws_fnc_setValueID;
			}
			else
			{
				[_destArray, _i, _j, 0] call ws_fnc_setValueID;
			};
		};
	};
};

_destArray