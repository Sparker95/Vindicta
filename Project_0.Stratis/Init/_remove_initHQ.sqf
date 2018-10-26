//todo add separate artillery radars for sides!

/*
globalArtilleryRadar = [] call sense_fnc_artilleryRadar_create;
globalSoundMonitor = [] call sense_fnc_soundMonitor_create;
globalEnemyMonitor = [] call sense_fnc_enemyMonitor_create;

artilleryRadarEast = [] call sense_fnc_artilleryRadar_create;
soundMonitorEast = [] call sense_fnc_soundMonitor_create;
enemyMonitorEast = [] call sense_fnc_enemyMonitor_create;

artilleryRadarWest = [] call sense_fnc_artilleryRadar_create;
soundMonitorWest = [] call sense_fnc_soundMonitor_create;
enemyMonitorWest= [] call sense_fnc_enemyMonitor_create;

artilleryRadarInd = [] call sense_fnc_artilleryRadar_create;
soundMonitorInd = [] call sense_fnc_soundMonitor_create;
enemyMonitorInd = [] call sense_fnc_enemyMonitor_create;
*/

/*
fn_highLevelScript =
{
	private _counterSounds = 0;
	private _counterArtClusters = 0;
	private _counterEnemies = 0;
	private _counterEnemiesClusters = 0;
	while {true} do
	{
		sleep 5;
		
		//==== Sound Monitor ====
		//Sound monitor
		[globalSoundMonitor] call sense_fnc_soundMonitor_process;
		private _soundClusters = [globalSoundMonitor] call sense_fnc_soundMonitor_getActiveClusters;
		//Delete previous markers
		private _i = 0;
		while {_i < _counterSounds} do
		{
			private _name = format["soundCluster_%1", _i];
			deletemarker _name;
			_i = _i + 1;
		};
		_counterSounds = 0;
		//Create markers
		{
			diag_log format ["Active sound cluster: %1", _x];
			
			private _name = format["soundCluster_%1", _counterSounds];
			deletemarker _name;
			_counterSounds = _counterSounds + 1;
			private _c = _x select 0; //Cluster
			//deletemarker _name;
			private _mrk = createMarker [_name,
					[	0.5*((_c select 0) + (_c select 2)),
						0.5*((_c select 1) + (_c select 3)),
						0]];
			private _width = 0.5*((_c select 2) - (_c select 0)); //0.5*(x2-x1)
			private _height = 0.5*((_c select 3) - (_c select 1)); //0.5*(y2-y1)
			_mrk setMarkerShape "RECTANGLE";
			_mrk setMarkerBrush "SolidFull";
			_mrk setMarkerSize [_width, _height];
			_mrk setMarkerColor "ColorGreen";
			_mrk setMarkerAlpha 0.4;
		} forEach _soundClusters;
		
		//==== Artillery Radar ====
		private _batteries = [globalArtilleryRadar] call sense_fnc_artilleryRadar_getActiveClusters;
		//Remove previous markers and create new ones
		for [{_i = 0}, {_i < count _batteries}, {_i = _i + 1}] do
		{
			//Marker for the calculated launch site center
			private _name = format ["battery_center_%1", _i];
			deletemarker _name;
			private _avgPos = _batteries select _i select 1;
			private _mrk = createMarker [_name, [_avgPos select 0, _avgPos select 1, 0]];
			_mrk setMarkerType "hd_destroy";
			_mrk setMarkerColor "ColorRed";
			_mrk setMarkerText (format ["N:%1 time:%2", (_batteries select _i) select 2, (_batteries select _i) select 3]);
			
			//Marker for the launch site border
			_name = format ["battery_%1", _i];
			deleteMarker _name;
			private _c = _batteries select _i select 0;
			_mrk = createMarker [_name,
					[	0.5*((_c select 0) + (_c select 2)),
						0.5*((_c select 1) + (_c select 3)),
						0]];
			private _width = 0.5*((_c select 2) - (_c select 0)); //0.5*(x2-x1)
			private _height = 0.5*((_c select 3) - (_c select 1)); //0.5*(y2-y1)
			_mrk setMarkerShape "RECTANGLE";
			_mrk setMarkerBrush "SolidFull";
			_mrk setMarkerSize [_width, _height];
			_mrk setMarkerColor "ColorRed";
			_mrk setMarkerAlpha 0.3;
		};
		
		//==== Enemy monitor ====
		private _e = globalEnemyMonitor call sense_fnc_enemyMonitor_getActiveClusters;
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
			_mrk setMarkerColor "ColorBlue";
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
			_mrk setMarkerColor "ColorBlue";
			_mrk setMarkerAlpha 0.3;
		};
	};
};
*/

//_null = [] spawn fn_highLevelScript;

[sense_enemyMonitorEast, sense_soundMonitorEast, EAST] spawn cmr_fnc_senseMonitor;
[sense_enemyMonitorWest, sense_soundMonitorWest, WEST] spawn cmr_fnc_senseMonitor;
[sense_enemyMonitorInd, sense_soundMonitorInd, INDEPENDENT] spawn cmr_fnc_senseMonitor;

//Assign all garrisons to missions
false spawn AI_fnc_mission_missionMonitor;