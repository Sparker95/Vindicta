#include "Sense.hpp"

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
			[_loc, _posLaunch, true] call loc_fnc_handleArtilleryFire;
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
			if ((_x distance2D _pos) < (([_x] call loc_fnc_getBoundingRadius) max 300)) exitWith {_loc = _x;};
		} forEach allLocations;
		if(!isNull _loc) then
		{
			[_loc, _posLaunch, false] call loc_fnc_handleArtilleryFire;
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
	
	//diag_log format ["   ammo hit: %1, radius: %2", _hit];
	
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