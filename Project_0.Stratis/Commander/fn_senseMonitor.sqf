/*
This thread takes data from sense objects and displays it on the map
*/

#define TIME_SLEEP 5

params ["_enemyMonitor", "_side"];

private _colorEnemy = "ColorEAST";

switch (_side) do
{
	case EAST: { _colorEnemy = "ColorEAST";};
	case WEST: { _colorEnemy = "ColorWEST";};
	case INDEPENDENT: { _colorEnemy = "ColorGUER";};
};

private _counterEnemies = 0;
private _counterEnemiesClusters = 0;

while {true} do
{
	//==== Enemy monitor ====
	private _e = _enemyMonitor call sense_fnc_enemyMonitor_getActiveClusters;
	//diag_log format ["Global enemies: %1", _e select 0];
	//diag_log format ["Global enemies pos: %1", _e select 1];
	//diag_log format ["Global enemies age: %1", _e select 2];
	
	//Create markers
	for [{_i = 0}, {_i < _counterEnemies}, {_i = _i + 1}] do
	{
		private _name = format ["enemy_%1", _i];
		deletemarker _name;
	};
	_counterEnemies = count (_e select 0);
	for [{_i = 0}, {_i < _counterEnemies}, {_i = _i + 1}] do
	{
		//Marker for the calculated launch site center
		private _name = format ["enemy_%1", _i];
		private _mrk = createmarker [_name, (_e select 1) select _i];
		_mrk setMarkerType "mil_box";
		_mrk setMarkerColor _colorEnemy;
		_mrk setMarkerText (format ["%1", (_e select 2) select _i]);
	};
	//Rectangles for clusters
	//diag_log format ["_counterEnemiesClusters: %1", _counterEnemiesClusters];
	for [{_i = 0}, {_i < _counterEnemiesClusters}, {_i = _i + 1}] do
	{
		private _name = format ["enemyCluster_%1", _i];
		diag_log format ["deleting cluster: %1"];
		deleteMarker _name;
	};
	private _eclusters = _e select 3;
	_counterEnemiesClusters = count _eclusters;
	//diag_log format ["Clusters with enemies: %1", _eclusters];
	for [{_i = 0}, {_i < _counterEnemiesClusters}, {_i = _i + 1}] do
	{
		_name = format ["enemyCluster_%1", _i];
		private _c = _eclusters select _i;
		_mrk = createMarker [_name,
				[	0.5*((_c select 0) + (_c select 2)),
					0.5*((_c select 1) + (_c select 3)),
					0]];
		private _width = 10 + 0.5*((_c select 2) - (_c select 0)); //0.5*(x2-x1)
		private _height = 10 + 0.5*((_c select 3) - (_c select 1)); //0.5*(y2-y1)
		_mrk setMarkerShape "RECTANGLE";
		_mrk setMarkerBrush "SolidFull";
		_mrk setMarkerSize [_width, _height];
		_mrk setMarkerColor _colorEnemy;
		_mrk setMarkerAlpha 0.3;
	};

	sleep TIME_SLEEP;
};