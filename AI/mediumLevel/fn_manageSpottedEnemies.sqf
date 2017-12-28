/*
This script checks for spotted enemies among all groups and shares the infomation about enemies with other groups of this garrison.
The gathered information is also stored in garrison's special variable to be read by other modules.

parameters:
_gar - the garrison object where the data on reported enemies will be sent.
_extraParams: [_loc, _handleAlertState]
	_loc - the location object where requests to change alert state will be sent.
	_handleAlertState - bool - if true, this script will be handling the alert state of the garrison.
*/

//todo remove double buffer switching! It makes no sense.

params ["_scriptObject", "_extraParams"];

private _gar = _scriptObject getVariable ["AI_garrison", objNull];

//Read extra parameters
private _loc = _extraParams select 0;
private _handleAlertState = _extraParams select 1;
private _newAS = LOC_AS_safe;

private _side = [_gar] call gar_fnc_getSide;
private _groupsData = []; //[_groupHandle, _behaviour, timer]
private _hGs = [_gar, -1] call gar_fnc_findGroupHandles; //Get group handles of the garrison
{
	_groupsData pushback [_x, behaviour (leader _x), 0];
}forEach _hGs;

private _timeReveal = 5; //Time(in seconds) a group can be in combat mode before revealing its enemy to whole garrison.
private _timeRevealCounter = 0;
private _timeSleep = 2; //Sleep time between checking all groups
private _timeReport = 10; //Time between enemies being spotted and enemies being reported to garrison object.
private _timeReportCounter = 0;
private _reportArrayID = 0;
private _allTargetsReportObjects = [[], []];
private _allTargetsReportpos = [[], []];


private _combatPrev = false; //Combat mode at previous iteration
while {true} do
{
	sleep _timeSleep;
	
	private _i = 0;
	private _setNewAS = false;
	private _allTargets = []; //Array of objects
	private _allTargetsKnowsAbout = [];
	private _combat = false; //Is any squad in combat mode?
	private _nt = []; //NearTargets
	private _NGroups = count _groupsData;
	while {_i < _NGroups} do
	{
		_hG = _hGs select _i; //Group handle
		
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
		//Check if it's time to reveal enemies to other squads
		_timeRevealCounter = _timeRevealCounter + _timeSleep;
		if (_timeRevealCounter >= _timeReveal) then
		{
			_timeRevealCounter = _timeRevealCounter - _timeReveal;
			_allTargets = [];
			//Find new enemies
			{
				_hG = _x;
				_nt = (leader _hG) targetsQuery [objNull, sideUnknown, "", [], _timeReveal];
				{
					private _s = _x select 2; //Side of the target
					private _age = _x select 5; //Target age
					if(_s != _side && (_s in [EAST, WEST, INDEPENDENT]) && (_age <= _timeReveal)) then //If target's side is enemy
					{
						_allTargets pushBack [_x select 1, _hG knowsAbout (_x select 1), _x select 4, _x select 5];
					};
				} forEach _nt;
			} forEach _hGs;
			
			//Reveal enemies to other squads
			if (count _allTargets > 0) then
			{
				diag_log format ["fn_manageSpottedEnemies.sqf: revealing targets: %1", _allTargets];
				_i = 0;
				{
					private _hG = _x;
					{
						_hG reveal [_x select 0, _x select 1];
					}forEach _allTargets;
					_i = _i + 1;
				} forEach _hGs;
				
				//Handle new alert state
				_newAS = LOC_AS_combat;
			};
			
		};

		//Check if it's time to report enemies to garrison object
		_timeReportCounter = _timeReportCounter + _timeSleep;
		if(_timeReportCounter >= _timeReport) then
		{
			_timeReportCounter = _timeReportCounter - _timeReport;
			
			_reportArrayID = (_reportArrayID + 1) mod 2; //Switch between 0, 1, 0, 1, ...
			_allTargetsReportObjects set [_reportArrayID, []];
			_allTargetsReportPos set [_reportArrayID, []];				
			private _reportArrayObjects = _allTargetsReportObjects select _reportArrayID;
			private _reportArrayPos = _allTargetsReportPos select _reportArrayID;
			
			//Find new enemies
			{
				_hG = _x;
				_nt = (leader _hG) targetsQuery [objNull, sideUnknown, "", [], 0]; //Any age enemies are fine
				{
					private _o = _x select 1;
					private _s = _x select 2; //Side of the target
					private _age = _x select 5; //Target age
					//diag_log format ["side: %1 obj: %2 age: %3", _s, _o, _age];
					//Check only enemies older than some threshold
					if(_s != _side && (_s in [EAST, WEST, INDEPENDENT]) && (_age > _timeReport)) then // &&
					//	(_hG knowsAbout _o) > 0) then 
					{
						//diag_log format ["  %1 knows about %2: %3", _hG, _o, _hG knowsAbout _o];
						if ((_reportArrayObjects pushBackUnique _o) != -1) then
						{
							_reportArrayPos pushBack (_x select 4);
						};
					};
				} forEach _nt;
			} forEach _hGs;
			//diag_log format ["reporting: %1", _reportArrayObjects];
			[_gar, _reportArrayObjects, _reportArrayPos, false] call gar_fnc_reportSpottedEnemies;
			if (count _reportArrayObjects > 0) then
			{
				//Handle new alert state
				_newAS = LOC_AS_combat;
			};
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
			//Report no enemies to garrison object
			[_gar, [], []] call gar_fnc_reportSpottedEnemies;
			//Request to change the location's alert state
			_newAS = LOC_AS_safe;
		};
		_combatPrev = false;
	};
	
	//If needed, send requests to change alert state to the location
	if (_handleAlertState) then
	{
		//Send data to the location object
		[_loc, _newAS] call loc_fnc_setAlertStateInternal;
	};
};