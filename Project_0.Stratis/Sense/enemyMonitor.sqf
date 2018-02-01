/*
These functions are related to enemy monitor.
The purpose of enemy monitor is to gather data from AI/medium/manageSpottedEnemies scripts.
*/

//forget time in seconds
#define FORGET_TIME 300

sense_fnc_enemyMonitor_create =
{
	/*
	Creates a new enemy monitor object. Typically one per side/faction.
	
	Parameters: none
	
	Return value: enemyMonitor object.
	*/
	//Create a logic object
	private _o = groupLogic createUnit ["LOGIC", [55, 55, 55], [], 0, "NONE"];
	_o setVariable ["s_scriptObjects", []]; //Script objects
	_o setVariable ["s_enemyObjects", [], false]; //Known objects(enemies)
	_o setVariable ["s_enemyPos", [], false]; //Positions of known objects
	_o setVariable ["s_enemyAge", [], false]; //Age of known objects
	_o setVariable ["s_time", time, false]; //The time is used to update age of known threats
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
	
	//Remove dead objects and null-objects
	private _i = 0;
	private _count = count _enemyObjects;
	while {_i < _count} do
	{
		private _o = _enemyObjects select _i;
		if ((isNull _o) || !(alive _o)) then
		{
			_enemyObjects deleteAt _i;
			_enemyPos deleteAt _i;
			_enemyAge deleteAt _i;
			_count = _count - 1;
		}
		else {_i = _i + 1;};
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
				if (_indexOld != -1) then
				{
					if(_age < (_enemyAge select _indexOld)) then
					{
						//Update data on known position and age
						_enemyPos set [_indexOld, _pos];
						_enemyAge set [_indexOld, _age];
					};
				}
				else
				{
					//Add the threat to the array
					_enemyObjects pushBack _o;
					_enemyPos pushBack _pos;
					_enemyAge pushBack _age;
				};
			};
		} forEach _newObjects;
	} forEach _scriptObjects;
	
	//Update age of known threats and remove objects that have age above threshold
	private _i = 0;
	private _count = count _enemyObjects;
	while {_i < _count} do
	{
		private _age = _enemyAge select _i;
		_age = _age + _dt;
		if (_age > FORGET_TIME) then
		{
			_enemyObjects deleteAt _i;
			_enemyPos deleteAt _i;
			_enemyAge deleteAt _i;
			_count = _count - 1;
		}
		else
		{
			_enemyAge set [_i, _age];
			_i = _i + 1;
		};
	};
	
	//Update database arrays of the enemyMonitor object
	_enemyMonitor setVariable ["s_enemyObjects", _enemyObjects, false];
	_enemyMonitor setVariable ["s_enemyPos", _enemyPos, false];
	_enemyMonitor setVariable ["s_enemyAge", _enemyAge, false];
	
	//Make clusters from individual enemies
	//First convert all the positions into tiny clusters
	private _smallClusters = [];
	for "_i" from 0 to ((count _enemyObjects) - 1) do
	{
		private _pos = _enemyPos select _i;
		private _newCluster = [_pos select 0, _pos select 1, _pos select 0, _pos select 1, _i] call cluster_fnc_newCluster;
		_smallClusters pushBack _newCluster;
	};
	//Find bigger clusters from smaller clusters
	private _clusters = [_smallClusters, 300] call cluster_fnc_findClusters;
	
	//Return value
	[_enemyObjects, _enemyPos, _enemyAge, _clusters]
};
