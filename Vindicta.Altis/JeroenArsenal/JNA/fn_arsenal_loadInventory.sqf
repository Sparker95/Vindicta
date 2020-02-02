#include "defineCommon.inc"


//items that need to be removed from arsenal
pr _arrayPlaced = EMPTY_ARRAY;
pr _arrayTaken = EMPTY_ARRAY;
pr _arrayMissing = [];
pr _arrayReplaced = [];

pr  _addToArray = {
	params ["_array","_index","_item","_amount"];

	if(_index != -1 && !(_item isEqualTo "") && _amount != 0)then{
		_array set [_index,[_array select _index,[_item,_amount]] call jn_fnc_common_array_add];
	};
};

pr _removeFromArray = {
	params ["_array","_index","_item","_amount"];

	if(_index != -1 && !(_item isEqualTo "") && _amount != 0)then{
		_array set [_index,[_array select _index,[_item,_amount]] call jn_fnc_common_array_remove];
	};
};

pr _addArrays = {
	_array1 = +(_this select 0);
	_array2 = +(_this select 1);
	{
		_index = _foreachindex;
		{
			_item = _x select 0;
			_amount = _x select 1;
			[_array1,_index,_item,_amount]call _addToArray;
		} forEach _x;
	} forEach _array2;
	_array1;
};

pr _subtractArrays = {
	_array1 = +(_this select 0);
	_array2 = +(_this select 1);
	{
		_index = _foreachindex;
		{
			_item = _x select 0;
			_amount = _x select 1;
			[_array1,_index,_item,_amount]call _removeFromArray;
		} forEach _x;
	} forEach _array2;
	_array1;
};

//name that needed to be loaded
pr _saveName = _this;
pr _object = UINamespace getVariable "jn_object";
pr _dataList = _object getVariable "jna_dataList";


pr _saveData = profilenamespace getvariable ["bis_fnc_saveInventory_data",[]];
pr _inventory = [];
{
	if (typename _x  == "STRING" && {_x == _saveName}) exitWith {
		_inventory = _saveData select (_foreachindex + 1);
	};
} forEach _saveData;

//[["U_B_CombatUniform_mcam",["FirstAidKit","30Rnd_65x39_caseless_mag","30Rnd_65x39_caseless_mag","Chemlight_green"]],["V_BandollierB_rgr",["30Rnd_65x39_caseless_mag","11Rnd_45ACP_Mag","11Rnd_45ACP_Mag","SmokeShell","SmokeShellGreen","Chemlight_green"]],["",[]],"H_MilCap_mcamo","","Binocular",["arifle_MXC_F",["","","optic_Aco",""],"30Rnd_65x39_caseless_mag"],["",["","","",""],""],["hgun_Pistol_heavy_01_F",["","","optic_MRD",""],"11Rnd_45ACP_Mag"],["ItemMap","ItemCompass","ItemWatch","ItemRadio","ItemGPS"],["WhiteHead_20","male07eng",""]]

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// REMOVE
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// magazines (loaded)
//["30Rnd_65x39_caseless_green",30,false,-1,"Uniform"]
{
	pr _loaded = _x select 2; //we only want need the mags that are loaded in a weapon
	if(_loaded) then {
		pr _item = _x select 0;
		pr _amount = _x select 1;
		pr _index = _item call jn_fnc_arsenal_itemType;
		//We dont need to remove the magazines here because they will be removed with the weapon later.
		[_arrayPlaced,_index,_item,_amount] call _addToArray;
	};
} foreach magazinesAmmoFull player;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// assinged items
pr _assignedItems_old = assignedItems player - [binocular player] + [headgear player] + [goggles player]; //we ignore binocular here, because its a weapon
{
	pr _item = _x;
	pr _amount = 1;
	pr _index = _item call jn_fnc_arsenal_itemType;
	player unlinkItem _item;
	[_arrayPlaced,_index,_item,_amount]call _addToArray;
} forEach _assignedItems_old - [""];

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  weapon attachments
pr _attachments = primaryWeaponItems player + secondaryWeaponItems player + handgunItems player;
{
	pr _item = _x;
	pr _amount = 1;
	pr _index = _item call jn_fnc_arsenal_itemType;
	//We dont need to remove the attachments here because they will be removed with the weapon later.
	[_arrayPlaced,_index,_item,_amount]call _addToArray;
} forEach _attachments - [""];

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	weapons
pr _weapons_old = [primaryWeapon player, secondaryWeapon player, handgunWeapon player, binocular player];
{
	pr _item = _x;
	if(_item != "")then{
		pr _amount = 1;
		pr _index = _foreachindex;
		player removeWeapon _item;
		[_arrayPlaced,_index,_item,_amount]call _addToArray;
	};
} forEach _weapons_old; // - [""]; we can use the _foreachindex as index number so we dont need jn_fnc_arsenal_itemType

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	uniform backpack vest (inc itmes)
pr _uniform_old = uniform player;
pr _vest_old = vest player;
pr _backpack_old = backpack player;

//remove items from containers
{
	pr _array = (_x call jn_fnc_arsenal_cargoToArray);
	//We dont need to remove the items here because they will be removed with uniform,vest and backpack later.
	_arrayPlaced = [_arrayPlaced, _array] call _addArrays;
} forEach [uniformContainer player, vestContainer player, backpackContainer player];

//remove containers
removeUniform player;
[_arrayPlaced,IDC_RSCDISPLAYARSENAL_TAB_UNIFORM,_uniform_old,1]call _addToArray;
removeVest player;
[_arrayPlaced,IDC_RSCDISPLAYARSENAL_TAB_VEST,_vest_old,1]call _addToArray;
removeBackpack player;
[_arrayPlaced,IDC_RSCDISPLAYARSENAL_TAB_BACKPACK,_backpack_old,1]call _addToArray;


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  ADD
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
pr _availableItems = [_dataList, _arrayPlaced] call _addArrays;
pr _itemCounts =+ _availableItems;

//TODO add member only stuff
// Let's not add it maybe? Not sure if we need that.
/*
pr _isMember = true;
{
	_index = _foreachindex;
	_subArray = _x;
	{
		_item = _x select 0;
		_amount = (_x select 1);
		if (_amount != -1) then {
			_amount = [(_x select 1) - (jna_minItemMember select _index),(_x select 1)] select _isMember;
		};
		_subArray set [_foreachindex, [_item,_amount]];
	} forEach _subArray;
	_availableItems set [_index, _subArray];
} forEach _availableItems;
*/

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  assigned items
pr _assignedItems = ((_inventory select 9) + [_inventory select 3] + [_inventory select 4]+ [_inventory select 5]);	    	//TODO add binocular batteries dont work yet
{// forEach _assignedItems - [""];
	pr _item = _x;
	pr _amount = 1;
	pr _index = _item call jn_fnc_arsenal_itemType;

	if(_index == -1) then {
		_arrayMissing = [_arrayMissing,[_item,_amount]] call jn_fnc_common_array_add;
	} else {

		//TFAR fix, find base radio
		pr _radioName = getText(configfile >> "CfgWeapons" >> _item >> "tf_parent");
		if!(_radioName isEqualTo "")then{
			_item =_radioName;
		};

		
		if ([_item, _itemCounts select _index] call jn_fnc_arsenal_itemCount == -1) then {
			if(_item isEqualTo (_inventory select 5) )then{
				player addweapon _item;
			}else{
				player linkItem _item;
			};
		} else {
			if ([_item, _availableItems select _index] call jn_fnc_arsenal_itemCount > 0) then {
				if(_item isEqualTo (_inventory select 5) )then{
					player addweapon _item;
				}else{
					player linkItem _item;
				};
				[_arrayTaken,_index,_item,_amount]call _addToArray;
				[_availableItems,_index,_item,_amount]call _removeFromArray;
			} else {
				_arrayMissing = [_arrayMissing,[_item,_amount]] call jn_fnc_common_array_add;
			};
		};



	};
} forEach _assignedItems - [""];

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// weapons and attachments
removeBackpack player;
player addBackpack "B_Carryall_oli"; //temp backpack for adding magazines to weapons
pr _weapons = [_inventory select 6,_inventory select 7,_inventory select 8];
{//forEach _weapons;
	pr _item = _x select 0;

	if!(_item isEqualTo "")then{
		pr _itemAttachmets = _x select 1;
		pr _itemMag = _x select 2;
		pr _amount = 1;
		pr _amountMag = getNumber (configfile >> "CfgMagazines" >> _itemMag >> "count");
		pr _index = _foreachindex;
		pr _indexMag = IDC_RSCDISPLAYARSENAL_TAB_CARGOMAGALL;

		//add ammo to backpack, which need to be loaded in the gun.
		call {
			if ([_itemMag, _itemCounts select _indexMag] call jn_fnc_arsenal_itemCount == -1) exitWith {
				player addMagazine [_itemMag, _amountMag];
			};

			pr _amountMagAvailable = [_itemMag, _availableItems select _indexMag] call jn_fnc_arsenal_itemCount;
			if (_amountMagAvailable > 0) then {
				if (_amountMagAvailable < _amountMag) then {
					_arrayMissing = [_arrayMissing,[_itemMag,_amountMag]] call jn_fnc_common_array_add;
					_amountMag = _amountMagAvailable;
				};
			[_arrayTaken,_indexMag,_itemMag,_amountMag] call _addToArray;
			[_availableItems,_indexMag,_itemMag,_amountMag] call _removeFromArray;
			player addMagazine [_itemMag, _amountMag];
			} else {
				_arrayMissing = [_arrayMissing,[_itemMag,_amountMag]] call jn_fnc_common_array_add;
			};
		};

		//adding the gun
		call {
			if ((_index != -1) AND ([_item, _itemCounts select _index] call jn_fnc_arsenal_itemCount == -1)) exitWith {
				player addWeapon _item;
			};

			if ((_index != -1) AND {[_item, _availableItems select _index] call jn_fnc_arsenal_itemCount > 0}) then {
				player addWeapon _item;
				[_arrayTaken,_index,_item,_amount] call _addToArray;
				[_availableItems,_index,_item,_amount] call _removeFromArray;
			} else {
				_arrayMissing = [_arrayMissing,[_item,_amount]] call jn_fnc_common_array_add;
			};
		};

		//add attachments
		{
			pr _itemAcc = _x;
			if!(_itemAcc isEqualTo "")then{
				pr _amountAcc = 1;
				pr _indexAcc = _itemAcc call jn_fnc_arsenal_itemType;

				call {

					if ((_indexAcc != -1) AND ([_itemAcc, _itemCounts select _indexAcc] call jn_fnc_arsenal_itemCount == -1)) exitWith {
						switch _index do{
							case IDC_RSCDISPLAYARSENAL_TAB_PRIMARYWEAPON:{player addPrimaryWeaponItem _itemAcc;};
							case IDC_RSCDISPLAYARSENAL_TAB_SECONDARYWEAPON:{player addSecondaryWeaponItem _itemAcc;};
							case IDC_RSCDISPLAYARSENAL_TAB_HANDGUN:{player addHandgunItem _itemAcc;};
						};
					};

					if ((_indexAcc != -1) AND {[_itemAcc, _availableItems select _indexAcc] call jn_fnc_arsenal_itemCount != 0}) then {
						switch _index do{
							case IDC_RSCDISPLAYARSENAL_TAB_PRIMARYWEAPON:{player addPrimaryWeaponItem _itemAcc;};
							case IDC_RSCDISPLAYARSENAL_TAB_SECONDARYWEAPON:{player addSecondaryWeaponItem _itemAcc;};
							case IDC_RSCDISPLAYARSENAL_TAB_HANDGUN:{player addHandgunItem _itemAcc;};
						};
						[_arrayTaken,_indexAcc,_itemAcc,_amountAcc] call _addToArray;
						[_availableItems,_indexAcc,_itemAcc,_amountAcc] call _removeFromArray;
					} else {
						_arrayMissing = [_arrayMissing,[_itemAcc,_amountAcc]] call jn_fnc_common_array_add;
					};
				};
			};
		}foreach _itemAttachmets;
	};
} forEach _weapons;
removeBackpack player;//Remove temporary backpack

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  vest, uniform and backpack
pr _uniform = _inventory select 0 select 0;
pr _vest = _inventory select 1 select 0;
pr _backpack = _inventory select 2 select 0;

pr _uniformItems = _inventory select 0 select 1;
pr _vestItems = _inventory select 1 select 1;
pr _backpackItems = _inventory select 2 select 1;

//add containers
pr _containers = [_uniform,_vest,_backpack];
pr _invCallArray = [
	{removeUniform player;player forceAddUniform _this;},//todo remove function because its done already before
    {removeVest player;player addVest _this;},
    {removeBackpackGlobal player;player addBackpack _this;}
];

{
	pr _item = _x;
	if!(_item isEqualTo "")then{
		pr _amount = 1;
		pr _index = [
			IDC_RSCDISPLAYARSENAL_TAB_UNIFORM,
			IDC_RSCDISPLAYARSENAL_TAB_VEST,
			IDC_RSCDISPLAYARSENAL_TAB_BACKPACK
		] select _foreachindex;

		if ([_item, _itemCounts select _index] call jn_fnc_arsenal_itemCount == -1) then {
				_item call (_invCallArray select _foreachindex);
		}else{
			if ([_item, _availableItems select _index] call jn_fnc_arsenal_itemCount > 0) then {
				_item call (_invCallArray select _foreachindex);
				[_arrayTaken,_index,_item,_amount] call _addToArray;
				[_availableItems,_index,_item,_amount] call _removeFromArray;
			} else {
				pr _oldItem = [_uniform_old,_vest_old,_backpack_old] select _foreachindex;
				if !(_oldItem isEqualTo "") then {
					_oldItem call (_invCallArray select _foreachindex);
					_arrayReplaced = [_arrayReplaced,[_item,_oldItem]] call jn_fnc_common_array_add;
					[_arrayTaken,_index,_oldItem,1] call _addToArray;
				} else {
					_arrayMissing = [_arrayMissing,[_item,_amount]] call jn_fnc_common_array_add;
				};
			};
		};
	};
} forEach _containers;

//add items to containers
{
	pr _container = call (_x select 0);
	pr _items = _x select 1;

	{
		pr _item = _x;
		pr _index = _item call jn_fnc_arsenal_itemType;

		if(_index == -1)then{
			pr _amount = 1; // we will never know the ammo count in the magazines anymore :c
			_arrayMissing = [_arrayMissing,[_item,_amount]] call jn_fnc_common_array_add;
		} else {
			pr _amountAvailable = [_item, _availableItems select _index] call jn_fnc_arsenal_itemCount;
			if (_index == IDC_RSCDISPLAYARSENAL_TAB_CARGOMAGALL) then {
				pr _amount = getNumber (configfile >> "CfgMagazines" >> _item >> "count");
				call {
					if ([_item, _itemCounts select _index] call jn_fnc_arsenal_itemCount == -1) exitWith {
						_container addMagazineAmmoCargo [_item,1, _amount];
					};

					if(_amountAvailable < _amount) then {
						_amount = _amountAvailable;
						_arrayMissing = [_arrayMissing,[_item,(_amount - _amountAvailable)]] call jn_fnc_common_array_add;
					};
					[_arrayTaken,_index,_item,_amount] call _addToArray;
					[_availableItems,_index,_item,_amount] call _removeFromArray;
					if (_amount>0) then {//prevent empty mags
						_container addMagazineAmmoCargo  [_item,1, _amount];
					};
				};
			} else {
				pr _amount = 1;
				call {
					if ([_item, _itemCounts select _index] call jn_fnc_arsenal_itemCount == -1) exitWith {
						_container addItemCargo [_item, 1];
					};

					if (_amountAvailable >= _amount) then {
						_container addItemCargo [_item,_amount];
						[_arrayTaken,_index,_item,_amount] call _addToArray;
						[_availableItems,_index,_item,_amount] call _removeFromArray;
					} else {
						_arrayMissing = [_arrayMissing,[_item,_amount]] call jn_fnc_common_array_add;
					};
				};
			};
		};
	} forEach _items;
} forEach [
	[{uniformContainer player},_uniformItems],
	[{vestContainer player},_vestItems],
	[{backpackContainer player},_backpackItems]
];


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  Update global
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

_arrayAdd = [_arrayPlaced, _arrayTaken] call _subtractArrays; //remove items that where not added
_arrayRemove = [_arrayTaken, _arrayPlaced] call _subtractArrays;

[_object,_arrayAdd] call jn_fnc_arsenal_addItem;

[_object, _arrayRemove] call jn_fnc_arsenal_removeItem;

//create text for missing and replaced items
//we could use ingame names here but some items might not be ingame(disabled mod), but if you feel like it you can still add it.

pr _reportTotal = "";
pr _reportReplaced = "";
{
	pr _nameNew = _x select 0;
	pr _nameOld = _x select 1;
	_reportReplaced = _reportReplaced + _nameOld + " instead of " + _nameNew + "\n";
} forEach _arrayReplaced;

if!(_reportReplaced isEqualTo "")then{
	_reportTotal = ("I keep this items because i couldn't find the other ones:\n" + _reportReplaced+"\n");
};

pr _reportMissing = "";
{
	pr _name = _x select 0;
	pr _amount = _x select 1;
	_reportMissing = _reportMissing + _name + " (" + (str _amount) + "x)\n";
}forEach _arrayMissing;

if!(_reportMissing isEqualTo "")then{
	_reportTotal = (_reportTotal+"I couldn't find the following items:\n" + _reportMissing+"\n");
};

if!(_reportTotal isEqualTo "")then{
	titleText[_reportTotal, "PLAIN"];
};


/*
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
[
	"13",
	[
		["U_BG_Guerilla2_3",["30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green"]],
		["",[]],
		["B_Carryall_oli",["30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green"]],
		"H_Beret_blk",
		"G_Bandanna_blk",
		"Binocular",
		["arifle_TRG21_F",["","","",""],""],
		["launch_I_Titan_F",["","","",""],"Titan_AA"],
		["",["","","",""],""],
		["ItemMap","ItemCompass","ItemWatch","ItemRadio","ItemGPS","NVGoggles"],
		["GreekHead_A3_01","Male01GRE",""]
	]
]
*/
