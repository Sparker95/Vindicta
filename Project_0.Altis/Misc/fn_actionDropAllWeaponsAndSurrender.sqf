/*
Function: misc_fnc_actionDropAllWeaponsAndSurrender
Throw all weapons of a unit in randomly in front of him with some animation and then launch surrender action
Added a random small sleep in case it is applied on a large it will appear more not natural.

Parameters: _unit

_unit - Unit Infantry

Author: Sen 01.03.2019
*/
params ["_unit"];

private _currentWeapon = currentWeapon _unit;
private _secondWeapon = secondaryWeapon _unit;
private _handgunWeapon = handgunWeapon _unit;

private _rand = ceil(random 6);
diag_log format["sleep %1", _rand];
sleep _rand;

if (!(isNil "_secondWeapon")) then {
	private _speed = 1.4;
	_unit removeWeapon (secondaryWeapon _unit);
	sleep .1;
	_weaponHolder = "WeaponHolderSimulated" createVehicle [0,0,0];
	_weaponHolder disableCollisionWith _unit;
	_weaponHolder addWeaponCargoGlobal [_secondWeapon,1];
	_weaponHolder setPos (_unit modelToWorld [0,0.2,1.2]);
	private _dir = direction _unit;
	private _biasX = random [-1.5, 0, 1.5];
	private _biasY = random [-1.5, 0, 1.5];
	_weaponHolder setVelocity [(sin (_dir) * _speed)+_biasX, (cos (_dir) * _speed)+_biasY, 4];
};

if (!(isNil "_handgunWeapon")) then {
	private _speed = 1.6;
	_unit removeWeapon (handgunWeapon _unit);
	sleep .1;
	_weaponHolder = "WeaponHolderSimulated" createVehicle [0,0,0];
	_weaponHolder disableCollisionWith _unit;
	_weaponHolder addWeaponCargoGlobal [_handgunWeapon,1];
	_weaponHolder setPos (_unit modelToWorld [0,0.2,1.2]);
	private _dir = direction _unit;
	private _biasX = random [-1.5, 0, 1.5];
	private _biasY = random [-1.5, 0, 1.5];
	_weaponHolder setVelocity [(sin (_dir) * _speed)+_biasX, (cos (_dir) * _speed)+_biasY, 4];
};

sleep .1;

if (!(isNil "_currentWeapon")) then {
	private _speed = 1.5;
	_unit removeWeapon (currentWeapon _unit);
	sleep .1;
	_weaponHolder = "WeaponHolderSimulated" createVehicle [0,0,0];
	_weaponHolder disableCollisionWith _unit;
	_weaponHolder addWeaponCargoGlobal [_currentWeapon, 1];
	_weaponHolder setPos (_unit modelToWorld [0,0.2,1.2]);
	private _dir = direction _unit;
	private _biasX = random [-1.5, 0, 1.5];
	private _biasY = random [-1.5, 0, 1.5];
	_weaponHolder setVelocity [(sin (_dir) * _speed)+_biasX, (cos (_dir) * _speed)+_biasY, 4];
};

_unit action ["Surrender", _unit];
