CALL_COMPILE_COMMON("Cluster\initFunctions.sqf");

//A script to test the cluster functions

_points =
[
[	6.0000,    9.0000],
[    2.0000,    2.0000],
[   12.0000,    2.0000],
[    4.0000,    2.0000],
[    9.0000,   10.0000],
[    1.0000,    1.0000],
[   10.0000,         0],
[   10.0000,   10.0000],
[    1.0000,    3.0000],
[   10.0000,    1.5000],
[         0,         0],
[    7.0000,    9.0000]
];

//Convert points to clusters
private _clusters = [];
{
	private _xpos = _x select 0;
	private _ypos = _x select 1;
	private _nc = [_xpos, _ypos, _xpos, _ypos, _foreachindex] call cluster_fnc_newCluster;
	_clusters pushBack _nc;
} forEach _points;

diag_log format ["Input points: %1", _points];
diag_log format ["Input clusters: %1", _clusters];

//Cluster this!
private _clustersOut = [_clusters, 2.2] call cluster_fnc_findClusters;

diag_log "Cluster calculation done!";
diag_log format ["Output data: %1", _clustersOut];
diag_log format ["Output: %1 clusters", count _clustersOut];

//Output
{
	private _border = [_x select 0, _x select 1, _x select 2, _x select 3];
	diag_log format ["Output cluster: %1, borders: %2", _foreachindex, _border];
	diag_log format ["  object IDs: %1", _x select 4];
} forEach _clustersOut;
