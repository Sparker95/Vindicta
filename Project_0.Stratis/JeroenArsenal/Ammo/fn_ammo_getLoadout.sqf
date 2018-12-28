#include "defineCommon.inc"

params[["_vehicle",objNull,[objNull]]];
pr _turretsPaths = [typeof _vehicle, true] call BIS_fnc_allTurrets;
pr _turretsCfgs = ([_vehicle] call BIS_fnc_getTurrets);
if(count _turretsPaths != count _turretsCfgs)then{_turretsPaths = [[-1]] + _turretsPaths;};

pr _magDetail = magazinesAllTurrets _vehicle;

pr _seatName = _vehicle call JN_fnc_common_vehicle_getSeatNames;

pr _data = [];
pr _index = 0;
{
	
	pr _turretCfg = _x;
	pr _turretPath = (_turretsPaths select _forEachIndex);

	pr _turretWeapons = getArray (_turretCfg >> "weapons");
	private	_turretDisplayName = _seatName select 1 select ((_seatName select 0) find _turretPath);
	pr _turretMagazines = getArray (_turretCfg >> "magazines");
	
	pr _turretData = [];
	{
		pr _weapon = _x;
		pr _weaponDisplayName = gettext (configfile >> "CfgWeapons" >> _weapon >> "displayName");
		pr _weaponMagazines = getArray (configfile >> "CfgWeapons" >> _weapon >> "magazines");
		
		pr _dataWeapon = [];
		{
			pr _turretMagazine = _x;
			pr _turretMagazineDisplayName = getText (configfile >> "CfgMagazines" >> _turretMagazine >> "displayNameShort");
			if(_turretMagazineDisplayName == "")then{_turretMagazineDisplayName = "Ammo"};
			pr _turretMagazineSizeMax = getNumber(configfile >> "CfgMagazines" >> _turretMagazine >> "count");
			
			pr _inserted = false;
			{
				_x params["_turretMagazineL","_turretMagazineDisplayNameL","_turretMagazineSizeL","_turretMagazineSizeMaxL"];
				if(_turretMagazineL isEqualTo _turretMagazine)exitWith{
					_x set [3,_turretMagazineSizeMaxL+_turretMagazineSizeMax];
					_inserted = true;
				};
			}forEach _dataWeapon;
			
			pr _index = _weaponMagazines find _turretMagazine;
			if(!_inserted && {_index != -1})then{
				_dataWeapon pushBack [_turretMagazine,_turretMagazineDisplayName,0,_turretMagazineSizeMax,_turretMagazineSizeMax,-1];
			};
			
		}forEach _turretMagazines;
		
		_turretData pushBack [_weaponDisplayName, _dataWeapon];
	}forEach _turretWeapons;
	
	if(!isnil"_turretPath")then{
		_data pushBack [_turretPath, _turretDisplayName, _turretData];
	};
} forEach _turretsCfgs;

{
	_x params ["_magType","_magPath","_magAmount"];
	scopeName "data";
	{
		_x params ["_turretPath","_turretDisplayName","_turretData"];
		pr _turretIndex = _forEachIndex;
		if(_turretPath isEqualTo _magPath)exitWith{
			{
				_x params ["_weaponDisplayName", "_dataWeapon"];
				pr _weaponIndex = _forEachIndex;
				{
					_x params ["_turretMagazine","_turretMagazineDisplayName","_turretMagazineSize","_turretMagazineSizeMax"];
					pr _magazineIndex = _forEachIndex;
					if(_turretMagazine isEqualTo _magType)exitWith{
						_x set [2, _turretMagazineSize + _magAmount];
						//_turretData set [_magazineIndex,_x];
						//_data set [_turretIndex,_turretData];
						breakTo "data";
					};
				}forEach _dataWeapon;
			}forEach _turretData;
		};
	}forEach _data;
}forEach _magDetail;

pr _turretDataDriver = _data select 0 select 2;
{
	_x params ["_magazine"];
	pr _pylonId = (_forEachIndex + 1);
	pr _magazineDisplayName =  getText(configfile >> "CfgMagazines" >> _magazine >> "displayNameShort");
	pr _weapon = getText(configfile >> "CfgMagazines" >> _magazine >> "pylonWeapon");
	pr _weaponDisplayName = getText(configfile >> "CfgWeapons" >> _weapon >> "displayName");
	pr _currentAmount = _vehicle ammoOnPylon _pylonId;
	pr _maxAmount = getNumber(configfile >> "CfgMagazines" >> _x >> "count");

	_turretDataDriver pushBack [format["Pylon %1 (%2)",_pylonId,_weaponDisplayName], [[_magazine,_magazineDisplayName,_currentAmount,_maxAmount,_maxAmount,_pylonId]]];

}forEach (getPylonMagazines _vehicle);

_data;
