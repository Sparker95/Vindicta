/*
This file scans a template and returns items of soldiers...
Author: Sparker 30 september 2019
*/

#define pr private

params ["_t"];

pr _catID = T_INF;
pr _catSize = T_INF_SIZE;
pr _classDefault = _t#_catID#0#0;
pr _subCatID = 0;
pr _group = createGroup WEST;

// Weapons and magazines for corresponding weapons
pr _primaryWeapons = [];
pr _primaryWeaponMagazines = [];

// Weapons and magazines for corresponding weapons
pr _secondaryWeapons = [];
pr _secondaryWeaponMagazines = [];

// Weapons and magazines for corresponding weapons
pr _handgunWeapons = [];
pr _handgunWeaponMagazines = [];

// Items are on their own
pr _primaryWeaponItems = [];
pr _secondaryWeaponItems = [];
pr _handgunWeaponItems = [];

while {_subCatID < _catSize} do {
	pr _classArray = _t#_catID#_subCatID;
	{
		pr _classOrLoadout = _x;
		pr _isLoadout = [_classOrLoadout] call t_fnc_isLoadout;
		
		if (_isLoadout) then {
			diag_log format ["LOADOUT: %1", _classOrLoadout];
		} else {
			diag_log format ["CLASS:   %1", _classOrLoadout];
		};

		// Create a unit from which we will read data
		pr _hO = objNull;
		pr _unitClassName = _classDefault;
		if (!_isLoadout) then {
			_unitClassName = _classOrLoadout;
		};
		_hO = _group createUnit [_unitClassName, [0, 0, 0], [], 100, "CAN_COLLIDE"];

		// Process primary weapon
		pr _weap = primaryWeapon _hO;
		if (! (_weap in _primaryWeapons) && (_weap != "")) then {
			pr _items = primaryWeaponItems _hO;
			pr _mags = getArray (configfile >> "CfgWeapons" >> _weap >> "magazines");
			_primaryWeapons pushBack _weap;
			_primaryWeaponMagazines pushBack _mags;
			{ if (_x != "") then {_primaryWeaponItems pushBackUnique _x} } forEach _items;
		};

		// Process secondary weapon
		pr _weap = secondaryWeapon _hO;
		if (! (_weap in _secondaryWeapons) && (_weap != "")) then {
			pr _items = secondaryWeaponItems _hO;
			pr _mags = getArray (configfile >> "CfgWeapons" >> _weap >> "magazines");
			_secondaryWeapons pushBack _weap;
			_secondaryWeaponMagazines pushBack _mags;
			{ if (_x != "") then {_secondaryWeaponItems pushBackUnique _x} } forEach _items;
		};

		// Process handgun weapon
		pr _weap = handgunWeapon _hO;
		if (! (_weap in _handgunWeapons) && (_weap != "")) then {
			pr _items = handgunItems _hO;
			pr _mags = getArray (configfile >> "CfgWeapons" >> _weap >> "magazines");
			_handgunWeapons pushBack _weap;
			_handgunWeaponMagazines pushBack _mags;
			{ if (_x != "") then {_handgunWeaponItems pushBackUnique _x} } forEach _items;
		};

		// Delete the unit
		deleteVehicle _hO;
	} forEach _classArray;
	_subCatID = _subCatID + 1;
};

diag_log format ["Primary weapons:", _primaryWeapons];
diag_log format ["  %1", _primaryWeapons];
diag_log format ["  %1", _primaryWeaponMagazines];
diag_log format ["  %1", _primaryWeaponItems];

diag_log format ["Secondary weapons:", _secondaryWeapons];
diag_log format ["  %1", _secondaryWeapons];
diag_log format ["  %1", _secondaryWeaponMagazines];
diag_log format ["  %1", _secondaryWeaponItems];

diag_log format ["Handgun weapons:", _handgunWeapons];
diag_log format ["  %1", _handgunWeapons];
diag_log format ["  %1", _handgunWeaponMagazines];
diag_log format ["  %1", _handgunWeaponItems];