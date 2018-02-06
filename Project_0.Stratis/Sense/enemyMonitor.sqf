/*
These functions are related to enemy monitor.
The purpose of enemy monitor is to gather data from AI/medium/manageSpottedEnemies scripts.

Return value:
[_enemyObjects, _enemyPos, _enemyAge, _clustersNew, _efficiencies]
_clustersNew: [0:cluster, 1:cluster ID, 2:time, 3:reportedBy, 4:garrisons]
*/

//Minimum distance between enemies until they are treated as a single cluster
#define DISTANCE_MIN 500
//forget time in seconds
#define FORGET_TIME 600

sense_fnc_enemyMonitor_create =
{
	/*
	Creates a new enemy monitor object. Typically one per side/faction.
	
	Parameters: none
	
	Return value: enemyMonitor object.
	*/
	//Create a logic object
	//private _o = groupLogic createUnit ["LOGIC", [55, 55, 55], [], 0, "NONE"];
	private _o = "Sign_Arrow_Large_Pink_F" createVehicle [5, 5, 5];
	hideObjectGlobal _o;
	_o setVariable ["s_scriptObjects", []];				//Script objects
	_o setVariable ["s_enemyObjects", [], false];		//Known objects(enemies)
	_o setVariable ["s_enemyPos", [], false];			//Positions of known objects
	_o setVariable ["s_enemyAge", [], false];			//Age of known objects
	_o setVariable ["s_enemyReportedBy", [], false];	//Garrisons that have reported enemies
	_o setVariable ["s_time", time, false];				//The time is used to update age of known threats
	_o setVariable ["s_clusters", [], false];			//Array with clusters: [[cluster_0, ID_0], [cluster_1, ID_1], ...]
	_o setVariable ["s_nextClusterID", 0, false];		//Counter for generating new IDs for clusters
	//Return value
	_o
};

sense_fnc_enemyMonitor_addScript =
{
	/*
	Adds a manageSpottedEnemies script object to the enemyMonitor object.
	
	Parameters:
	
	Return value: nothing
	*/
	params ["_scriptObject"];
	private _em = objNull; //Enemy monitor
	private _side = CIVILIAN;
	private _side = _scriptObject call AI_fnc_mediumLevel_getSide;
	switch (_side) do
	{
		case EAST: {_em = sense_enemyMonitorEast; };
		case WEST: {_em = sense_enemyMonitorWEST; };
		case INDEPENDENT: {_em = sense_enemyMonitorInd; };		
	};
	if (isNull _em) exitWith
	{
		diag_log format ["ERROR: sense_fnc_enemyMonitor_addScript: wrong side: %1", _side];
	};
	private _scriptObjects = _em getVariable ["s_scriptObjects", []];
	_scriptObjects pushBack _scriptObject;
};

sense_fnc_enemyMonitor_removeScript =
{
	/*
	Removes a manageSpottedEnemies script object from the enemyMonitor object.
	
	Parameters:
	
	Return value: success - bool, if the operation was completed successfully
	*/
	params ["_scriptObject"];
	private _side = _scriptObject call AI_fnc_mediumLevel_getSide;
	private _em = objNull;
	switch (_side) do
	{
		case EAST: {_em = sense_enemyMonitorEast; };
		case WEST: {_em = sense_enemyMonitorWEST; };
		case INDEPENDENT: {_em = sense_enemyMonitorInd; };		
	};
	if (isNull _em) exitWith
	{
		diag_log format ["ERROR: sense_fnc_enemyMonitor_addScript: wrong side: %1", _side];
	};
	private _scriptObjects = _em getVariable ["s_scriptObjects", []];
	private _id = _scriptObjects find _scriptObject;
	if (_id != -1) exitWith
	{
		_scriptObjects deleteAt _id;
		true
	};
	false
};

sense_fnc_enemyMonitor_getActiveClusters =
{
	/*
	Returns clusters with enemies.
	*/
	
	params ["_enemyMonitor"];
	
	//Update time
	private _timeCurrent = time;
	private _time = _enemyMonitor getVariable ["s_time", _timeCurrent];
	private _dt = _timeCurrent - _time;
	_enemyMonitor setVariable ["s_time", _timeCurrent];
	
	private _scriptObjects = _enemyMonitor getVariable ["s_scriptObjects", []];	
	private _enemyObjects = _enemyMonitor getVariable ["s_enemyObjects", []];
	private _enemyReportedBy = _enemyMonitor getVariable ["s_enemyReportedBy", []];
	private _enemyPos = _enemyMonitor getVariable ["s_enemyPos", []];
	private _enemyAge = _enemyMonitor getVariable ["s_enemyAge", []];
	
	//Remove scripts which have terminated
	/*
	private _scriptObjectsNull = _scriptObjects select {isNull _x};
	if (count _scriptObjectsNull > 0) then
	{
		_scriptObjects = _scriptObjects - _scriptObjectsNull;
		_enemyMonitor setVariable ["s_scriptObjects", _scriptObjects, false];
	};
	*/

	//Remove enemies which haven't been seen for too long, or dead or non existant
	private _i = 0;
	private _count = count _enemyObjects;
	while {_i < _count} do
	{
		private _age = _enemyAge select _i;
		private _o = _enemyObjects select _i;
		_age = _age + _dt;
		if ((_age > FORGET_TIME) || (isNull _o) || !(alive _o)) then {
			_enemyObjects deleteAt _i;
			_enemyPos deleteAt _i;
			_enemyAge deleteAt _i;			
			_enemyReportedBy deleteAt _i;
			_count = _count - 1;
		} else {
			_enemyAge set [_i, _age];
			_i = _i + 1;
		};
	};
	
	//Update database of known enemies
	{ //forEach _scriptObjects;
		private _scriptObject = _x;
		private _a = _scriptObject call AI_fnc_getReportedEnemies;
		_a params ["_newObjects", "_newPos", "_newAge"];
		{ //forEach _newObjects;
			private _o = _x;
			if(alive _o && !(isNull _o)) then
			{
				private _indexOld = _enemyObjects find _o;
				private _age = _newAge select _forEachIndex;
				private _pos = _newPos select _forEachIndex;
				//Check if the new reported object is already known
				if (_indexOld != -1) then {
					if(_age < (_enemyAge select _indexOld)) then {
						//Update data on known position and age
						_enemyPos set [_indexOld, _pos];
						_enemyAge set [_indexOld, _age];
						//Old reported-by array PLUS the garrisons that report this enemy
						private _erbyNew = (_enemyReportedBy select _indexOld) + (_scriptObject call AI_fnc_mediumLevel_getGarrisons);
						_erbyNew = _erbyNew arrayIntersect _erbyNew; //Find unique elements
						_enemyReportedBy set [_indexOld, _erbyNew];
					};
				}
				else {
					//Check if the age is below the forget time
					if (_age < FORGET_TIME) then {
						//Add the threat to the array
						_enemyObjects pushBack _o;
						_enemyPos pushBack _pos;
						_enemyAge pushBack _age;
						//Get garrisons report this enemy
						_enemyReportedBy pushBack (_scriptObject call AI_fnc_mediumLevel_getGarrisons);
					};
				};
			};
		} forEach _newObjects;
	} forEach _scriptObjects;
	
	//Update database arrays of the enemyMonitor object
	_enemyMonitor setVariable ["s_enemyObjects", _enemyObjects, false];
	_enemyMonitor setVariable ["s_enemyReportedBy", _enemyReportedBy, false];
	_enemyMonitor setVariable ["s_enemyPos", _enemyPos, false];
	_enemyMonitor setVariable ["s_enemyAge", _enemyAge, false];
	
	//Make clusters from individual enemies
	//First convert all the positions into tiny clusters
	private _smallClusters = [];
	for "_i" from 0 to ((count _enemyObjects) - 1) do
	{
		private _pos = _enemyPos select _i;
		private _newCluster = [_pos select 0, _pos select 1, _pos select 0, _pos select 1, _enemyObjects select _i] call cluster_fnc_newCluster;
		_smallClusters pushBack _newCluster;
	};
	
	//Find bigger clusters from smaller clusters
	private _clustersNew = [_smallClusters, DISTANCE_MIN] call cluster_fnc_findClusters;
	_clustersNew = _clustersNew apply {[_x, -1, 0, [], []]}; //[0:cluster, 1:cluster ID, 2:time, 3:reportedBy, 4:garrisons]
	
	//Compare new clusters with old clusters
	private _clustersOld = _enemyMonitor getVariable "s_clusters";
	//How much old and new clusters resemble each other
	private _affinity = []; // [_affinity, _oldIndex, _newIndex]
	private _cc = count _clustersNew;
	for "_i" from 0 to ((count _clustersOld) - 1) do
	{
		for "_j" from 0 to (_cc-1) do
		{
			//Calculate affinity: how many units from old clusters are present in the new cluster
			private _a = count ((_clustersOld select _i select 0 select 4) arrayIntersect (_clustersNew select _j select 0 select 4));
			if (_a > 0) then {
				_affinity pushBack [_a, _i, _j];
			};
		};
	};
	//Assign IDs to clusters
	_affinity sort false; //Descending order
	for "_i" from 0 to ((count _affinity) - 1) do {
		private _indexOld = _affinity select _i select 1;
		private _indexNew = _affinity select _i select 2;
		private _IDOld = _clustersOld select _indexOld select 1;
		private _IDNew = _clustersNew select _indexNew select 1;
		if (_IDNew == -1 && _IDOld != -1) then { //If the new ID isn't assigned and the old ID hasn't been used
			//Transfer the ID from old cluster to new cluster
			(_clustersNew select _indexNew) set [1, _IDOld];
			(_clustersOld select _indexOld) set [1, -1];
			//Transfer the time of the cluster
			private _timeOld = _clustersOld select _indexOld select 2;
			(_clustersNew select _indexNew) set [2, _timeOld];
		};
	};
	//Make new IDs for clusters without IDs
	//Find which garrisons this cluster is reported by
	private _nextClusterID = _enemyMonitor getVariable "s_nextClusterID";
	for "_i" from 0 to ((count _clustersNew) - 1) do {
		//Assign new IDs
		private _cluster = _clustersNew select _i;
		private _ID = _cluster select 1;
		if (_ID == -1) then { //If the ID hasn't been assigned
			//Make new ID
			_cluster set [1, _nextClusterID];
			_nextClusterID = _nextClusterID + 1;
		};
		//Find garrisons that report this cluster
		private _rBy = [];
		private _uhs = _cluster select 0 select 4; //Unit handles
		for "_j" from 0 to ((count _uhs) - 1) do {
			private _uid = _enemyObjects find (_uhs select _j); //Unit's ID in the enemyObjects array
			_rBy append (_enemyReportedBy select _uid);
		};	
		//Find unique elements
		_cluster set [3, _rBy arrayIntersect _rBy];
	};
	_enemyMonitor setVariable ["s_nextClusterID", _nextClusterID, false];
	
	//Store the clusters
	_enemyMonitor setVariable ["s_clusters", _clustersNew, false];
	
	//Increase the time of each cluster
	for "_i" from 0 to ((count _clustersNew) - 1) do {
		private _c = _clustersNew select _i;
		private _time = _c select 2;
		_time = _time + _dt;
		_c set [2, _time];
	};
	
	//Calculate enemy efficiencies of clusters
	//Calculate garrisons in each clusters
	private _efficiencies = [];
	for "_i" from 0 to ((count _clustersNew) - 1) do
	{
		private _clusterStruct = _clustersNew select _i;
		private _c = _clusterStruct select 0;
		private _uhs = _c select 4; //Unit handles in this cluster
		private _eff = T_EFF_null;
		private _garrisons = [];
		//Sum efficiencies of all enemies inside the cluster
		for "_j" from 0 to ((count _uhs) - 1) do
		{
			//Sum efficiencies
			private _uh = _uhs select _j; //Unit handle
			private _ue = (_uh call gar_fnc_getUnitData) call T_fnc_getEfficiency; 
			_eff = [_eff, _ue] call BIS_fnc_vectorAdd;
			//Find garrisons in this cluster
			_garrisons pushBackUnique (_uh call gar_fnc_getUnitGarrison);
		};
		_clusterStruct set [4, _garrisons];
		_efficiencies pushBack _eff;
	};
	
	//Return value
	[_enemyObjects, _enemyPos, _enemyAge, _clustersNew, _efficiencies]
};
