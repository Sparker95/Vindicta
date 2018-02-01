/*
Mortar fire detection system.
*/

sense_fnc_artilleryRadar_create =
{
	/*
	This function creates the artillery radar object. Typically one per side/faction.
	*/
	//private _o = groupLogic createUnit ["LOGIC", [77, 77, 77], [], 0, "NONE"];
	private _o = "Sign_Arrow_Large_Pink_F" createVehicle [7, 7, 7];
	hideObjectGlobal _o;
	
	//Array with clusters of spotted launch sites of mortar shells
	//A new element per every spotted mortar shell.
	_o setVariable ["r_sites", [], false]; //[_x, _y] pos of reported artillery shell
	
	//Array with active batteries currently firing
	//Each element is: [0:_cluster, 1:_avgpos, 2:_nShots, 3:_age]
	_o setVariable ["r_batteries", [], false];
	
	//The time variable is being updated every time getActiveClusters is being called
	_o setVariable ["r_time", time, false];
	
	_o setVariable ["r_markerCounter", 0, false];
	//Spawn the script\
	//_hScript = [_o] spawn sense_fnc_artilleryRadar;
	//_o setVariable ["r_hScript", _hScript];
	_o
};

sense_fnc_artilleryRadar_getActiveClusters =
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
	
	private _timeCurrent = time;
	private _time = _radar getVariable ["r_time", _timeCurrent-1];
	private _dt = _timeCurrent - _time; //How much time has passed since last time the function was called
	_radar setVariable ["r_time", _timeCurrent, false];
	
	//Cluster measured launch sites into artillery batteries
	private _sites = _radar getVariable ["r_sites", []]; //Each element is: [_x, _y, _size]
	_radar setVariable ["r_sites", []];
	if (count _sites > 0) then
	{
		//Convert positions of measured launch sites to clusters
		private _sitesClusters = [];
		{
			private _sx = _x select 0;
			private _sy = _x select 1;
			private _size = _x select 2;
			_sitesClusters pushBack ([_sx - _size, _sy - _size, _sx + _size, _sy + _size, _foreachindex] call cluster_fnc_newCluster);
		} forEach _sites;
		
		//diag_log format ["Spotted launch sites: %1", _sites];
		private _batteriesCurrent = [_sitesClusters, 100] call cluster_fnc_findClusters;
		//diag_log format ["Output: %1 clusters", count _batteriesCurrent];
		
		/*
		//Output
		{
			private _border = [_x select 0, _x select 1, _x select 2, _x select 3];
			//diag_log format ["Output cluster: %1, borders: %2", _foreachindex, _border];
			//diag_log format ["  object IDs: %1", _x select 4];
		} forEach _batteriesCurrent;
		*/
		
		//Check batteries that have been previously firing
		private _batteriesActive = _radar getVariable ["r_batteries", []];
		{ //forEach _batteriesCurrent;
			//Check if the current cluster can be attached to another cluster
			private _c1 = _x; //Current battery
			private _found = false;
			{ //forEach _batteriesActive;
				private _bActive = _x; //Active battery
				if (([_c1, (_bActive select 0)] call cluster_fnc_distance) < 20) exitWith
				{
					//Merge batteries
					private _newIDs = _c1 select 4; //IDs of sites in the new created clusters
					private _newn = count _newIDs;
					private _xAvg = (_bActive select 1) select 0;
					private _yAvg = (_bActive select 1) select 1;
					private _n = _bActive select 2;
					{
						private _id = _x;
						private _centerx = (_sites select _id) select 0;
						private _centery = (_sites select _id) select 1;
						//Update the averaged position
						_xAvg = _xAvg*_n/(_n+1) + (_centerx)/(_n+1);
						_yAvg = _yAvg*_n/(_n+1) + (_centery)/(_n+1);
						_n = _n + 1;
					} forEach _newIDs;
					_bActive set [1, [_xAvg, _yAvg]]; //Store new averaged position
					_bActive set [2, _n]; //Number of shots fired
					_bActive set [3, 0]; //Reset the age of the threat
					_c1 set [4, []]; //Clear the array with IDs of the current cluster before merging, because we don't need it
					[_x select 0, _c1] call cluster_fnc_merge;
					
					_found = true;
				};
			} forEach _batteriesActive;
			
			//If current cluster wasn't attached to already existing cluster, create a new active battery
			if (!_found) then
			{
				private _xAvg = 0;
				private _yAvg = 0;
				//Check all sites with IDs from this cluster
				//diag_log format [" IDs: %1, sites: %2", _c1 select 4, _sites];
				{
					private _id = _x;
					private _centerx = (_sites select _id) select 0;
					private _centery = (_sites select _id) select 1;
					_xAvg = _xAvg + _centerx;
					_yAvg = _yAvg + _centery;
				} forEach (_c1 select 4);
				private _n = count (_c1 select 4); //Number of points in this cluster
				_xAvg = _xAvg / _n;
				_yAvg = _yAvg / _n;
				_c1 set [4, []]; //Clear the array with IDs before merging, because we don't need it
				private _newBat = [_c1, [_xAvg, _yAvg], _n, 0];
				_batteriesActive pushBack _newBat; //Add it to the active batteries list
			};
		} forEach _batteriesCurrent;
	};
	
	//Update age of previously known threats
	private _batteriesActive = _radar getVariable ["r_batteries", []];
	{ //forEach _batteriesActive;
		private _age = _x select 3;
		_x set [3, _age + _dt];
		
		//Output
		//diag_log format ["  known threat: %1", _x];		
	} forEach _batteriesActive;
	_batteriesActive
};

sense_fnc_artilleryRadar_getNewThreats =
{
	/*
	Returns an array with new detected launch positions.
	
	Parameters:
		_radar - the radar object
	
	Return value:
	array of: [_x, _y, _3sigma] per every reported mortar shell
	*/
	params ["_radar"];
	private _sites = _radar getVariable ["r_sites", []];
	_radar setVariable ["r_sites", [], false];
	_sites
};

sense_fnc_artilleryRadar_reportFire =
{
	/*
	This function sends data about artillery fire position to the global radar system.
	*/
	params ["_radar", "_posLaunch", "_posLand"];
	
	//Add some error based on distance
	private _d = _posLaunch distance2D _posLand;
	private _c = (70/1000); //Error per distance
	private _3sigma = _c*_d;
	private _lx = _posLaunch select 0;
	private _ly = _posLaunch select 1;
	private _dx = random [-_3sigma, 0, _3sigma];
	private _dy = random [-_3sigma, 0, _3sigma];
	private _mx = _lx + _dx; //Measured coordinates
	private _my = _ly + _dy;
	//private _posLaunchM = [_mx, _my]; //Measured position
	diag_log format ["Reporting artillery fire: distance: %1, 3 sigma: %2", _d, _3sigma];
	
	//Add the launch site to the array
	private _sites = _radar getVariable ["r_sites", []];
	private _newID = count _sites;
	_3sigma = 0.5*_3sigma;
	_sites pushBack [_mx, _my, _3sigma];

	//Create a marker	
	private _counter = _radar getVariable ["r_markerCounter", 0];
	_mrkName = format ["artSite_%1", _counter];
	_counter = _counter + 1;
	_radar setVariable ["r_markerCounter", _counter, false];	
	//diag_log format ["Creating marker: %1, position: %2", _mrkName, [_mx, _my]];
	private _mrk = createMarkerLocal [_mrkName, [_mx, _my, 0]];
	_mrk setMarkerTypeLocal "hd_dot";
	_mrk setMarkerColorLocal "ColorRed";
	
};
