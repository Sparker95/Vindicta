#include "defineCommon.inc"

params["_vehicle"];
pr _turretsArrayName = [typeof _vehicle, true] call BIS_fnc_allTurrets;
pr _turretCfgs = ([_vehicle] call BIS_fnc_getTurrets);
if(count _turretsArrayName != count _turretCfgs)then{	_turretsArrayName = [[-1]] + _turretsArrayName;};//add driver
pr _turrets = [];
pr _totalLoadout = [];

{
	pr _turretLoadout = [];
	_x params ["_cfgTurret"];
	pr _magazineArray = getArray (_cfgTurret >> "magazines");
	
	{
		_x params["_magClass"];
		pr _ammoCount = getNumber(configfile >> "CfgMagazines" >> _magClass >> "count");
		pr _inserted = false;
		{
			_x params ["_magClassList","_ammoCountList"];
			if(_magClassList isEqualTo _magClass) then
			{
				_x set [1, (_ammoCountList + _ammoCount)];
				_inserted = true;
			};
		} forEach _turretLoadout;

		if (!_inserted) then
		{
			_turretLoadout pushBack [_magClass, _ammoCount];
		};
	}forEach _magazineArray;
	if(count _turretLoadout != 0)then{
		_turrets pushBack (_turretsArrayName select _forEachIndex);
		_totalLoadout pushBack _turretLoadout;
	};
} forEach _turretCfgs;

_pylonLoadout = [];
{
	_pylonLoadout pushBack [_x, getNumber(configfile >> "CfgMagazines" >> _x >> "count")]
}forEach (getPylonMagazines _vehicle);

[_turrets,_totalLoadout,_pylonLoadout];