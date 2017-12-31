#include "Sense.hpp"

/*
This is the sound monitor module. It processes sounds produced by units firing their weapons.
The main purpose of this is to warn the HQ and all locations that are not spawn of enemy presense when enemy fires a weapon.
*/

/*
Useful cfgAmmo classes:
BulletBase - bullets
ShellBase - tank, ifv cannons, also mortars
GrenadeBase - 40mm grenades
*/

/*
fired event handler data:
unit: Object - Object the event handler is assigned to 
weapon: String - Fired weapon 
muzzle: String - Muzzle that was used 
mode: String - Current mode of the fired weapon
ammo: String - Ammo used 
magazine: String - magazine name which was used
(Since Arma 2 OA)
projectile: Object - Object of the projectile that was shot out
(Since Arma 3 v 1.65)
gunner: Object - gunner whose weapons are firing.
*/

/*
hit data for different ammo:
handguns: ~5
rifles: ~10
12.7mm: 30..50
40mm: 70-150 (Marshall)
82mm: 165 (mortar)
120mm: 250-500 (merkava)
155mm: 165..340 (mortar)
230mm: 300 (MLRS Sandstorm)

Radius is calculated based on hit value for ammo.
handguns and rifles: ~1km
light mortar: ~5km
heavy mortars and tanks: ~10km
*/

sense_fnc_createSoundMonitor =
{
	/*
	Creates sound monitor object. Typically it is created per every side/faction.
	
	Parameters:
		none
		
	Return value:
		object - the soundMonitor object. Manipulate it with other functions.
	*/
	
	//Create a logic object
	private _o = groupLogic createUnit ["LOGIC", [55, 55, 55], [], 0, "NONE"];
	_o setVariable ["s_units", [], false]; //Units this sound monitor will be checking
	//_o setVariable ["s_hearingObjects", [], false]; //Objects that can hear the units. Now these are locations, but this might change
	_o setVariable ["s_hearingObjects", allLocations, false]; //todo add a func. to set the hearing objects
	_o setVariable ["s_time", time, false]; //Time is stored to measure time between each call to the  'process...' function
	_o
};

sense_fnc_addUnitToSoundMonitor =
{
	/*
	Adds unit to the soundMonitor object.
	Call this on a unit(infantry or vehicle) at the server if you want to monitor gunshots produced by it.
	
	Parameters:
		_unit - the unit object
		_soundMonitor - the sound monitor object that will handle this unit.
	
	Return value:
		nothing
	*/
	params ["_unit", "_soundMonitor"];
	_unit setVariable ["s_firedLight", 0, false]; //Counter for light weapons, like rifles ad handguns
	_unit setVariable ["s_firedMedium", 0, false]; //12mm and above
	_unit setVariable ["s_firedHeavy", 0, false]; //Above 40mm or so
	_unit setVariable ["s_firedArtillery", 0, false]; //Artillery
	private _eh = _unit getVariable ["s_firedEh", -1];
	private _unitType = 0; //0 - inf, 1 - veh, 2 - mortar
	private _silenced = false;
	if(_eh == -1) then
	{
		if(_unit isKindOf "Man") then
		{
			_eh = _unit addEventHandler ["Fired", {_this spawn sense_fnc_infFired_eh}];
			_silenced = _unit call misc_fnc_currentWeaponSilenced;
			_unitType = 0;
		}
		else
		{
			//Check if the unit is a mortar
			if((_unit isKindOf "StaticMortar") || ((typeof _unit) in mortarClassnames)) then
			{
				_eh = _unit addEventHandler ["Fired", {_this spawn sense_fnc_mortarFired_eh}];
				_unitType = 2;
			}
			else
			{
				_eh = _unit addEventHandler ["Fired", {_this spawn sense_fnc_vehFired_eh}];
				_unitType = 1;
			};
			
			//Check if it's a plane or helicopter to monitor its emitted sound when its engine is on
			if (_unit isKindOf "Air") then
			{
				if(_unit isKindOf "Helicopter" && !(_unit isKindOf "UAV_01_base_F")) then
				{
					//
				};
				if(_unit isKindOf "Plane" && !(_unit isKindOf "UAV")) then
				{
					//
				};
			};
		};
		_unit setVariable ["s_firedEh", _eh];
		_unit setVariable ["s_silenced", _silenced, false]; //Is the unit using a silenced weapon? This variable will be updated every time the sound monitor function is called.
		//Add unit to the units array of the soundMonitor object
		private _units = _soundMonitor getVariable ["s_units", []];
		_units pushBack _unit;
		
	}
	else
	{
		diag_log format ["sense_fnc_initUnitSoundMonitor: error: attempt to launch second unitSoundMonitor script: %1", _unit];
	};
};

sense_fnc_removeUnitFromSoundMonitor =
{
	/*
	Removes unit from the sound monitor object.
	
	Parameters:
		_unit - 
		_soundMonitor - 
	
	Return value:
		success - bool, if the operation was completed successfully
	*/
	params ["_unit", "_soundMonitor"];
	private _units = _soundMonitor getVariable ["s_units", []];
	private _id = _units find _unit;
	if (_id != -1) exitWith
	{
		_units deleteAt _id;
		private _eh = _unit getVariable ["s_firedEh", -1];
		if(_eh != -1) then
		{
			_unit removeEventHandler ["Fired", _eh];
			_unit setVariable ["s_firedEH", nil, false];
		};
		true
	};
	false
};

sense_fnc_soundMonitorThreadClient =
{
	/*
		A thread spawned by each client(player) to monitor player's firing
	*/
};

sense_fnc_processSoundMonitor =
{
	/*
	This function processes the amount of shots fired and sound produced by all units attached to the sound monitor object. Call it in a loop with fixed intervals.
	
	Parameters:
		_soundMonitor - the sound monitor object
		_processData - do you want the function also to process data about gunshots?
			If true, then the function will return array with all the gunshots in following format(see return value):
			
	Return vaue:
		If _processData==true:
			_sounds - array of:
				[_x, _y, _size, _soundType]
					_x, _y - coordinates of the source
					_size - the size of the area
					_soundType - the type of sound source. See Sense.hpp
		If _processData==false:
			[] - empty array
	*/
	params ["_soundMonitor", "_processData"];
	//Update the time variable
	private _dt = time - (_soundMonitor getVariable ["s_time", 0]); //Time passed between prev. call to this function
	_soundMonitor setVariable ["s_time", time, false];
	private _locatedSounds = []; //The return value
	
	//The constant used to calculate dispersion of located soun
	private _dCoef = (150/1000);
	
	//Check all the units
	private _units = _soundMonitor getVariable ["s_units", []];
	private _i = 0;
	private _hearingObjects = _soundMonitor getVariable ["s_hearingObjects", []];
	while {_i < count _units} do
	{
		private _unit = _units select _i;
		private _active = true;
		//If the unit is dead or has been despawned, delete it from this sound monitor object
		if(isNull _unit || !alive _unit) then
		{
			[_unit, _soundMonitor] call sense_fnc_removeUnitFromSoundMonitor;
			_active = false;
		};
		
		//If the unit hasn't been removed from the array
		if(_active) then
		{
			private _silenced = _unit getVariable ["s_silenced", false];
			//Read how many shots have been fired by the unit. Normalize them by the sleep time to get fires per second.
			//Reset the counters
			private _cl = (_unit getVariable ["s_firedLight", 0])/_dt; //Counter for light weapons
			_unit setVariable ["s_firedLight", 0];
			private _cm = (_unit getVariable ["s_firedMedium", 0])/_dt; //Medium
			_unit setVariable ["s_firedMedium", 0];
			private _ch = (_unit getVariable ["s_firedHeavy", 0])/_dt; //Heavy
			_unit setVariable ["s_firedHeavy", 0];
			private _ca = (_unit getVariable ["s_firedArtillery", 0])/_dt; //Artillery
			_unit setVariable ["s_firedArtillery", 0];
			
			//If the unit has produced any sound
			if(_cl > 0 || _cm > 0 || _ch > 0 || _ca > 0) then
			{			
				private	_countST = [_cl, _cm, _ch, _ca]; //Count of sound types: light, med., heavy, art.
				diag_log format ["sense_fnc_processSoundMonitor: sounds produced by unit %1: %2", _unit, _countST];
				private _distST = [1000, 2000, 8000, 6000]; //Hearing distance for sound types
				{
					private _soundType = _foreachindex;
					private _dMax = _distST select _soundType;
					private _count = _x; //Count of sounds of this type produced by the unit
					if (_count > 0) then
					{
						private _dMin = 666666;
						private _dMin2 = 666666;
						//Find objects that can hear sounds from this unit
						{
							private _d = _x distance2D _unit;
							if(_d < _dMin) then
							{
								_dMin2 = _dMin;
								_dMin = _d;
							};
							_t = _d / 340; //Sound travel time
							//Notify the object of produced sound
							if(_d < _dMax) then
							{
								[_x, _t, _soundType] spawn
								{
									params ["_loc", "_t", "_st"];
									sleep _t;
									[_loc, _st] call loc_fnc_handleSound;
								};
							};
						} forEach _hearingObjects;
						
						/*
						If the sound has been heard by two objects, we assume that the position of sound source can be triangulated.
						If _processData==true, we need to create an array with spotted sounds.
						Todo check if the objects have communication with the HQ
						*/
						if(_dMin2 < _dMax && _processData) then
						{
							//diag_log format ["dmin2= %1", _dmin2];
							private _3sigma = _dCoef*_dMin;
							private _posUnit = getPosWorld _unit;
							private _ux = _posUnit select 0;
							private _uy = _posUnit select 1;
							private _mx = _ux + (random [-_3sigma, 0, _3sigma]); //Measured coordinates
							private _my = _uy + (random [-_3sigma, 0, _3sigma]);
							_locatedSounds pushBack [_mx, _my, _3sigma, _soundType];
						};
					};
				} forEach _countST;
			};
			
			//If unit is infantry, check if it's using silenced weapon
			if(_unit isKindOf "Man") then
			{
				_unit setVariable ["s_silenced", _unit call misc_fnc_currentWeaponSilenced, false];
			};
		};
		
		_i = _i + 1;
	};
	
	_locatedSounds
};

//TODO remove this function, it is not needed any more!
sense_fnc_sendSoundToLocations =
{
	/*
	This function sends data about gunfire sound sources from _unit to locations
	within _maxDistance range.
	Also the function simulates data being passed to HQ.
	*/
	params ["_unit", "_maxDistance", "_weaponType", "_shotsPerSecond"];
	private _locs = allLocations select {(_x distance _unit) < _maxDistance};
	private _count = count _locs;
	private _dMin = 66666;
	private _dMin2 = 66666;
	if(_count > 0) then
	{
		{
			_d = _x distance2D _unit;
			if(_d < _dMin) then
			{
				_dMin2 = _dMin;
				_dMin = _d;
			};
			_t = (_d) / 340; //Sound travel time
			[_x, _t, _weaponType] spawn
			{
				params ["_loc", "_t", "_wt"];
				sleep _t;
				[_loc, _wt] remoteExec ["loc_fnc_handleGunfireSounds", 2];
			};
		} forEach _locs;
		
		//todo add more checks for location antennas, connectivity, etc
		/*
		For now we assume that if sound source has been heard from >2 locations,
		it can be triangulated.
		Propagation is calculated by the distance to the second location that hears
		the sound, plus some extra delay.
		*/
		if(_count >= 2 || _dMin < 300) then
		{
			[getPos _unit, _weaponType, _shotsPerSecond, _dMin2] spawn
			{
				params ["_pos", "_wt", "_sps", "_d"]; //pos, weapon type, shots per second, distance
				sleep (_d/340) + 5;
				//[_pos, _wt, _sps, _d] remoteExec ["sense_fnc_reportSound", 2];
			};
		};
	};
};

sense_fnc_mortarFired_eh =
{
	/*
	Fired event handler for mortars.
	If a mortar shell/rocket is fired, its trajectory is being monitored. If it falls near
	a location, the location is spawned.
	*/
	params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
	
	diag_log format [" allvariables: %1", allVariables _projectile];
	
	if((_ammo isKindOf "GrenadeBase") || (_ammo isKindOf "BulletBase")) then //If it's some kind of machinegun attached to the artillery
	{
		private _hit = getNumber (configFile >> "cfgAmmo" >> _ammo >> "hit");
		if(_hit > 0) then
		{
			if(_hit > S_HIT_HEAVY) then
			{
				private _c = _unit getVariable "s_firedHeavy";
				_c = _c + 1;
				_unit setVariable ["s_firedHeavy", _c];
			}
			else
			{
				if(_hit > S_HIT_MEDIUM) then
				{
					private _c = _unit getVariable "s_firedMedium";
					_c = _c + 1;
					_unit setVariable ["s_firedMedium", _c];
				}
				else //Light
				{
					private _c = _unit getVariable "s_firedLight";
					_c = _c + 1;
					_unit setVariable ["s_firedLight", _c];
				}
			};
		};
	}
	else //Otherwise it's either a rocket(MLRS) or a shell
	{
		private _posLaunch = getPosWorld _unit;
		//diag_log format ["==== Mortar fire detected!"];
		private _c = _unit getVariable "s_firedArtillery";
		_c = _c + 1;
		_unit setVariable ["s_firedArtillery", _c];
		
		_pos = getPos _projectile;
		//Wait until projectile ascends
		waitUntil {
			_vz = (velocity _projectile) select 2;
			if (isNull _projectile || _vz < 0) then { true }
			else {sleep 0.7; false};
		};
		//diag_log format ["Ascention done!"];
		
		//Wait until projectile is about 5s before impact
		_t = 0;
		waitUntil {
			if(!isNull _projectile) then
			{
				_vz = (velocity _projectile) select 2;
				_h = (getPosATL _projectile) select 2;
				_t = -(_h/_vz);
				if(_t < 8) then {true}
				else {sleep 0.2; false};
			};
		};
		
		//Estimate the impact location
		_v = velocity _projectile;
		_vx = _v select 0;
		_vy = _v select 1;
		_pos = (getPos _projectile) vectorAdd [_vx*_t, _vy*_t, 0];
		//diag_log format ["final eta: %1", _t];
		//diag_log format ["estimated impact pos: %1", _pos];
		
		//Check estimated impact pos. and spawn the location in advance
		private _loc = objNull;
		{
			if ((_x distance2D _pos) < (([_x] call loc_fnc_getBoundingRadius) max 300)) exitWith {_loc = _x;};
		} forEach allLocations;
		if(!isNull _loc) then
		{
			diag_log format ["Mortar shell incoming to location!"];
			[_loc, _posLaunch, false] remoteExec["loc_fnc_handleArtilleryFire", 2];
		};
		
		//Wait until the explosion
		_pos = getPos _projectile;
		waitUntil {
			if (isNull _projectile) then { true }
			else {
				_pos = getPos _projectile; sleep 0.2; false
			};
		};
		
		_loc = objNull;
		{
			if ([_x, _pos] call loc_fnc_insideBorder) exitWith {_loc = _x;};
		} forEach allLocations;
		if(!isNull _loc) then
		{
			[_loc, _posLaunch, true] remoteExec["loc_fnc_handleArtilleryFire", 2];
		};
	};
};

sense_fnc_infFired_eh =
{
	//Fired event handler for infantry
	params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
	/*
	diag_log "Fired!";
	diag_log format ["   unit: %1, weapon: %2, muzzle: %3, mode: %4, ammo: %5, magazine: %6", _unit, _weapon, _muzzle, _mode, _ammo, _magazine];
	diag_log format ["   type projectile: %1, velocity: %2", typeof _projectile, vectorMagnitude (velocity _projectile)];
	*/
	_hit = getNumber (configFile >> "cfgAmmo" >> _ammo >> "hit");
	/*
	private _radius = 0;	
	diag_log format ["   ammo hit: %1, radius: %2", _hit, _radius];
	*/
	if(_hit > 0) then
	{
		if(_hit > S_HIT_HEAVY) then
		{
			private _c = _unit getVariable "s_firedHeavy";
			_c = _c + 1;
			_unit setVariable ["s_firedHeavy", _c];
		}
		else
		{
			if(_hit > S_HIT_MEDIUM) then
			{
				private _c = _unit getVariable "s_firedMedium";
				_c = _c + 1;
				_unit setVariable ["s_firedMedium", _c];
			}
			else //Light
			{
				private _c = _unit getVariable "s_firedLight";
				_c = _c + 1;
				_unit setVariable ["s_firedLight", _c];
			}
		};
	};		
};

sense_fnc_vehFired_eh =
{
	//Fired event handler for vehicles.
	params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];

	_hit = getNumber (configFile >> "cfgAmmo" >> _ammo >> "hit");

	if(_hit > 0) then
	{
		if(_hit > S_HIT_HEAVY) then
		{
			private _c = _unit getVariable "s_firedHeavy";
			_c = _c + 1;
			_unit setVariable ["s_firedHeavy", _c];
		}
		else
		{
			if(_hit > S_HIT_MEDIUM) then
			{
				private _c = _unit getVariable "s_firedMedium";
				_c = _c + 1;
				_unit setVariable ["s_firedMedium", _c];
			}
			else //Light
			{
				private _c = _unit getVariable "s_firedLight";
				_c = _c + 1;
				_unit setVariable ["s_firedLight", _c];
			}
		};
	};
};