/*
This function groups provided clusters into bigger clusters according to provided maximum distance.

!!!!!!!!!!!!!!!
!!! WARNING !!!
!!!!!!!!!!!!!!!

This function modifies the initial array!
Make a copy of your initial array if you still need it after calling the function.

!!!!!!!!!!!!!!!
!!! WARNING !!!
!!!!!!!!!!!!!!!

Parameters:
_clusters - array with clusters
_md - Minimum Distance between clusters, if two clusters are closer than _md to each other then they will be merged

Returns: array with new bigger clusters.

Author: Sparker 12.2017
*/

/*
Performance results:
data size - exec. time
12 - 1.3 ms
20 - 3.5 ms
50 - 15.6 ms
100 - 61 ms
200 - 250 ms
*/

params ["_clusters", "_md"];

private _c = count _clusters;

if(_c < 2) exitWith
{
	private _out = +_clusters;
	_out
};

for "_i" from 0 to _c-1 do
{
	for "_j" from 0 to _c-1 do
	{
		_ci = _clusters select _i;
		_cj = _clusters select _j;
		//If we have different clusters, and if both clusteres have not been removed
		if (_i != _j &&
			{count _ci > 0} &&
			{count _cj > 0}) then
		{
			#ifdef DEBUG
			diag_log format ["Checking clusters: %1 %2", _i, _j];
			#endif
			_d = [_ci, _cj] call cluster_fnc_distance;
			//If the clusters are close, merge them
			if (_d < _md) then
			{
				[_ci, _cj] call cluster_fnc_merge;
				//Mark the second cluster as inactive
				_clusters set [_j, []];
			};
		};
	};
};

//Produce output array
private _out = [];
{
	//Add only active clusters
	if (count _x > 0) then
	{
		_out pushBack _x;
	};
} forEach _clusters;
_out
