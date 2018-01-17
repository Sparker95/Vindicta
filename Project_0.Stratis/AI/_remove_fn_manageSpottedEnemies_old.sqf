/*
This script checks for spotted enemies among all groups and shares the infomation about enemies with other groups of this garrison.
The gathered information is also stored in garrison's special variable to be read by other modules.

parameters:
_gar - the garrison object where the data on reported enemies will be sent.
_loc - the location object where requests to change alert state will be sent.
_handleAlertState - bool - if true, this script will be handling the alert state of the garrison.
*/

params ["_gar", ["_loc", objNull], ["_handleAlertState", false]];

private _side = [_gar] call gar_fnc_getSide;
private _groupsData = []; //[_groupHandle, _vehaviour, timer]
private _hGs = [_gar] call gar_fnc_getAllGroupHandles; //Get group handles of the garrison
{
	_groupsData pushback [_x, behaviour (leader _x), 0];
}forEach _hGs;

private _timeReveal = 5; //Time(in seconds) a group can be in combat mode before revealing its enemy to whole garrison.
private _timeSleep = 2; //Sleep time between checking all groups
private _timeReport = 10; //Time between enemies being spotted and enemies being reported to garrison object.
private _timeReportCounter = 0;
private _reportArrayID = 0;
private _allTargetsReportObjects = [[], []];
private _allTargetsReportpos = [[], []];

while {true} do
{
	sleep _timeSleep;	
	private _i = 0;
	private _setNewAS = false;
	private _newAS = 0;
	private _allTargets = []; //Array of objects
	private _allTargetsKnowsAbout = [];
	private _combat = false; //Is any squad in combat mode?
	private _nt = []; //NearTargets
	while {_i < (count _groupsData)} do
	{
		private _x = _groupsData select _i; //The current element of groupsData
		_hG = _x select 0; //Group handle
		
		//Check if the group has been totally destroyed
		private _alive = true;
		if(! isNull _hg) then
		{
			if({alive _x} count (units _hG) == 0) then //If everyone is dead, delete this group from _groupsData array.
			{
				_groupsData deleteAt _i;
				_alive = false;
			};
		}
		else
		{
			_groupsData deleteAt _i;
			_alive = false;
		};
		
		//If the group is still alive
		if (_alive) then
		{
			private _bP = _x select 1; //Behaviour previous
			private _bC = behaviour (leader _hG); //Behaviour current
			if(_bP isEqualTO "COMBAT") then
			{
				//diag_log format ["fn_locationThread.sqf: location: %1, combat group couter: %2", _name, _x select 2];
				if(_bC isEqualTO "COMBAT") then //If it was combat and it's still combat
				{
					private _t = _x select 2; //Counter, how long the group has been in combat mode
					_t = _t + _timeSleep;
					_combat = true;
					if(_t > _timeReveal) then //If group has been in combat mode for more than _timeReveal seconds
					{
						//Find targets of this group
						//_nt = (leader _hG) nearTargets 2000;
						_nt = (leader _hG) targetsQuery [objNull, sideUnknown, "", [], 1.5];
						//Add the targets of this group to global targets array
						{
							private _s = _x select 2;
							if(_s != _side && (_s in [EAST, WEST, INDEPENDENT])) then //If target's side is enemy
							{
								//object, knowsabout, pos
								//_allTargets pushBack [_x select 4, _hG knowsAbout (_x select 4), _x select 0];
								_allTargets pushBack [_x select 1, _hG knowsAbout (_x select 1), _x select 4, _x select 5];
							};
						}forEach _nt;
						//Switch the location to combat mode
						_t = 0;
						//_newAS = G_AS_combat;
						//_setNewAS = true;
					};
					_x set [2, _t];
				}
				else //If group's behaviour was combat and not combat any more
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
	
	//Reveal targets to everyone in this garrison
	if(_combat) then
	{
		if ((count _allTargets) > 0) then
		{
			//Reveal enemies to other squads
			
			diag_log format ["fn_manageSpottedEnemies.sqf: revealing targets: %1", _allTargets];
			_i = 0;
			private _count = count _groupsData;
			while {_i < _count} do
			{
				private _hG = _groupsData select _i select 0;
				{
					//_hG reveal [_x select 0, _x select 1];
					_hG reveal [_x select 0, 1.0];
					//_hG reveal (_x select 0);
				}forEach _allTargets;
				_i = _i + 1;
			};
			
			//Report enemies to garrison object
			_timeReportCounter = _timeReportCounter + _timeSleep;
			diag_log format ["fn_manageSpottedEnemies.sqf: timeReportCounter: %1", _timeReportCounter];
			//Check if report time has been reached
			if(_timeReportCounter >= _timeReport) then
			{
				//Report spotted enemies to garrison object
				_allTargetsReportObjects set [_reportArrayID, []];
				_allTargetsReportPos set [_reportArrayID, []];				
				private _reportArrayObjects = _allTargetsReportObjects select _reportArrayID;
				private _reportArrayPos = _allTargetsReportPos select _reportArrayID;
				_reportArrayID = (_reportArrayID + 1) mod 2; //Switch between 0, 1, 0, 1, ...
				{
					private _o = _x select 0;
					private _p = _x select 2;
					//diag_log format ["obj: %1 pos: %2", _o, _p];
					if (!(_o in _reportArrayObjects)) then
					{
						_reportArrayObjects pushBack _o;
						_reportArrayPos pushBack _p;
					};
				} forEach _allTargets;
				//diag_log format ["=== %1 %2", _reportArrayObjects, _reportArrayPos];
				[_gar, _reportArrayObjects, _reportArrayPos, true] call gar_fnc_reportSpottedEnemies;
				_timeReportCounter = _timeReportCounter - _timeReport;
			};
		};
	}
	else
	{
		_timeReportCounter = 0; //_timeRevealCounter + _timeSleep;
		//Report no enemies to garrison object
		[_gar, [], []] call gar_fnc_reportSpottedEnemies;
	};
	
	//If needed, send requests to change alert state to the location
	if (_handleAlertState) then
	{
		//Send data to location object
		/*
		if (count _allTargets > 0) then
		{
		};
		*/
	};
};
