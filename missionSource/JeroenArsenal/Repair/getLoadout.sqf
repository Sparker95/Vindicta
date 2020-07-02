#include "defineCommon.inc"

params["_vehicle"];

pr _currentLoadout = [];
pr _magDetail = magazinesAllTurrets _vehicle;
pr _pylonList = getPylonMagazines _vehicle;
pr _pylonRun = 1;
{
	pr _magClass = _x select 0;
	pr _turretPath = _x select 1;
	pr _ammoCount = _x select 2;
	pr _pylon = -1;
	if (_magclass in _pylonList) then 
	{_pylon = _pylonRun;_pylonRun = _pylonRun + 1;
	_currentLoadout pushBack [_turretPath, _pylon, _magClass, _ammoCount];
	} else
	{
	pr ["_tempAmmo", "_inserted"];
	pr _inserted = false;
		{
			if ((_x select 0) isEqualTo _turretPath && (_x select 2) isEqualTo _magClass) then
			{
				_tempAmmo = (_x select 3);
				_x set [3, (_tempAmmo + _ammoCount)];
				_inserted = true;
			};
		} forEach _currentLoadout;

		if (!_inserted) then
		{
			_currentLoadout pushBack [_turretPath, _pylon, _magClass, _ammoCount];
		};
	};
} forEach _magDetail;

_currentLoadout;