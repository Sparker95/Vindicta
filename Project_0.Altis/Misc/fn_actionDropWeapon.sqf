params ["_dude"];


diag_log format["DEBUG: _dude drop weapon %1", _dude];

_weapon = currentWeapon _dude;
_dude removeWeapon (currentWeapon _dude);
sleep .1;
_weaponHolder = "WeaponHolderSimulated" createVehicle [0,0,0];
_weaponHolder addWeaponCargoGlobal [_weapon,1];
_weaponHolder setPos (_dude modelToWorld [0,.2,1.2]);
_weaponHolder disableCollisionWith _dude;
_dir = random(360);
_speed = 1.5;
_weaponHolder setVelocity [_speed * sin(_dir), _speed * cos(_dir),4];
