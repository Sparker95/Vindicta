fnc_selectPlayerSpawnLoadout = {
	call (selectRandom T_SpawnPlayerVariants);
};

T_SpawnPlayerVariants = [
	{
		comment "Exported from Arsenal by william.woodbury";

		comment "[!] UNIT MUST BE LOCAL [!]";
		if (!local _this) exitWith {};

		comment "Remove existing items";
		removeAllWeapons _this;
		removeAllItems _this;
		removeAllAssignedItems _this;
		removeUniform _this;
		removeVest _this;
		removeBackpack _this;
		removeHeadgear _this;
		removeGoggles _this;

		comment "Add containers";
		_this forceAddUniform "U_C_Poloshirt_blue";
		for "_i" from 1 to 2 do {_this addItemToUniform "11Rnd_45ACP_Mag";};
		_this addBackpack "B_AssaultPack_cbr";
		_this addHeadgear "H_Bandanna_gry";

		comment "Add weapons";
		_this addWeapon "hgun_Pistol_heavy_01_F";

		comment "Add items";
		_this linkItem "ItemMap";
		_this linkItem "ItemCompass";
		_this linkItem "ItemWatch";

		comment "Set identity";
		[_this,"Default","male01gre"] call BIS_fnc_setIdentity;
	},
	{
		comment "Exported from Arsenal by william.woodbury";

		comment "[!] UNIT MUST BE LOCAL [!]";
		if (!local _this) exitWith {};

		comment "Remove existing items";
		removeAllWeapons _this;
		removeAllItems _this;
		removeAllAssignedItems _this;
		removeUniform _this;
		removeVest _this;
		removeBackpack _this;
		removeHeadgear _this;
		removeGoggles _this;

		comment "Add containers";
		_this forceAddUniform "U_C_Poloshirt_redwhite";
		for "_i" from 1 to 3 do {_this addItemToUniform "9Rnd_45ACP_Mag";};
		_this addHeadgear "H_Bandanna_gry";

		comment "Add weapons";
		_this addWeapon "hgun_ACPC2_F";

		comment "Add items";
		_this linkItem "ItemMap";
		_this linkItem "ItemCompass";
		_this linkItem "ItemWatch";

		comment "Set identity";
		[_this,"Default","male01gre"] call BIS_fnc_setIdentity;
	},
	{
		comment "Exported from Arsenal by william.woodbury";

		comment "[!] UNIT MUST BE LOCAL [!]";
		if (!local _this) exitWith {};

		comment "Remove existing items";
		removeAllWeapons _this;
		removeAllItems _this;
		removeAllAssignedItems _this;
		removeUniform _this;
		removeVest _this;
		removeBackpack _this;
		removeHeadgear _this;
		removeGoggles _this;

		comment "Add containers";
		_this forceAddUniform "U_C_HunterBody_grn";
		for "_i" from 1 to 5 do {_this addItemToUniform "16Rnd_9x21_Mag";};
		_this addBackpack "B_AssaultPack_cbr";
		_this addHeadgear "H_Bandanna_gry";

		comment "Add weapons";
		_this addWeapon "hgun_P07_F";

		comment "Add items";
		_this linkItem "ItemMap";
		_this linkItem "ItemCompass";
		_this linkItem "ItemWatch";

		comment "Set identity";
		[_this,"Default","male01gre"] call BIS_fnc_setIdentity;
	},
	{
		comment "Exported from Arsenal by william.woodbury";

		comment "[!] UNIT MUST BE LOCAL [!]";
		if (!local _this) exitWith {};

		comment "Remove existing items";
		removeAllWeapons _this;
		removeAllItems _this;
		removeAllAssignedItems _this;
		removeUniform _this;
		removeVest _this;
		removeBackpack _this;
		removeHeadgear _this;
		removeGoggles _this;

		comment "Add containers";
		_this forceAddUniform "U_OrestesBody";
		for "_i" from 1 to 3 do {_this addItemToUniform "16Rnd_9x21_Mag";};
		_this addBackpack "B_AssaultPack_cbr";
		_this addHeadgear "H_Bandanna_gry";

		comment "Add weapons";
		_this addWeapon "hgun_Rook40_F";

		comment "Add items";
		_this linkItem "ItemMap";
		_this linkItem "ItemCompass";
		_this linkItem "ItemWatch";

		comment "Set identity";
		[_this,"Default","male01gre"] call BIS_fnc_setIdentity;
	},
	{
		comment "Exported from Arsenal by william.woodbury";

		comment "[!] UNIT MUST BE LOCAL [!]";
		if (!local _this) exitWith {};

		comment "Remove existing items";
		removeAllWeapons _this;
		removeAllItems _this;
		removeAllAssignedItems _this;
		removeUniform _this;
		removeVest _this;
		removeBackpack _this;
		removeHeadgear _this;
		removeGoggles _this;

		comment "Add containers";
		_this forceAddUniform "U_Marshal";
		for "_i" from 1 to 5 do {_this addItemToUniform "6Rnd_45ACP_Cylinder";};
		_this addBackpack "B_AssaultPack_cbr";
		_this addHeadgear "H_Bandanna_gry";

		comment "Add weapons";
		_this addWeapon "hgun_Pistol_heavy_02_F";

		comment "Add items";
		_this linkItem "ItemMap";
		_this linkItem "ItemCompass";
		_this linkItem "ItemWatch";

		comment "Set identity";
		[_this,"Default","male01gre"] call BIS_fnc_setIdentity;
	}
];