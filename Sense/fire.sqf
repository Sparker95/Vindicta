#include "Sense.hpp"

/*
Useful cfgAmmo classes:
BulletBase - bullets
ShellBase - tank, ifv cannons, also mortars
GrenadeBase - 40mm grenades
*/

/*
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
		if(_count >= 2) then
		{
			[getPos _unit, _weaponType, _shotsPerSecond, _dMin2] spawn
			{
				params ["_pos", "_wt", "_sps", "_d"]; //pos, weapon type, shots per second, distance
				sleep (_d/340) + 5;
				[_pos, _wt, _sps, _d] remoteExec ["sense_fnc_reportSound", 2];
			};
		};
	};
};

sense_fnc_reportSound =
{
	/*
	A server side function to handle fire sounds coming from a unit.
	This function sends gunfire data to HQ.
	*/
	params ["_pos", "_wt", "_sps", "_d"]; //pos, weapon type, shots per second, distance
	
};

sense_fnc_unitFireMonitor =
{
	/*
	This script monitors how many shots the unit has made during current iteration.
	If unit has made audible gun shots, data is being sent to nearby locations.
	*/
	params ["_unit", "_st", "_ut"]; //unit, sleep time, unit type
	scopeName "main";
	private _silenced = false;
	while {!isNull _unit} do
	{
		if(!alive _unit) then //If the unit is dead, terminate the script
		{breakTo "main"};
		
		sleep _st;
		
		//Read how many shots have been fired by the unit Normalize them by the sleep time to get fires per second.
		//Reset the counters
		private _cl = (_unit getVariable ["s_firedLight", 0])/_st; //Counter for light weapons
		_unit setVariable ["s_firedLight", 0];
		private _cm = (_unit getVariable ["s_firedMedium", 0])/_st; //Medium
		_unit setVariable ["s_firedMedium", 0];
		private _ch = (_unit getVariable ["s_firedHeavy", 0])/_st; //Heavy
		_unit setVariable ["s_firedHeavy", 0];
		private _ca = (_unit getVariable ["s_firedArtillery", 0])/_st; //Artillery
		_unit setVariable ["s_firedArtillery", 0];
		
		if(_cl > 0 || _cm > 0 || _ch > 0 || _ca > 0) then
		{
			//Calculate minimum hearing distances for weapon types
			_dl = 1000;
			_dm = 2000;
			_dh = 8000;
			_da = 6000;
			
			//todo check only locations of enemy side			
			if(_cl > 0) then
			{
				if(!_silenced) then //Check if the weapon is silenced
				{
					[_unit, _dl, 0, _cl] call sense_fnc_sendSoundToLocations;
					//diag_log format ["Light: %1", _cl];
				};
			};
			if(_cm > 0) then
			{
				[_unit, _dm, 1, _cm] call sense_fnc_sendSoundToLocations;
				//diag_log format ["Medium: %1", _cm]; 
			};
			if(_ch > 0) then
			{
				[_unit, _dh, 2, _ch] call sense_fnc_sendSoundToLocations;
				//diag_log format ["Heavy: %1", _ch];
			};
			if(_ca > 0) then
			{
				[_unit, _da, 3, _ca] call sense_fnc_sendSoundToLocations;
				//diag_log format ["Artillery: %1", _ca];
			};
		};
		
		//If unit is infantry, check if it's using silenced weapon
		if(_ut == 0) then
		{
			_silenced = _unit call misc_fnc_currentWeaponSilenced;
		};
	};
};

sense_fnc_initUnitFireMonitor =
{
	/*
	Call this on a unit(infantry or vehicle) if you want to monitor gunshots produced by it.
	*/
	params ["_unit"];
	_unit setVariable ["s_firedLight", 0, false]; //Counter for light weapons, like rifles ad handguns
	_unit setVariable ["s_firedMedium", 0, false]; //12mm and above
	_unit setVariable ["s_firedHeavy", 0, false]; //Above 40mm or so
	_unit setVariable ["s_firedArtillery", 0, false]; //Artillery
	private _sleepInterval = 3;
	private _eh = _unit getVariable ["s_firedEh", -1];
	private _unitType = 0; //0 - inf, 1 - veh, 2 - mortar
	if(_eh == -1) then
	{
		if(_unit isKindOf "man") then
		{
			_eh = _unit addEventHandler ["Fired", {_this spawn sense_fnc_infFired_eh}];
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
		};
		_unit setVariable ["s_firedEh", _eh];
		private _hScript = [_unit, _sleepInterval, _unitType] spawn sense_fnc_unitFireMonitor;
		_unit setVariable ["s_hFireMonitor", _hScript, false];
	}
	else
	{
		diag_log format ["sense_fnc_initUnitFireMonitor: error: attempt to launch second unitFireMonitor script: %1", _unit];
	};
};