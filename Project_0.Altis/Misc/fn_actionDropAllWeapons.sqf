params ["_unit"];

_weapon = currentWeapon _unit;
_secondWeapon = secondaryWeapon _unit;
_handgunWeapon = handgunWeapon _unit;

if (!(isNil "_secondWeapon")) then {
	_unit removeWeapon _secondWeapon;
	sleep .1;
	_weaponHolder = "WeaponHolderSimulated" createVehicle [0,0,0];
	_weaponHolder disableCollisionWith _unit;
	_weaponHolder addWeaponCargoGlobal [_secondWeapon,1];
	_weaponHolder setPos (_unit modelToWorld [0,.2,.2]);
};

if (!(isNil "_handgunWeapon")) then {
	_unit removeWeapon _handgunWeapon;
	sleep .1;
	_weaponHolder = "WeaponHolderSimulated" createVehicle [0,0,0];
	_weaponHolder disableCollisionWith _unit;
	_weaponHolder addWeaponCargoGlobal [_handgunWeapon,1];
	_weaponHolder setPos (_unit modelToWorld [0,.2,.2]);
};

_unit removeWeapon (currentWeapon _unit);
sleep .1;
_weaponHolder = "WeaponHolderSimulated" createVehicle [0,0,0];
_weaponHolder disableCollisionWith _unit;
_weaponHolder addWeaponCargoGlobal [_weapon,1];
_weaponHolder setPos (_unit modelToWorld [0,.2,1.2]);
_dir = random(360);
_speed = 1.5;
_weaponHolder setVelocity [_speed * sin(_dir), _speed * cos(_dir),4];
