call compile preprocessFileLineNumbers "WarStatistics\initFunctions.sqf";
//call compile preprocessFileLineNumbers "WarStatistics\plotFrontline.sqf";
/*
_r = 500;

_aaf = [((mrkAAF-ciudades)-colinasAA)-controles, _r, 1] call ws_fnc_markersToGridArray;
_fia = [mrkFIA-["FIA_HQ"], _r, -1] call ws_fnc_markersToGridArray;
_sum = [_aaf, _fia] call ws_fnc_addGrid;
_zc = [_sum] call ws_fnc_filterZeroCrossing;
[_zc, 0.5, _zc] call ws_fnc_filterThreshold; //make the border line less blurry
_dir = [_sum] call ws_fnc_filterEdgeDir;

for [{private _i = 0}, {_i < ws_gridSizeX}, {_i = _i + 1}] do //_i is x-pos
{
	for [{private _j = 0}, {_j < ws_gridSizeY}, {_j = _j + 1}] do //_j is y-pos
	{
		private _value = [_zc, _i, _j] call ws_fnc_getValueID;
		if(_value == 0) then
		{
			[_dir, _i, _j, 666] call ws_fnc_setValueID; //We don't want to plot the arrows everywhere
		};
	};
};

[_dir] call ws_fnc_plotDirGrid;
//[_zc, 1] call ws_fnc_plotGrid;
*/

_r = 500;

private _sum = call ws_fnc_newGridArray;
[((mrkAAF-ciudades)-colinasAA)-controles, _r, 1, _sum] call ws_fnc_markersToGridArray;
[mrkFIA-["FIA_HQ"], _r, -1, _sum] call ws_fnc_markersToGridArray;
private _zc = call ws_fnc_newGridArray;
[_sum, 0, _zc] call ws_fnc_filterZeroCrossing;
[_zc, 0.5, _zc] call ws_fnc_filterThreshold; //make the border line less blurry
private _dir = call ws_fnc_newGridArray;
[_sum, _dir] call ws_fnc_filterEdgeDir;


for [{private _i = 0}, {_i < ws_gridSizeX}, {_i = _i + 1}] do //_i is x-pos
{
	for [{private _j = 0}, {_j < ws_gridSizeY}, {_j = _j + 1}] do //_j is y-pos
	{
		private _value = [_zc, _i, _j] call ws_fnc_getValueID;
		if(_value == 0) then
		{
			[_dir, _i, _j, 666] call ws_fnc_setValueID; //We don't want to plot the arrows everywhere
		};
	};
};


//[_dir] call ws_fnc_plotDirGrid;
[_zc, 1] call ws_fnc_plotGrid;