	/*
	Author: code34 nicolas_boiteux@yahoo.fr
	Copyright (C) 2013-2018 Nicolas BOITEUX

	CLASS OO_INVENTORY simple inventory class
	
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>. 
	*/

	#include "oop.h"

	#define OOP_CLASS_NAME OO_INVENTORY
CLASS("OO_INVENTORY")
		PRIVATE VARIABLE("object","unit");

		PUBLIC FUNCTION("object","constructor") { 
			DEBUG(#, "OO_INVENTORY::constructor")
			MEMBER("unit", _this);
		};

		PUBLIC FUNCTION("","getVersion") {
			DEBUG(#, "OO_INVENTORY::getVersion")
			"0.5";
		};

		PUBLIC FUNCTION("object","setUnit") {
			DEBUG(#, "OO_INVENTORY::setUnit")
			MEMBER("unit", _this);
		};

		PUBLIC FUNCTION("","clearInventory") {
			DEBUG(#, "OO_INVENTORY::clearInventory")
			private _unit = MEMBER("unit", nil);
			removeallweapons _unit;
			removeGoggles _unit;
			removeHeadgear _unit;
			removeVest _unit;
			removeUniform _unit;
			removeAllAssignedItems _unit;
			removeBackpack _unit;
		};

		PUBLIC FUNCTION("","clearBackpack") {
			DEBUG(#, "OO_INVENTORY::clearBackpack")
			clearAllItemsFromBackpack MEMBER("unit", nil);
		};

		PUBLIC FUNCTION("","clearBackpackItems") {
			DEBUG(#, "OO_INVENTORY::clearBackpackItems")
			{
				if(!(_x isEqualTo "") and (_x isKindOf ["ItemCore", configFile >> "CfgWeapons"] )) then {
					 MEMBER("unit", nil) removeItemFromBackpack _x;
				};
				uisleep 0.001;
			} foreach (backpackItems MEMBER("unit", nil));
		};

		PUBLIC FUNCTION("","clearBackpackWeapons") {
			DEBUG(#, "OO_INVENTORY::clearBackpackWeapons")
			{
				if(!(_x isEqualTo "") and !(_x isKindOf ["ItemCore", configFile >> "CfgWeapons"] )) then {
					 MEMBER("unit", nil) removeItemFromBackpack _x;
				};
				uisleep 0.001;
			} foreach (backpackItems MEMBER("unit", nil));
		};

		PUBLIC FUNCTION("","clearVest") {
			DEBUG(#, "OO_INVENTORY::clearVest")
			{
				MEMBER("unit", nil) removeItemFromVest _x;
				uisleep 0.001;
			} foreach (vestItems MEMBER("unit", nil));
		};

		PUBLIC FUNCTION("","clearVestItems") {
			DEBUG(#, "OO_INVENTORY::clearVestItems")
			{
				if(!(_x isEqualTo "") and (_x isKindOf ["ItemCore", configFile >> "CfgWeapons"] )) then {
					 MEMBER("unit", nil) removeItemFromVest _x;
				};
				uisleep 0.001;
			} foreach (vestItems MEMBER("unit", nil));
		};

		PUBLIC FUNCTION("","clearVestWeapons") {
			DEBUG(#, "OO_INVENTORY::clearVestWeapons")
			{
				if(!(_x isEqualTo "") and !(_x isKindOf ["ItemCore", configFile >> "CfgWeapons"] )) then {
					 MEMBER("unit", nil) removeItemFromVest _x;
				};
				uisleep 0.001;
			} foreach (vestItems MEMBER("unit", nil));
		};

		PUBLIC FUNCTION("","clearUniform") {
			DEBUG(#, "OO_INVENTORY::clearUniform")
			{
				MEMBER("unit", nil) removeItemFromUniform _x;
				uisleep 0.001;
			} foreach (uniformItems MEMBER("unit", nil));
		};

		PUBLIC FUNCTION("","clearUniformItems") {
			DEBUG(#, "OO_INVENTORY::clearUniformItems")
			{
				if(!(_x isEqualTo "") and (_x isKindOf ["ItemCore", configFile >> "CfgWeapons"] )) then {
					 MEMBER("unit", nil) removeItemFromUniform _x;
				};
				uisleep 0.001;
			} foreach (uniformItems MEMBER("unit", nil));
		};

		PUBLIC FUNCTION("","clearUniformWeapons") {
			DEBUG(#, "OO_INVENTORY::clearUniformWeapons")
			{
				if(!(_x isEqualTo "") and !(_x isKindOf ["ItemCore", configFile >> "CfgWeapons"] )) then {
					 MEMBER("unit", nil) removeItemFromUniform _x;
				};
				uisleep 0.001;
			} foreach (uniformItems MEMBER("unit", nil));
		};

		PUBLIC FUNCTION("","takeOffInventory") {
			DEBUG(#, "OO_INVENTORY::takeOffInventory")
			private _holder = "groundweaponholder" createVehicle position MEMBER("unit", nil);
			_holder setpos (position MEMBER("unit", nil));
			{
				if(_x isEqualType "") then {
					_holder addItemCargoGlobal [_x , 1] ;
				} else {
					{
						_holder addItemCargoGlobal [_x , 1] ;
						uisleep 0.001;
					}foreach _x;
				};
				uisleep 0.001;
			} foreach MEMBER("getInventory", nil);
			MEMBER("clearInventory", nil);
			_holder;
		};

		PUBLIC FUNCTION("","takeOffVest") {
			DEBUG(#, "OO_INVENTORY::takeOffVest")
			private _holder = "groundweaponholder" createVehicle position MEMBER("unit", nil);
			_holder setpos (position MEMBER("unit", nil));
			_holder addItemCargoGlobal [(vest MEMBER("unit", nil)) , 1] ;
			{
				_holder addItemCargoGlobal [_x , 1] ;
				uisleep 0.001;
			} foreach (vestItems MEMBER("unit", nil));
			removeVest MEMBER("unit", nil);
			_holder;
		};

		PUBLIC FUNCTION("","takeOffUniform") {
			DEBUG(#, "OO_INVENTORY::takeOffUniform")
			private _holder = "groundweaponholder" createVehicle position MEMBER("unit", nil);
			_holder setpos (position MEMBER("unit", nil));
			_holder addItemCargoGlobal [(uniform MEMBER("unit", nil)) , 1] ;

			{
				_holder addItemCargoGlobal [_x , 1] ;
				uisleep 0.001;
			} foreach (uniformItems MEMBER("unit", nil));
			removeUniform MEMBER("unit", nil);
			_holder;
		};

		PUBLIC FUNCTION("","takeOffBackPack") {
			DEBUG(#, "OO_INVENTORY::takeOffBackPack")
			MEMBER("unit", nil) addBackpack (backpack MEMBER("unit", nil));
			removeBackpack MEMBER("unit", nil);
		};

		PUBLIC FUNCTION("","takeOffPrimaryWeapon") {
			DEBUG(#, "OO_INVENTORY::takeOffPrimaryWeapon")
			private _holder = "groundweaponholder" createVehicle position MEMBER("unit", nil);
			_holder setpos (position MEMBER("unit", nil));
			_holder addItemCargoGlobal [(primaryWeapon MEMBER("unit", nil)) , 1] ;

		 	{
				if((_x select 3 == 1) and !(_x select 4 in ["Vest", "Uniform", "Backpack"])) then {
					_holder addMagazineAmmoCargo [_x select 0, 1, _x select 1] ;
				};
				uisleep 0.001;
			}foreach (magazinesAmmoFull MEMBER("unit", nil));
			MEMBER("unit", nil) removeWeaponGlobal (primaryWeapon MEMBER("unit", nil));
			_holder;
		};

		PUBLIC FUNCTION("","takeOffSecondaryWeapon") {
			DEBUG(#, "OO_INVENTORY::takeOffSecondaryWeapon")
			private _holder = "groundweaponholder" createVehicle position MEMBER("unit", nil);
			_holder setpos (position MEMBER("unit", nil));
			_holder addItemCargoGlobal [(secondaryWeapon MEMBER("unit", nil)) , 1] ;
		
			{
				if((_x select 3 == 4) and !(_x select 4 in ["Vest", "Uniform", "Backpack"])) then {
					_holder addMagazineAmmoCargo [_x select 0, 1, _x select 1] ;
				};
				uisleep 0.001;
			}foreach (magazinesAmmoFull MEMBER("unit", nil));
			MEMBER("unit", nil) removeWeaponGlobal (secondaryWeapon MEMBER("unit", nil));
			_holder;
		 };

		 PUBLIC FUNCTION("","takeOffHandGun") {
		 	DEBUG(#, "OO_INVENTORY::takeOffHandGun")
			private _holder = "groundweaponholder" createVehicle position MEMBER("unit", nil);
			_holder setpos (position MEMBER("unit", nil));
			_holder addItemCargoGlobal [(handgunWeapon MEMBER("unit", nil)) , 1] ;

			{
				if((_x select 3 == 2) and !(_x select 4 in ["Vest", "Uniform", "Backpack"])) then {
					_holder addMagazineAmmoCargo [_x select 0, 1, _x select 1] ;
				};
				uisleep 0.001;
			}foreach (magazinesAmmoFull MEMBER("unit", nil));
			MEMBER("unit", nil) removeWeaponGlobal (handgunWeapon MEMBER("unit", nil));
			_holder;
		 };

		PUBLIC FUNCTION("","getInventory") {	
			DEBUG(#, "OO_INVENTORY::getInventory")
			private _unit = MEMBER("unit", nil);
			
			private _array = [
				(headgear _unit), 
				(goggles _unit), 
				(uniform _unit), 
				(UniformItems _unit), 
				(vest _unit), 
				(VestItems _unit), 
				(backpack _unit), 
				(backpackItems _unit), 
				(magazinesAmmoFull _unit),
				(primaryWeapon _unit), 
				(primaryWeaponItems _unit),
				(secondaryWeapon _unit),
				(secondaryWeaponItems _unit),
				(handgunWeapon _unit),
				(handgunItems _unit),
				(assignedItems _unit)
			];
			_array;
		};

		PUBLIC FUNCTION("","getPrimaryWeaponType") {
			DEBUG(#, "OO_INVENTORY::getPrimaryWeaponType")
			primaryWeapon MEMBER("unit", nil);
		};

		PUBLIC FUNCTION("","getSecondaryWeaponType") {
			DEBUG(#, "OO_INVENTORY::getSecondaryWeaponType")
			secondaryWeapon MEMBER("unit", nil);
		};

		PUBLIC FUNCTION("","getHandGunType") {
			DEBUG(#, "OO_INVENTORY::getHandGunType")
			handgunWeapon MEMBER("unit", nil);
		};

		PUBLIC FUNCTION("","getBackPackType") {
			DEBUG(#, "OO_INVENTORY::getBackPackType")
			backpack MEMBER("unit", nil);
		};

		PUBLIC FUNCTION("","getVestType") {
			DEBUG(#, "OO_INVENTORY::getVestType")
			vest MEMBER("unit", nil);
		};

		PUBLIC FUNCTION("","getUniformType") {
			DEBUG(#, "OO_INVENTORY::getUniformType")
			uniform MEMBER("unit", nil);
		};

		PUBLIC FUNCTION("","getBackPack") {
			DEBUG(#, "OO_INVENTORY::getBackPack")
			unitBackpack MEMBER("unit", nil);
		};

		PUBLIC FUNCTION("","getUniformItems") {
			DEBUG(#, "OO_INVENTORY::getUniformItems")
			private _array = [];

			{
				if(!(_x isEqualTo "") and (_x isKindOf ["ItemCore", configFile >> "CfgWeapons"] )) then {
					_array pushBack _x;
				};
				uisleep 0.001;
			} foreach (uniformItems MEMBER("unit", nil));
			_array;
		};

		PUBLIC FUNCTION("","getUniformWeapons") {
			DEBUG(#, "OO_INVENTORY::getUniformWeapons")
			private _array = [];

			{
				if(!(_x isEqualTo "") and !(_x isKindOf ["ItemCore", configFile >> "CfgWeapons"] )) then {
					_array pushBack _x;
				};
				uisleep 0.001;
			} foreach (uniformItems MEMBER("unit", nil));
			_array;
		};

		PUBLIC FUNCTION("","getVestItems") {
			DEBUG(#, "OO_INVENTORY::getVestItems")
			private _array = [];

			{
				if(!(_x isEqualTo "") and (_x isKindOf ["ItemCore", configFile >> "CfgWeapons"] )) then {
					_array pushBack _x;
				};
				uisleep 0.001;
			} foreach (vestItems MEMBER("unit", nil));
			_array;
		};

		PUBLIC FUNCTION("","getVestWeapons") {
			DEBUG(#, "OO_INVENTORY::getVestWeapons")
			private _array = [];

			{
				if(!(_x isEqualTo "") and !(_x isKindOf ["ItemCore", configFile >> "CfgWeapons"] )) then {
					_array pushBack _x;
				};
				uisleep 0.001;
			} foreach (vestItems MEMBER("unit", nil));
			_array;
		};

		PUBLIC FUNCTION("","getBackPackItems") {
			DEBUG(#, "OO_INVENTORY::getBackPackItems")
			private _array = [];

			{
				if(!(_x isEqualTo "") and (_x isKindOf ["ItemCore", configFile >> "CfgWeapons"] )) then {
					_array pushBack _x;
				};
				uisleep 0.001;
			} foreach (backpackItems MEMBER("unit", nil));
			_array;
		};

		PUBLIC FUNCTION("","getBackPackWeapons") {
			DEBUG(#, "OO_INVENTORY::getBackPackWeapons")
			private _array = [];

			{
				if(!(_x isEqualTo "") and !(_x isKindOf ["ItemCore", configFile >> "CfgWeapons"] )) then {
					_array pushBack _x;
				};
				uisleep 0.001;
			} foreach (backpackItems MEMBER("unit", nil));
			_array;
		};


		PUBLIC FUNCTION("string","getAmmoLoadedType") {
			DEBUG(#, "OO_INVENTORY::getAmmoLoadedType")
			private _ammo = "";
			private _type = 1;

			switch (tolower _this) do {
				case "primaryweapon" : { _type = 1;};
				case "secondaryweapon" : { _type = 4; 	};
				case "handgun" : { _type = 2;};
				case "grenade" : { _type = 0; };
				default { _type = 1; };
			};

			{
				if((_x select 3 == _type) and !(_x select 4 in ["Vest", "Uniform", "Backpack"])) then {
					_ammo = _x select 0;
				};
				uisleep 0.001;
			}foreach (magazinesAmmoFull MEMBER("unit", nil));
			_ammo;
		};

		PUBLIC FUNCTION("string","getAmmoCountByType") {
			DEBUG(#, "OO_INVENTORY::getAmmoCountByType")
			private _type = _this;
			private _count = 0;

			{
				if((_x select 0) isEqualTo _type)  then {
					_count = (_x select 1) + _count;
				};
				uisleep 0.001;
			}foreach (magazinesAmmoFull MEMBER("unit", nil));
			_count;
		};

		PUBLIC FUNCTION("string","getMagazinesCountByType") {
			DEBUG(#, "OO_INVENTORY::getMagazinesCountByType")
			private _type = _this;
			private _count = 0;

			{
				if((_x select 0)  isEqualTo _type)  then { 
					_count = _count + 1;
				};
				uisleep 0.001;
			}foreach (magazinesAmmoFull MEMBER("unit", nil));
			_count;
		};

		PUBLIC FUNCTION("string","getAmmoCountByWeapon") {
			DEBUG(#, "OO_INVENTORY::getAmmoCountByWeapon")
			private _count = 0;
			private _type = "";

			switch (tolower _this) do {
				case "primaryweapon" : { _type = (primaryWeaponMagazine MEMBER("unit", nil)) select 0; };
				case "secondaryweapon" : { _type = (secondaryWeaponMagazine MEMBER("unit", nil)) select 0; };
				case "handgun" : { _type = (handgunMagazine MEMBER("unit", nil)) select 0; };
				default { _type = (primaryWeaponMagazine MEMBER("unit", nil)) select 0; };
			};

			if(isnil "_type") then {_type = "";};
			MEMBER("getAmmoCountByType", _type);
		};

		PUBLIC FUNCTION("string","getAmmoLoadedCount") {
			DEBUG(#, "OO_INVENTORY::getAmmoLoadedCount")
			private _count = 0;
			private _type = "";

			switch (tolower _this) do {
				case "primaryweapon" : {_type = 1; };
				case "secondaryweapon" : { _type = 4;	};
				case "handgun" : { _type = 2;};
				case "grenade" : {_type = 0;};
				default {_type = 1;};
			};

			{
				if((_x select 3 == _type) and !(_x select 4 in ["Vest", "Uniform", "Backpack"])) then {
					_count = _x select 1;
				};
				uisleep 0.001;
			}foreach (magazinesAmmoFull MEMBER("unit", nil));
			_count;
		};

		PUBLIC FUNCTION("","hasBackPack") {
			DEBUG(#, "OO_INVENTORY::hasBackPack")
			if(backpack MEMBER("unit", nil) isEqualTo "") then { false;} else {true;};
		};

		PUBLIC FUNCTION("","hasVest") {
			DEBUG(#, "OO_INVENTORY::hasVest")
			if(vest MEMBER("unit", nil) isEqualTo "") then { false;} else {true;};
		};

		PUBLIC FUNCTION("","hasUniform") {
			DEBUG(#, "OO_INVENTORY::hasUniform")
			if(uniform MEMBER("unit", nil) isEqualTo "") then { false;} else {true;};
		};

		PUBLIC FUNCTION("","hasPrimaryWeapon") {
			DEBUG(#, "OO_INVENTORY::hasPrimaryWeapon")
			if(primaryWeapon MEMBER("unit", nil) isEqualTo "") then { false;} else {true;};
		};

		PUBLIC FUNCTION("","hasSecondaryWeapon") {
			DEBUG(#, "OO_INVENTORY::hasSecondaryWeapon")
			if(secondaryWeapon MEMBER("unit", nil) isEqualTo "") then { false;} else {true;};
		};

		PUBLIC FUNCTION("","hasHandGun") {
			DEBUG(#, "OO_INVENTORY::hasHandGun")
			if(handgunWeapon MEMBER("unit", nil) isEqualTo "") then { false;} else {true;};
		};

		PUBLIC FUNCTION("","hasHeadGear") {
			DEBUG(#, "OO_INVENTORY::hasHeadGear")
			if(headgear MEMBER("unit", nil) isEqualTo "") then { false;} else {true;};
		};

		PUBLIC FUNCTION("","hasGoggles") {
			DEBUG(#, "OO_INVENTORY::hasGoggles")
			if(goggles MEMBER("unit", nil) isEqualTo "") then { false;} else {true;};
		};

		PUBLIC FUNCTION("array","setInventory") {
			DEBUG(#, "OO_INVENTORY::setInventory")
			private _array = _this;
			MEMBER("clearInventory", nil);
			private _headgear = _array select 0;
			private _goggles = _array select 1;
			private _uniform = _array select 2;
			private _uniformitems = _array select 3;
			private _vest = _array select 4;
			private _vestitems = _array select 5;
			private _backpack = _array select 6;
			private _backpackitems = _array select 7;
			private _fullmagazine = _array select 8;
			private _primaryweapon = _array select 9;
			private _primaryweaponitems = _array select 10;
			private _secondaryweapon = _array select 11;
			private _secondaryweaponitems = _array select 12;
			private _handgunweapon = _array select 13;
			private _handgunweaponitems = _array select 14;
			private _assigneditems = _array select 15;

			private _unit = MEMBER("unit", nil);
			_unit addHeadgear _headgear;
			_unit forceAddUniform _uniform;
			_unit addGoggles _goggles;
			_unit addVest _vest;

			{
				if(!(_x isEqualTo "") and (_x isKindOf ["ItemCore", configFile >> "CfgWeapons"] )) then {
					_unit addItemToUniform _x;
				};
			}foreach _uniformitems;
	
			{
				if(!(_x isEqualTo "") and (_x isKindOf ["ItemCore", configFile >> "CfgWeapons"] )) then {
					_unit addItemToVest _x;
				};
			}foreach _vestitems;
	
			if!(_backpack isEqualTo "") then {
				_unit addbackpack _backpack;
				{
					if(!(_x isEqualTo "") and (_x isKindOf ["ItemCore", configFile >> "CfgWeapons"] )) then {
						_unit addItemToBackpack _x;
					};
				} foreach _backpackitems;
			};
	
			{
				if!(_x isEqualTo "") then {
					_unit addMagazine [_x select 0, _x select 1];
				};
			} foreach _fullmagazine;

			//must be after assign items to secure loading mags
			_unit addweapon _primaryweapon;
	
			{
				if(_x != "") then {
					_unit addPrimaryWeaponItem _x;
				};
			} foreach _primaryweaponitems;

			_unit addweapon _secondaryweapon;
	
			{
				if(_x != "") then {
					_unit addSecondaryWeaponItem _x;
				};
			} foreach _secondaryweaponitems;
	

			_unit addweapon _handgunweapon;
			{
				if(_x != "") then {
					_unit addHandgunItem _x;
				};
			} foreach _handgunweaponitems;
	
			{
				if(_x != "") then {
					_unit addweapon _x;
				};
			} foreach _assigneditems;
			if (needReload _unit == 1) then {reload _unit};
		};

		PUBLIC FUNCTION("","deconstructor") {
			DEBUG(#, "OO_INVENTORY::deconstructor")
			DELETE_VARIABLE("unit");
		 };
	ENDCLASS;