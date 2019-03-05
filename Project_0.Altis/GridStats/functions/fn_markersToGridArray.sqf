/*
Converts markers to a grid array. In the new grid array, the further the element is from the marker, the lower the value.
Input: [_mrk, _radius, _k]
_mrk - array of marker names
_radius - number, the radius of imfluence of each marker
_k - proportion coefficient
Return value: [_gridArray] - a grid array
Author: Sparker
Date: 12.08.2017
*/

params ["_mrk", "_radius", "_k", ["_gridArray", []]];

if(_gridArray isEqualTo []) then
{
	_gridArray = call ws_fnc_newGridArray;
};

//private _gridArray = call ws_fnc_newGridArray;
private _pos = [0, 0, 0];
private _dist = 0;
private _posGrid = [0, 0, 0];
private _posMrk = [0, 0, 0];
private _currentMarker = "";
private _halfSize = 0.5*ws_squareSize;
private _limitNorm = ceil(16*_radius/ws_squareSize);
private _xIDMrk = 0;
private _yIDMrk = 0;
{
	_posMrk = getMarkerPos _x;
	_currentMarker = _x;
	//diag_log format ["fn_markersToGridArray.sqf: checking marker: %1", _currentMarker];
	private _xIDMrk = floor(((_posMrk select 0) - ws_gridStartX) / ws_squareSize);
	private _yIDMrk = floor(((_posMrk select 1) - ws_gridStartY) / ws_squareSize);
	for [{private _i = (_xIDMrk - _limitNorm)}, {_i <= (_xIDMrk + _limitNorm)}, {_i = _i + 1}] do //_i is x-pos
	{
		_posMrk = getMarkerPos _currentMarker;
		//diag_log format ["fn_markersToGridArray.sqf: marker position is: %1", _posMrk];
		for [{private _j = (_yIDMrk - _limitNorm)}, {_j <= (_yIDMrk + _limitNorm)}, {_j = _j + 1}] do //_j is y-pos
		{
			_posGrid = [ws_squareSize*_i + _halfSize + ws_gridStartX, ws_squareSize*_j + _halfSize + ws_gridStartY, 0];
			_dist = _posGrid distance _posMrk;
			_dist = _dist / _radius; //Normalized distance
			//_addValue = _k/(abs(_dist*_dist)+1);
			_addValue = _k / (_dist/ + 1);
			//_addValue = 10;
			if(abs ([_gridArray, _i, _j] call ws_fnc_getValueID) < abs (_addValue)) then
			{
				//[_gridArray, _i, _j, _addValue] call ws_fnc_addValueID;
				[_gridArray, _i, _j, _addValue] call ws_fnc_setValueID;
			};
			//diag_log format ["fn_markersToGridArray.sqf: grid [x, y] IDs are: [%1, %2], grid position is: %3, distance: %4", _i, _j, _posGrid, _dist];
		};
	};
}
forEach _mrk;

_gridArray