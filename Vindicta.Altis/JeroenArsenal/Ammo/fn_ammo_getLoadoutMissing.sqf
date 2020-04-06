#include "defineCommon.inc"

params["_vehicle"];

pr _loadoutCfg = _vehicle call JN_fnc_ammo_getLoadoutCfg;
pr _loadoutCurrent = _vehicle call JN_fnc_ammo_getLoadoutCurrent;
pr _loadoutMissing = [];
pr _turrets = [];
{
	pr _turret = _x;
	pr _loadoutCurrentIndex = _forEachIndex;
	{

		if(_turret isEqualTo _x)exitWith{

			pr _missing = [
				(_loadoutCfg select 1 select _forEachIndex),
				(_loadoutCurrent select 1 select _loadoutCurrentIndex)
			] call jn_fnc_common_array_remove;
			if!(_missing isEqualTo [])then{

				_turrets pushBack _turret;
				_loadoutMissing pushBack _missing;
			}
			
		};
	}forEach (_loadoutCfg select 0);
}forEach (_loadoutCurrent select 0);

[_turrets, _loadoutMissing]
