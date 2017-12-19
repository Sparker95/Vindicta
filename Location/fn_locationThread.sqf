/*
The main Location thread.
*/
params ["_loc", ["_debug", true]];

diag_log "Hello from location thread!";

private _distanceSpawn = 1000;
private _distanceDespawn = _distanceSpawn + 100;
private _sleepInterval = 0.5;

private _name = _loc getVariable ["l_name", "_"];
private _spawned = false;
private _garMain = [_loc] call loc_fnc_getMainGarrison;
sleep (random _sleepInterval);

private _groupsData = []; //[_grpHandle, _behaviour, _counter]
private _hGsDelete = []; //Group handles marked for deletion(if they get empty)
private _hG = grpNull; //Group handle
private _gar = [_loc] call loc_fnc_getMainGarrison;
private _side = [_gar] call gar_fnc_getSide;

private _GMCounter = 0; //Group monitor counter
private _GMInterval = 2; //The time before checking groups' states
private _revealTime = 6; //The time(in seconds) a group can be in combat mode before revealing its enemy to whole location.

while {true} do
{
	sleep _sleepInterval;
	//diag_log format ["fn_locationThread.sqf: location: %1, simulation: %2", _name, simulationEnabled _loc];
	if(_spawned) then
	{
		if({_x distance _loc < _distanceSpawn && (side _x != _side || (isPlayer _x))} count allUnits == 0) then //If garrison must be despawned
		{
			[_loc] call loc_fnc_despawnAllGarrisons;
			_spawned = false;
		}
		else //Otherwise handle what's going on with the location
		{
			//==== Handling group states ====
			//todo put it to another file??

			if(_GMCounter == 0) then //If it's time to update group states
			{
				private _i = 0;
				private _setNewAS = false;
				private _newAS = 0;
				private _allTargets = []; //Array of [_object, _knowsAbout]
				private _nt = []; //NearTargets
				while {_i < count _groupsData} do
				{
					private _x = _groupsData select _i; //The current element of groupsData
					_hG = _x select 0; //Group handle
					if({alive _x} count (units _hG) == 0) then //If everyone is dead, delete this group from _groupsData array.
					{
						_groupsData deleteAt _i;
					}
					else //If there's someone alive
					{
						private _bP = _x select 1; //Behaviour previous
						private _bC = behaviour (leader _hG); //Behaviour current
						if(_bP isEqualTO "COMBAT") then
						{
							//diag_log format ["fn_locationThread.sqf: location: %1, combat group couter: %2", _name, _x select 2];
							if(_bC isEqualTO "COMBAT") then //If it was combat and it's still combat
							{
								private _t = _x select 2; //Counter, how long the group has been in combat mode
								_t = _t + _GMInterval;
								if(_t > _revealTime) then //If group has been in combat mode for more than _revealTime seconds
								{
									//Find targets of this group
									_nt = (leader _hG) nearTargets _distanceDespawn;
									//Add the targets of this group to global targets array
									{
										private _s = _x select 2;
										if(_s != _side && (_s in [EAST, WEST, INDEPENDENT])) then //If target's side is enemy
										{
											_allTargets pushBack [_x select 4, _hG knowsAbout (_x select 4)];
										};
									}forEach _nt;
									//Switch the location to combat mode
									_t = 0;
									_newAS = G_AS_combat;
									_setNewAS = true;
								};
								_x set [2, _t];
							}
							else //If it was combat and not combat any more
							{
								_x set [1, _bC]; //Set the current behaviour as previous behaviour
								_x set [2, 0]; //Reset the counter
							};
						}
						else
						{
							_x set [1, _bC]; //Set the current behaviour as previous behaviour
						};
						_i = _i + 1;
					};
				};

				//Set new alert state
				if(_setNewAS && ((_loc getVariable ["l_alertState", G_AS_none]) != _newAS)) then
				{
					diag_log format ["fn_locationThread.sqf: location: %1, switching to new alert state: %2", _name, _newAS];
					[_loc getVariable ["l_garrison_main", objNull], _newAS] call gar_fnc_setAlertState;
					_loc setVariable ["l_alertState", _newAS];
					[_loc] call loc_fnc_updateMarker;
				};

				//Reveal targets to everyone in this location
				if(count _allTargets > 0) then
				{
					diag_log format ["fn_locationThread.sqf: revealing all targets: %1", _allTargets];
					_i = 0;
					while {_i < (count _groupsData)} do
					{
						private _hG = _groupsData select _i select 0;
						{
							_hG reveal _x;
						}forEach _allTargets;
						_i = _i + 1;
					};
				};


			};

			//Increase the counter
			_GMCounter = _GMCounter + _sleepInterval;
			if(_GMCounter >= _GMInterval) then
			{
				_GMCounter = _GMCounter - _GMInterval;
			};
		};
	}
	else //If not spawned
	{
		if({_x distance _loc < _distanceSpawn && ((side _x != _side) || (isPlayer _x))} count allUnits > 0) then //If garrison needs to be spawned
		{
			[_loc] call loc_fnc_spawnAllGarrisons;
			waitUntil //Wait until it has spawned
			{
				sleep _sleepInterval;
				[_gar] call gar_fnc_isSpawned
			};
			private _hGs = [_gar] call gar_fnc_getAllGroupHandles; //Get group handles of the spawned garrison
			{
				_groupsData pushback [_x, behaviour (leader _x), 0];
			}forEach _hGs;
			_spawned = true;
		};
	};
};