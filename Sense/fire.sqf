#include "Sense.hpp"

/*
Useful cfgAmmo classes:
BulletBase - bullets
ShellBase - tank, ifv cannons
GrenadeBase - 40mm grenades
*/

//A test for mortar fire event handler
sense_fnc_mortarFired_eh =
{
	params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
	_pos = getPos _projectile;
	waitUntil {
		if (isNull _projectile) then { true }
		else {_pos = getPos _projectile; sleep 0.5; false}
	};
	//player setPos _pos;
	private _loc = objNull;
	{
		if ([_x, _pos] call loc_fnc_insideBorder) exitWith {_loc = _x;};
	} forEach allLocations;
	if(!isNull _loc) then
	{
		//Spawn the location for some time
		[_loc, 120] remoteExec["loc_fnc_setForceSpawnTimer", 2]; //Execute it at the server 
	};
};

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

sense_fnc_infFired_eh =
{
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
	
};

sense_fnc_unitFireMonitor =
{
	params ["_unit", "_st"]; //unit, sleep time
	while {(!isNull _unit) && (alive _unit)} do
	{
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
		
		if(_cl > 0) then
		{
			diag_log format ["Light: %1", _cl];
		};
		if(_cm > 0) then
		{
			diag_log format ["Medium: %1", _cm]; 
		};
		if(_ch > 0) then
		{
			diag_log format ["Heavy: %1", _ch];
		};
		if(_ca > 0) then
		{
			diag_log format ["Artillery: %1", _ca];
		};
	};
};

sense_fnc_initUnitFireMonitor =
{
	params ["_unit"];
	_unit setVariable ["s_firedLight", 0, false]; //Counter for light weapons, like rifles ad handguns
	_unit setVariable ["s_firedMedium", 0, false]; //12mm and above
	_unit setVariable ["s_firedHeavy", 0, false]; //Above 40mm or so
	_unit setVariable ["s_firedArtillery", 0, false]; //Artillery
	private _sleepInterval = 3;
	private _eh = 0;
	if(_unit isKindOf "man") then
	{
		_eh = _unit addEventHandler ["Fired", {_this spawn sense_fnc_infFired_eh}];
	}
	else
	{
		//Check if the unit is a mortar
		if((_unit isKindOf "StaticMortar") || ((typeof _unit) in mortarClassnames)) then
		{
			_eh = _unit addEventHandler ["Fired", {_this spawn sense_fnc_mortarFired_eh}];
		}
		else
		{
			_eh = _unit addEventHandler ["Fired", {_this spawn sense_fnc_vehFired_eh}];
			//_eh = _unit addEventHandler ["Fired", {_this spawn sense_fnc_infFired_eh}];
		};
	};
	_unit setVariable ["s_firedEh", _eh];
	private _hScript = [_unit, _sleepInterval] spawn sense_fnc_unitFireMonitor;
	_unit setVariable ["s_hFireMonitor", _hScript, false];
};

sense_fnc_handleFireFromUnit =
{
	//A server side function to handle fire sounds coming from a unit
	params [""];
};

sense_fnc_

[player] call sense_fnc_initUnitFireMonitor;