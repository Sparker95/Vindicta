/*
Mortar fire detection system.
*/

sense_fnc_createArtilleryRadar =
{
	/*
	This function creates the artillery radar object.
	*/
	private _o = groupLogic createUnit ["LOGIC", [77, 77, 77], [], 0, "NONE"];
	
	//Array with clusters of spotted launch sites of mortar shells
	//A new element per every spotted mortar shell
	_o setVariable ["r_sites", [], false];
	
	//Array with active batteries currently firing
	//Each element is: [0:_cluster, 1:_avgpos, 2:_nShots, 3:_age]
	_o setVariable ["r_batteries", [], false];
	
	_o setVariable ["r_markerCounter", 0, false];
	//Spawn the script\
	_hScript = [_o] spawn sense_fnc_artilleryRadar;
	_o setVariable ["r_hScript", _hScript];
	_o
};

sense_fnc_artilleryRadar =
{
	/*
	This script handles data about artillery fire coming to the global artillery radar system.
	*/
	params ["_radar"];
	
	private _st = 6; //Sleep time
	
	while {true} do
	{
		sleep _st;
		
		//Cluster measured launch sites into artillery batteries
		private _sites = _radar getVariable ["r_sites", []];
		private _sitesCopy = +_sites;
		_radar setVariable ["r_sites", []];
		if (count _sites > 0) then
		{
			//diag_log format ["Spotted launch sites: %1", _sites];
			private _batteriesCurrent = [_sitesCopy, 100] call cluster_fnc_findClusters;
			//diag_log format ["Output: %1 clusters", count _batteriesCurrent];
			
			//Output
			{
				private _border = [_x select 0, _x select 1, _x select 2, _x select 3];
				//diag_log format ["Output cluster: %1, borders: %2", _foreachindex, _border];
				//diag_log format ["  object IDs: %1", _x select 4];
			} forEach _batteriesCurrent;
			
			//Check batteries previously firing
			private _batteriesActive = _radar getVariable ["r_batteries", []];
			{ //forEach _batteriesCurrent;
				//Check if the current cluster can be attached to another cluster
				private _c1 = _x; //Current battery
				private _found = false;
				{ //forEach _batteriesActive;
					if (([_c1, (_x select 0)] call cluster_fnc_distance) < 20) exitWith
					{
						//Merge batteries
						private _newIDs = _c1 select 4;
						private _newn = count _newIDs;
						private _xAvg = (_x select 1) select 0;
						private _yAvg = (_x select 1) select 1;
						private _n = _x select 2;
						{
							private _center = [_sites select _x] call cluster_fnc_getCenter;
							//Update the averaged position
							_xAvg = _xAvg*_n/(_n+1) + (_center select 0)/(_n+1);
							_yAvg = _yAvg*_n/(_n+1) + (_center select 1)/(_n+1);
							_n = _n + 1;
						} forEach _newIDs;
						_x set [1, [_xAvg, _yAvg]]; //Store new averaged position
						_x set [2, _n]; //Number of shots fired
						_x set [3, 0]; //Reset the age of the threat
						_c1 set [4, []]; //Clear the array with IDs before merging, because we don't need it
						[_x select 0, _c1] call cluster_fnc_merge;
						
						_found = true;
					};
				} forEach _batteriesActive;
				
				//If current battery wasn't attached to another battery, create a new active battery
				if (!_found) then
				{
					private _xAvg = 0;
					private _yAvg = 0;
					//Check all sites with IDs from this cluster
					//diag_log format [" IDs: %1, sites: %2", _c1 select 4, _sites];
					{
						private _center = [_sites select _x] call cluster_fnc_getCenter;
						_xAvg = _xAvg + (_center select 0);
						_yAvg = _yAvg + (_center select 1);
					} forEach (_c1 select 4);
					private _n = count (_c1 select 4); //Number of points in this cluster
					_xAvg = _xAvg / _n;
					_yAvg = _yAvg / _n;
					_c1 set [4, []]; //Clear the array with IDs before merging, because we don't need it
					private _newBat = [_c1, [_xAvg, _yAvg], _n, 0];
					_batteriesActive pushBack _newBat; //Add it to the active threats list
				};
			} forEach _batteriesCurrent;
		};
		
		//Update age of previously known threats
		private _batteriesActive = _radar getVariable ["r_batteries", []];
		{
			private _age = _x select 3;
			_x set [3, _age + _st];
			
			//Output
			diag_log format ["  known threat: %1", _x];
			
			//Create marker for the cluster
			private _c = _x select 0;
			private _name = format["threat_%1", _foreachindex];
			deleteMarkerLocal _name;
			private _mrk = createMarkerLocal [_name,
					[	0.5*((_c select 0) + (_c select 2)),
						0.5*((_c select 1) + (_c select 3)),
						0]];
			private _width = 0.5*((_c select 2) - (_c select 0)); //0.5*(x2-x1)
			private _height = 0.5*((_c select 3) - (_c select 1)); //0.5*(y2-y1)
			_mrk setMarkerShapeLocal "RECTANGLE";
			_mrk setMarkerBrushLocal "SolidFull";
			_mrk setMarkerSizeLocal [_width, _height];
			_mrk setMarkerColorLocal "ColorGreen";
			_mrk setMarkerAlphaLocal 0.4;
			
			//Create marker for calculated launch center
			private _name = format["threat_center_%1", _foreachindex];
			private _avgPos = _x select 1;
			deleteMarkerLocal _name;
			private _mrk = createMarkerLocal [_name, [_avgPos select 0, _avgPos select 1, 0]];
			_mrk setMarkerTypeLocal "hd_destroy";
			_mrk setMarkerColorLocal "ColorBlue";
			
		} forEach _batteriesActive;
	};
};

sense_fnc_reportArtilleryFire =
{
	/*
	This function sends data about artillery fire position to the global radar system.
	*/
	params ["_radar", "_posLaunch", "_posLand"];
	
	//Add some error based on distance
	private _d = _posLaunch distance2D _posLand;
	private _c = (90/1000); //Error per distance
	private _3sigma = _c*_d;
	private _lx = _posLaunch select 0;
	private _ly = _posLaunch select 1;
	private _dx = random [-_3sigma, 0, _3sigma];
	private _dy = random [-_3sigma, 0, _3sigma];
	private _mx = _lx + _dx; //Measured coordinates
	private _my = _ly + _dy;
	//private _posLaunchM = [_mx, _my]; //Measured position
	diag_log format ["Reporting artillery fire: distance: %1, 3 sigma: %2", _d, _3sigma];
	
	//Create a new cluster array
	private _sites = _radar getVariable ["r_sites", []];
	private _newID = count _sites;
	_3sigma = 0.5*_3sigma;
	_sites pushBack ([_mx - _3sigma, _my - _3sigma, _mx + _3sigma, _my + _3sigma, _newID] call cluster_fnc_newCluster);
	//_sites pushBack ([_mx, _my, _mx, _my, _newID] call cluster_fnc_newCluster);
	
	//Create a marker
	private _counter = _radar getVariable ["r_markerCounter", 0];
	_mrkName = format ["art_%1", _counter];
	_counter = _counter + 1;
	_radar setVariable ["r_markerCounter", _counter, false];
	
	//diag_log format ["Creating marker: %1, position: %2", _mrkName, [_mx, _my]];
	private _mrk = createMarkerLocal [_mrkName, [_mx, _my, 0]];
	_mrk setMarkerTypeLocal "hd_dot";
	_mrk setMarkerColorLocal "ColorRed";
};

sense_fnc_getActiveArtilleryBatteries =
{
	/*
	This function gets active threats (those that have been shooting lately)
	
	Return value:
	array of: [0:_cluster, 1:_avgpos, 2:_nShots, 3:_age]
		_cluster - cluster array of battery. You can use it to estimate the bounds of artillery battery location.
		_avgPos - averaged calculated position
		_nShots - shots totally registered from the battery
		_age - time in seconds since the last artillery shell came from this battery
	*/
	params ["_radar"];
	_radar getVariable ["r_batteries", []];
};