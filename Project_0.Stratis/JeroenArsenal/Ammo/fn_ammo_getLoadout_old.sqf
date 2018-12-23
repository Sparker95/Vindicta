#include "defineCommon.inc"


params["_vehicle"];
_vehicle = cursorObject;
pr _turretsArrayName = [typeof _vehicle, true] call BIS_fnc_allTurrets;
pr _turretCfgs = ([_vehicle] call BIS_fnc_getTurrets);
if(count _turretsArrayName != count _turretCfgs)then{	_turretsArrayName = [[-1]] + _turretsArrayName;};

pr _magDetail = magazinesAllTurrets _vehicle;

pr _turrets = [];
pr _totalLoadout = [];

{
	_x params ["_cfgTurret"];
	
	pr _turretLoadout = [];
	pr _magazineArray = getArray (_cfgTurret >> "magazines");
	pr _weapons = getArray (_cfgTurret >> "weapons");
	{
		_x params["_magClass"];
		
		pr _ammoCount = getNumber(configfile >> "CfgMagazines" >> _magClass >> "count");
		pr _inserted = false;
		{
			_x params ["_magClassList","_displayName","_ammoCountCur","_ammoCountMax"];
			if(_magClassList isEqualTo _magClass) exitWith
			{
				_x set [3, (_ammoCountMax + _ammoCount)];
				_inserted = true;
			};
		} forEach _turretLoadout;

		if (!_inserted) then
		{
			pr _displayName = DISPLAYNAME_MAG(_magClass);
			if(_displayName == "")then{
				{
					_x params["_weapon"];
					pr _magazinesArray = getArray(configfile >> "CfgWeapons" >> _weapon >> "magazines");
					if(_magazinesArray find _magClass != -1)exitWith{
						_displayName = getText(configFile >> "CfgWeapons" >> _weapon >> "displayName");
					};
				}forEach _weapons;
			};
			_turretLoadout pushBack [_magClass, _displayName, 0, _ammoCount];
		};
	}forEach _magazineArray;
	if(count _turretLoadout != 0)then{
		_turrets pushBack (_turretsArrayName select _forEachIndex);
		_totalLoadout pushBack _turretLoadout;
	};
} forEach _turretCfgs;

{
	_x params ["_magClass","_turretPath","_ammoCount"];
	pr _turretLoadout = _totalLoadout select (_turrets find _turretPath);
	{
		_x params ["_magClassList","_displayName","_ammoCountCur","_ammoCountMax"];
		if(_magClassList isEqualTo _magClass)exitWith{
			_x set [2, (_ammoCountCur + _ammoCount)];
		};
	}forEach (_turretLoadout);
}forEach _magDetail;

pr _pylonLoadout = [];
{
	_x params ["_magClass"];
	_pylonLoadout pushBack [_magClass,DISPLAYNAME_MAG(_magClass), _vehicle ammoOnPylon (_forEachIndex + 1), getNumber(configfile >> "CfgMagazines" >> _x >> "count")]
}forEach (getPylonMagazines _vehicle);


pr _displayNames = [];
pr _allTurretsNames = _vehicle call JN_fnc_common_vehicle_getSeatNames;
{
	pr _turretPath = _x;
	pr _turretPaths = _allTurretsNames select 0;
	pr _names = _allTurretsNames select 1;
	_displayNames pushBack (_names select (_turretPaths find  _turretPath));
}forEach _turrets;

[_turrets,_displayNames,_totalLoadout,_pylonLoadout];