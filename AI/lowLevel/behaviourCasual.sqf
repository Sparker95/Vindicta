/*
Makes units of _groups randomply 'talk' to each other, walk around or sit by campfires.
[[group cursorObject], getPos player, 20] spawn (compile preprocessfilelinenumbers "AI\mediumLevel\behaviourCasual.sqf");

_params:
	_groups
	_location
	_maxRadius
*/

params ["_scriptObject", "_groups", "_loc", "_maxRadius", ["_isAnybodyWatching", true]];

private _radius = [_loc] call loc_fnc_getBoundingRadius;
//Find campfires
private _pos = getPos _loc;
private _campfires = (_pos nearObjects ["Campfire_burning_F", 2*_radius]) + (_pos nearObjects ["FirePlace_burning_F", 2*_radius]) + (_pos nearObjects ["Land_Campfire_F", 2*_radius]) + (_pos nearObjects ["Land_FirePlace_F", 2*_radius]);
diag_log format ["Number of campfires: %1", count _campfires];
if(_maxRadius < _radius) then //Check radius
{
	_radius = _maxRadius;
};

{
	_x setBehaviour "SAFE";
	_x setSpeedMode "LIMITED";
	{
		_x setVariable ["casualFree", nil];
	} forEach (units _x);
	(units _x) orderGetIn false; //Order all units to dismount their vehicles
}foreach _groups;

private _chat =
{
	params ["_men"];
	private _c = (count _men) - 1;
	private _m0 = _men select 0;
	private _tstart = time;
	waitUntil
	{
		//(_rvPos distance _man1 < 2) && (_rvPos distance _man2 < 2)
		//|| ((_man1 distance _man2) < 2)
		sleep 0.1;
		((_men select 0) distance (_men select 1) < 2.8)
		|| (time - _tstart > 500)
		|| (!(alive (_men select 0)))
		|| (!(alive (_men select 1)))
	};
	//diag_log "Hello!";
	//player setpos (getpos (_men select 0)); //For debug purposes
	if((alive (_men select 0)) && (alive (_men select 1))) then
	{
		(_men select 0) lookAt (_men select 1);
		(_men select 1) lookAt (_men select 0);
		doStop _men;
		sleep 1;
		//if(random 1 < 0.666) then
		//{
			_m0 playmove "AmovPercMstpSrasWrflDnon_SaluteIn";
			_m0 playmove "AmovPercMstpSrasWrflDnon_SaluteOut";
		//};
		//_man2 playmove "Acts_CivilTalking_2";
		//_man1 action ["salute", _man1];
		//Let them talk for some time
		(_men select 0) lookAt (_men select 1);
		(_men select 1) lookAt (_men select 0);
		doStop _men;
		sleep 120 + (random 120);
		{
			_x setVariable ["casualFree", true];
		} forEach _men;
		(_men select 0) lookAt objNull; //To make them stop rotating around seeking for the previous target they were looking at
		(_men select 1) lookAt objNull;
	};
	//Reset the script handle variables
	(_men select 0) setVariable ["AI_hScript", nil];
	(_men select 1) setVariable ["AI_hScript", nil];
};

private _chat_campfire =
{
	params ["_man", "_campfire", "_pos"];
	private _tstart = time;
	waitUntil
	{
		//(_rvPos distance _man1 < 2) && (_rvPos distance _man2 < 2)
		//|| ((_man1 distance _man2) < 2)
		sleep 0.2;
		((_man distance _campfire) < 5)
		|| (time - _tstart > 200)
		|| (!alive _man)
	};
	if(alive _man) then
	{
		if(!(time - _tstart > 200)) then
		{
			_man setPos _pos;
			//diag_log "Campfire!";
			doStop [_man];
			sleep 1;
			_man lookAt _campfire;
			sleep 1;
			if(! (inflamed _campfire)) then
			{
				_man action ["FireInflame", _campfire];
			};
			sleep 1;
			if(random 1 < 0.666) then {_man action ["sitDown", _man];};
			sleep 60 + (random 120); //Let him stay at the campfire for some time
		};
		_man setVariable ["casualFree", true];
		_man lookAt objNull;		
	};
	_man setVariable ["AI_hScript", nil];
};

private _counter = 0;
while {true} do
{
	private _units = [];
	{
		_units append (units _x);
	}foreach _groups;
	private _freeUnits = _units select {_x getVariable ["casualFree", true]}; //Find those that are not occupied
	private _freeUnitsNr = count _freeUnits;

	//diag_log format ["_freeUnitsNr: %1, _freeUnits: %2", _freeUnitsNr, _freeUnits];
	if(random 1 < 0.5) then
	{
		//Find a few random AIs to chat with each other
		private _i = selectrandom [1, 2];
		while {_i > 0} do
		{
			if(_freeUnitsNr >= 2) then
			{
				private _man1 = selectRandom _freeUnits;
				private _man2 = _man1;
				while {_man2 isEqualTO _man1} do { _man2 = selectRandom _freeUnits; };
				_man1 setVariable ["casualFree", false];
				_man2 setVariable ["casualFree", false];
				_man1 lookAt _man2;
				_man2 lookAt _man1;
				//Select a random position for these two guys
				private _posX = (_pos select 0) - _radius +  (random (2*_radius));
				private _posY = (_pos select 1) - _radius +  (random (2*_radius));
				while {surfaceIsWater [_posX, _posY] || !([_loc, [_posX, _posY, 0]] call loc_fnc_insideBorder)} do
				{
					_posX = (_pos select 0) - _radius +  (random (2*_radius));
					_posY = (_pos select 1) - _radius +  (random (2*_radius));
				};
				_man1 doMove [_posX, _posY, 0];
				//private _alpha = random 360;
				//_man2 doMove ([_posX, _posY, 0] vectorAdd [1.5*(sin _alpha), 1.5*(cos _alpha), 0]);
				_man2 doMove [_posX, _posY, 0];
				_freeUnitsNr = _freeUnitsNr - 2;
				_freeUnits = _freeUnits - [_man1, _man2];
				private _scriptHandle = [[_man1, _man2]] spawn _chat;
				//Set the script handles for units. They will be used later to terminate the spawned scripts.
				[_scriptObject, _scriptHandle] call AI_fnc_registerScriptHandle;
			};
			_i = _i - 1;
		};
	}
	else
	{
		if(_counter >= 3) then
		{
			_counter = 0;
			//Find a campfire
			//diag_log format ["Number of campfires: %1", count _campfires];
			{
				if(_freeUnitsNr > 0) then
				{
					private _menAtCampfireNr = 0;
					private _alpha = random 360;
					private _menAtCampfireMax = 3;
					while {_menAtCampfireNr < _menAtCampfireMax && _freeUnitsNr > 0} do
					{
						private _campfireMan = selectRandom _freeUnits;
						_campfireman setVariable ["casualFree", false];
						private _campfireSitPos = _x getPos [2.0+(random 1), random 360];//_alpha + (360/_menAtCampfireMax) * _menAtCampfireNr];
						private _scriptHandle = [_campfireMan, _x, _campfireSitPos] spawn _chat_campfire;
						//_campfireMan setVariable ["AI_hScript", _scriptHandle]; //Set the script handle for unit. It will be used later to terminate the spawned scripts.
						[_scriptObject, _scriptHandle] call AI_fnc_registerScriptHandle;
						_campfireMan doMove _campfireSitPos;
						_menAtCampfireNr = _menAtCampfireNr + 1;
						_freeUnitsNr = _freeUnitsNr - 1;
						_freeUnits = _freeUnits - [_campfireMan];
					};
				};
			}forEach _campfires;
		};
	};

	//Make the other guys walk around
	if(count _freeUnits > 0) then
	{
		private _man = selectRandom _freeUnits;
		_man doMove ((getPos _man) vectorAdd [-6 + random 12, -6 + random 12, 0]);
	};

	/*
	{
		private _man = _x;
		if(random 1 < 0.8) then
		{
			//if(_campfires count {(_man distance _x) < 6} == 0) then //If he's away from campfires. We odn't want to burn him.
			//{
				_x doMove ((getPos _x) vectorAdd [-6 + random 12, -6 + random 12, 0]);
			//};
		};
	} forEach _freeUnits;
	*/
	sleep 15 + (random 15);
	_counter = _counter + 1;
};