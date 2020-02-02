#include "defineCommon.inc"

params[["_vehicle",objNull,[objNull]]];

pr _turrets = [];
pr _totalLoadout = [];
pr _magDetail = magazinesAllTurrets _vehicle;

pr "_turretLoadout";
{
	_x params ["_magClass","_turretPath","_ammoCount"];
	if!(_turretPath in _turrets)then{
		_turrets pushBack _turretPath;
		if(!isNil "_turretLoadout")then{_totalLoadout pushBack _turretLoadout;};//skip first one
		_turretLoadout = [];
	};

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

} forEach _magDetail;

_totalLoadout pushBack _turretLoadout;

_pylonLoadout = [];
{
	_pylonLoadout pushBack [_x,_vehicle ammoOnPylon (_forEachIndex + 1)]
}forEach (getPylonMagazines _vehicle);


[_turrets,_totalLoadout,_pylonLoadout];


