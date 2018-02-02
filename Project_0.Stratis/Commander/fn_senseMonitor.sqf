/*
This thread takes data from sense objects and displays it on the map
*/

#define TIME_SLEEP 5

#define DEBUG_MISSIONS
#define DEBUG_ENEMIES

params ["_enemyMonitor", "_side"];

private _colorEnemy = "ColorEAST";
private _colorFriendly = "ColorEAST";
private _mrkEnemyName = "";
private _mrkEnemyClusterName = "";
private _mrkEnemyClusterEffName = "";
private _mrkMissionName = "";
switch (_side) do
{
	case EAST: {
		_colorEnemy = "ColorEAST";
		_colorFriendly = "ColorEAST";
		_mrkMissionName = "m_east_%1";
		_mrkEnemyName = "eo_east_%1";
		_mrkEnemyClusterName = "eoc_east_%1";
		_mrkEnemyClusterEffName = "eoceff_east_%1";
		};
	case WEST: {
		_colorEnemy = "ColorWEST";
		_colorFriendly = "ColorWEST";
		_mrkEnemyName = "eo_west_%1";
		_mrkMissionName = "m_west_%1";
		_mrkEnemyClusterName = "eoc_west_%1";		
		_mrkEnemyClusterEffName = "eoceff_west_%1";
	};
	case INDEPENDENT: {
		_colorEnemy = "ColorGUER";
		_colorFriendly = "ColorGUER";
		_mrkEnemyName = "eo_ind_%1";
		_mrkMissionName = "m_ind_%1";
		_mrkEnemyClusterName = "eoc_ind_%1";
		_mrkEnemyClusterEffName = "eoceff_ind_%1";
	};
};

private _counterEnemies = 0;
private _counterEnemiesClusters = 0;
private _counterMissions = 0;

while {true} do
{
	//==== Enemy monitor ====
	#ifdef DEBUG_ENEMIES
		private _t = time;
		private _e = _enemyMonitor call sense_fnc_enemyMonitor_getActiveClusters;
		diag_log format ["==== TIME SPENT: %1 ms", (time - _t)*1000];
		//diag_log format ["Global enemies: %1", _e select 0];
		//diag_log format ["Global enemies pos: %1", _e select 1];
		//diag_log format ["Global enemies age: %1", _e select 2];
		
		//Create markers
		for [{_i = 0}, {_i < _counterEnemies}, {_i = _i + 1}] do
		{
			private _name = format [_mrkEnemyName, _i];
			deletemarker _name;
		};
		_counterEnemies = count (_e select 0);
		for [{_i = 0}, {_i < _counterEnemies}, {_i = _i + 1}] do
		{
			//Marker for each spotted enemy
			private _name = format [_mrkEnemyName, _i];
			private _mrk = createmarker [_name, (_e select 1) select _i];
			_mrk setMarkerType "mil_box";
			_mrk setMarkerColor _colorEnemy;
			_mrk setMarkerAlpha 0.4;
			_mrk setMarkerText (format ["%1", round ((_e select 2) select _i)]);
		};
		//Rectangles for clusters
		//diag_log format ["_counterEnemiesClusters: %1", _counterEnemiesClusters];
		//Delete old markers
		for [{_i = 0}, {_i < _counterEnemiesClusters}, {_i = _i + 1}] do
		{
			private _name = format [_mrkEnemyClusterName, _i];
			//diag_log format ["deleting cluster: %1"];
			deleteMarker _name;
			//Marker with efficiency text
			_name = format [_mrkEnemyClusterEffName, _i];
			deleteMarker _name;
		};
		private _eclustersAndIDs = _e select 3; //Array with [_cluster, _ID]
		private _efficiencies = _e select 4;
		_counterEnemiesClusters = count _eclustersAndIDs;
		//diag_log format ["Clusters with enemies: %1", _eclusters];
		for [{_i = 0}, {_i < _counterEnemiesClusters}, {_i = _i + 1}] do
		{
			//Marker for the cluster
			_name = format [_mrkEnemyClusterName, _i];
			private _c = _eclustersAndIDs select _i select 0;
			private _cID = _eclustersAndIDs select _i select 1;
			private _cTime = _eclustersAndIDs select _i select 2;
			private _cCenter = _c call cluster_fnc_getCenter;
			_mrk = createMarker [_name, _cCenter];
			private _width = 10 + 0.5*((_c select 2) - (_c select 0)); //0.5*(x2-x1)
			private _height = 10 + 0.5*((_c select 3) - (_c select 1)); //0.5*(y2-y1)
			_mrk setMarkerShape "RECTANGLE";
			_mrk setMarkerBrush "SolidFull";
			_mrk setMarkerSize [_width, _height];
			_mrk setMarkerColor _colorEnemy;
			_mrk setMarkerAlpha 0.3;
			//Marker for the cluster ID and efficiency
			private _eff = _efficiencies select _i; //Vector with total efficiency of the cluster
			_name = format [_mrkEnemyClusterEffName, _i];
			_mrk = createMarker [_name, _cCenter];
			_mrk setMarkerType "mil_dot";
			_mrk setMarkerColor _colorEnemy;
			_mrk setMarkerText format ["ID: %1, T: %2, E: %3", _cID, round _cTime, _eff]; //ID: efficiency
		};
	#endif
	
	#ifdef DEBUG_MISSIONS
		//Draw markers for missions
		//Delete previous markers
		for "_i" from 0 to (_counterMissions - 1) do {
			private _name = format[_mrkMissionName, _i];
			deleteMarker _name;
		};
		//Draw new markers
		private _missions = allMissions select {_x call AI_fnc_mission_getSide == _side};
		_counterMissions = count _missions;
		for "_i" from 0 to (_counterMissions - 1) do {
			private _m = _missions select _i;
			//Get mission position
			private _mParams = _m getVariable "AI_m_params";
			_mParams params ["_target"];
			private _pos = if (_target isEqualType objNull) then { getPos _target } else { _target };
			//Draw marker
			private _name = format [_mrkMissionName, _i];
			private _mrk = createmarker [_name, _pos];
			_mrk setMarkerType "hd_objective"; //Objective (circle with two crosses)
			_mrk setMarkerColor _colorFriendly;
			_mrk setMarkerAlpha 1.0;
			_mrk setMarkerText (format ["Mission: %1, %2, %3",
				_m call AI_fnc_mission_getType, _m call AI_fnc_mission_getRequirements, _m call AI_fnc_mission_getState]);
		};
	#endif

	sleep TIME_SLEEP;
};