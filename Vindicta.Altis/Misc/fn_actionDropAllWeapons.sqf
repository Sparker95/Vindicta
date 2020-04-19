/*
Function: misc_fnc_actionDropAllWeapons
Throw all weapons of a unit in randomly in front of him with some animation and then launch surrender action
Added a random small sleep in case it is applied on a large it will appear more not natural.

Parameters: _unit

_unit - Unit Infantry

Author: zalexki 01.03.2019
Updated: Jeroen 03.03.2019 merging into single weaponholder
*/

params ["_unit"];

private _weaponHolders = [];
private _weapons = [];
private _currentWeapon = currentWeapon _unit; //we need to store it because when you drop a gun it changes
{
	_x params ["_weapon","_dirOffset","_speed"];
	if(_weapon != "")then{
		_weapons pushback _weapon;
		private _dir = direction _unit;
		if(_weapon != _currentWeapon)then{
			_dir = _dir + _dirOffset;
			if(_dir>360)then{_dir = _dir - 360};
		};
		_unit removeWeapon _weapon;
		sleep 0.1;
		private _weaponHolder = "WeaponHolderSimulated" createVehicle [0,0,0];
		_weaponHolder disableCollisionWith _unit;
		_weaponHolder addWeaponCargoGlobal [_weapon,1];
		_weaponHolder setPos (_unit modelToWorld [0,0.2,1.2]);
		_weaponHolders pushback _weaponHolder;
		private _biasX = random [-1.5, 0, 1.5];
		private _biasY = random [-1.5, 0, 1.5];
		_weaponHolder setVelocity [(sin (_dir) * _speed)+_biasX, (cos (_dir) * _speed)+_biasY, 1];
		sleep 0.5;//dorp weapon one by one
	};
}forEach [[secondaryWeapon _unit,190,1.4], [handgunWeapon _unit,90,1.6], [primaryWeapon _unit,170,1.5]];


// we place items together in a non simulated weapon holder.
// better preforments and when weapon holders overlap its hard to find the right one.
if(count _weapons > 0)then{

	sleep 1;
	private _weaponHolder = "GroundWeaponHolder" createVehicle [0,0,0];
	_weaponHolder setPos getpos (_weaponHolders # 0);
	{
		deleteVehicle _x;
	}forEach _weaponHolders;
	
	{
		_weaponHolder addWeaponCargoGlobal [_x,1];
	}forEach _weapons;
};

