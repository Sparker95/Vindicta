/*
This script checks for spotted enemies among all groups and shares the infomation about enemies with other groups of this garrison.
The gathered information is also stored in garrison's special variable to be read by other modules.

parameters:
_extraParams: nothing
*/

//todo remove double buffer switching! It makes no sense.

#define SLEEP_TIME 5

params ["_scriptObject", "_extraParams"];

//Initialize the variable synchronously, in case it will be accessed by other modules right after script starts
private _gars = _scriptObject getVariable ["AI_garrisons", objNull];
private _side = (_gars select 0) call gar_fnc_getSide;
_scriptObject setVariable ["AI_side", _side, false];
_scriptObject setVariable ["AI_reportObjects", [], false];
_scriptObject setVariable ["AI_reportPos", [], false];
_scriptObject setVariable ["AI_reportAge", [], false];
_scriptObject setVariable ["AI_reportArraysMutex", 0, false]; //Mutex is needed to exclude arrays being accessed while they are being updated
_scriptObject setVariable ["AI_requestedAS", LOC_AS_safe, false];

private _hScript = [_scriptObject, _extraParams] spawn
{
	params ["_scriptObject", "_extraParams"];
	private _gars = _scriptObject getVariable ["AI_garrisons", objNull];

	//Read extra parameters
	private _newAS = LOC_AS_safe;

	private _side = [_gars select 0] call gar_fnc_getSide;
	private _groupsData = []; //[_groupHandle, _behaviour, timer]
	//Get group handles of all the garrisons
	private _hGs = [];
	{
		_hGs append ([_x, -1] call gar_fnc_findGroupHandles); 
	} forEach _gars;
	{
		_groupsData pushback [_x, behaviour (leader _x), 0];
	} forEach _hGs;

	private _timeReveal = 5; //Time(in seconds) a group can be in combat mode before revealing its enemy to whole garrison.
	private _timeRevealCounter = 0;
	private _timeSleep = 2; //Sleep time between checking all groups
	private _timeReport = 10; //Time between enemies being spotted and enemies being reported to garrison object.
	private _timeReportCounter = 0;
	private _reportArrayID = 0;
	private _allTargetsReportObjects = [[], []];
	private _allTargetsReportPos = [[], []];


	private _combatPrev = false; //Combat mode at previous iteration
	while {true} do
	{
		sleep SLEEP_TIME;
		
		private _setNewAS = false;
		private _allTargets = []; //Array of objects
		private _allTargetsKnowsAbout = [];
		private _combat = false; //Is any squad in combat mode?
		private _nt = []; //NearTargets
		//Update array with groups
		private _hGsCur = []; //Get groups currently present in the garrisons
		{ _hGsCur append ([_x, -1] call gar_fnc_findGroupHandles); } forEach _gars;
		private _hGsPrev = _groupsData apply {_x select 0}; //Group handles
		//Remove groups which are no longer in the garrisons
		private _hGsRemove = _hGsPrev - _hGsCur; //Array with groups to remove
		if (count _hGsRemove > 0) then
		{			
			private _groupsDataRemove = _groupsData select {(_x select 0) in _hGsRemove};
			_groupsData = _groupsData - _groupsDataRemove;
		};
		//Add new groups
		private _hGsAdd = _hGsCur - _hGsPrev;
		if (count _hGsAdd > 0) then
		{
			{
				_groupsData pushback [_x, behaviour (leader _x), 0];
			} forEach _hGsAdd;
		};
		private _NGroups = count _groupsData;
		
		//Check group behaviours
		private _i = 0;
		while {_i < _NGroups} do
		{
			_hG = (_groupsData select _i) select 0; //Group handle
			
			//Check if the group has been totally destroyed
			private _alive = true;
			if(! isNull _hg) then
			{
				if({alive _x} count (units _hG) == 0) then //If everyone is dead, delete this group from _groupsData array.
				{
					_groupsData deleteAt _i;
					_NGroups = _NGroups - 1;
					_alive = false;
				};
			}
			else
			{
				_groupsData deleteAt _i;
				_NGroups = _NGroups - 1;
				_alive = false;
			};
			
			//If the group is still alive
			if (_alive) then
			{			
				if ((behaviour (leader _hG)) isEqualTO "COMBAT") then
				{
					_combat = true;
				};
				_i = _i + 1;
			};
		};
		
		//Check spotted enemies
		if(_combat) then
		{
			//If previous state is not combat, reset the counters
			if(!_combatPrev) then
			{
				_timeReportCounter = 0;
				_timeRevealCouunter = 0;
			};
			//Check if it's time to reveal enemies to other squads
			_timeRevealCounter = _timeRevealCounter + _timeSleep;
			if (_timeRevealCounter >= _timeReveal) then
			{
				_timeRevealCounter = _timeRevealCounter - _timeReveal;
				_allTargets = [];
				//Find new enemies
				{
					_hG = _x select 0;
					_nt = (leader _hG) targetsQuery [objNull, sideUnknown, "", [], _timeReveal];
					{ //forEach _nt
						private _s = _x select 2; //Side of the target
						private _age = _x select 5; //Target age is the time that has passed since the last time the group has actually seen the enemy unit. Values lower than 0 mean that they see the enemy right now
						//diag_log format ["Age of target %1: %2", _x select 1, _age];
						if(_s != _side && (_s in [EAST, WEST, INDEPENDENT, sideUnknown]) && (_age <= _timeReveal)) then //If target's side is enemy
						{
							_allTargets pushBack [_x select 1, _hG knowsAbout (_x select 1), _x select 4, _x select 5];
						};
					} forEach _nt;
				} forEach _groupsData;
				
				//Reveal enemies to other squads
				if (count _allTargets > 0) then
				{
					diag_log format ["fn_manageSpottedEnemies.sqf: revealing targets: %1", _allTargets];
					_i = 0;
					{
						private _hG = _x select 0;
						{
							_hG reveal [_x select 0, _x select 1];
						}forEach _allTargets;
						_i = _i + 1;
					} forEach _groupsData;
				};
				_newAS = LOC_AS_combat;
			};

			//Check if it's time to report enemies to garrison object
			_timeReportCounter = _timeReportCounter + _timeSleep;
			diag_log format ["Location is in combat state for %1 seconds", _timeReportCounter];
			if(_timeReportCounter >= _timeReport) then
			{
				_timeReportCounter = _timeReportCounter - _timeReport;
				
				_reportArrayID = (_reportArrayID + 1) mod 2; //Switch between 0, 1, 0, 1, ...
				_allTargetsReportObjects set [_reportArrayID, []];
				_allTargetsReportPos set [_reportArrayID, []];				
				
				private _reportObjects = []; //Objects to report
				private _reportPos = []; //Positions of corresponding objects
				private _reportAge = []; //Age of corresponding objects
				
				//Find enemies
				{ //forEach _groupsData
					_hG = _x select 0;
					_nt = (leader _hG) targetsQuery [objNull, sideUnknown, "", [], 0]; //Any age enemies are fine
					//diag_log format ["_nt: %1", _nt];
					{ //forEach _nt
						private _o = _x select 1;
						private _s = _x select 2; //Side of the target
						private _age = _x select 5; //Target age
						//TODO add a check for knowsAbout, because sometimes these fools think they know about enemy while they have no way to see it (like when they report artillery cannon that has killed their comrade from 10km away)
						if(_s != _side && (_s in [EAST, WEST, INDEPENDENT])) then
						{
							//Check if the reported object already exists
							private _pos = _x select 4;
							private _index = _reportObjects find _o;
							if (_index != -1) then
							{
								//Check if the age reported by this group is lower than the age reported before
								if(_age < (_reportAge select _index)) then
								{
									_reportPos set [_index, _pos];
									_reportAge set [_index, _age];
								};
							}
							else
							{
								_reportObjects pushBack _o;
								_reportPos pushBack _pos;
								_reportAge pushBack _age;
							};
						};
					} forEach _nt;
				} forEach _groupsData;
				/*
				diag_log format ["Report objects: %1", _reportObjects];
				diag_log format ["Report pos: %1", _reportPos];
				diag_log format ["Report age: %1", _reportAge];
				*/
				diag_log format ["Reported objects: %1", _reportObjects];
				//Wait until the arrays have been released (see manageSpottedEnemies.sqf)
				waitUntil {(_scriptObject getVariable ["AI_reportArraysMutex", 0]) == 0};
				//Lock the mutex
				_scriptObject setVariable ["AI_reportArraysMutex", 1, false];
				//Update the arrays
				_scriptObject setVariable ["AI_reportObjects", _reportObjects, false];
				_scriptObject setVariable ["AI_reportPos", _reportPos, false];
				_scriptObject setVariable ["AI_reportAge", _reportAge, false];
				//Unlock the mutex
				_scriptObject setVariable ["AI_reportArraysMutex", 0, false];
				
				//diag_log format ["reporting: %1", _reportArrayObjects];
			};
			_combatPrev = true;
		}
		else
		{
			//If previous state was combat, reset the counters
			if(_combatPrev) then
			{
				_timeReportCounter = 0;
				_timeRevealCouunter = 0;
			};
			//New alert state must settle down, in case of rapid switching between alert combat/aware AI behaviour
			_timeReportCounter = _timeReportCounter + _timeSleep;
			if(_timeReportCounter > _timeReport) then
			{
				_timeReportCounter = _timeReportCounter - _timeReport;
				//Report no enemies
				_scriptObject setVariable ["AI_reportObjects", [], false];
				_scriptObject setVariable ["AI_reportPos", [], false];
				_scriptObject setVariable ["AI_reportAge", [], false];
				_newAS = LOC_AS_safe;
			};
			_combatPrev = false;
		};
		
		//Update the requested alert state
		_scriptObject setVariable ["AI_requestedAS", _newAS];
	};
};

[_scriptObject, _hScript, [], ""] call AI_fnc_registerScriptHandle;
_hScript
