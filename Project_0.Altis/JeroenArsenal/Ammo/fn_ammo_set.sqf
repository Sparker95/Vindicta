#include "defineCommon.inc"

params [
	["_vehicle",objNull,[objNull]],
	["_turretPath",[],[[]]],
	["_magazine","",[""]],
	["_amount",0,[0]],
	["_amountPerMag",0,[0]]
];

_vehicle removeMagazinesTurret [_magazine, _turretPath];

while {_amount > _amountPerMag}do{
	_vehicle addMagazineTurret [_magazine, _turretPath, _amountPerMag];
	_amount = _amount - _amountPerMag;
};
if(_amount > 0)then{
	_vehicle addMagazineTurret [_magazine, _turretPath, _amount];
};

//_vehicle setWeaponReloadingTime 