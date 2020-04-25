removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

//	==== Head Gear ====
this addHeadgear "CUP_H_C_Policecap_01";

//	==== Uniform ====
this forceAddUniform "CUP_U_C_Policeman_01";
this addItemToUniform "FirstAidKit";

//	==== Vest ====
this addVest "CUP_V_C_Police_Holster";

//	==== Weapons ====
private _gunAndAmmo = [
	["CUP_smg_bizon", "CUP_64Rnd_9x19_Bizon_M"],						0.5,
	["CUP_arifle_AKM_top_rail", "CUP_30Rnd_762x39_AK47_bakelite_M"],	0.3,
	["CUP_sgun_Saiga12K_top_rail", "CUP_8Rnd_B_Saiga12_74Slug_M"],		0.2
];

(selectRandomWeighted _gunAndAmmo) params ["_gun", "_ammo"];
this addWeapon _gun;
this addPrimaryWeaponItem _ammo;
for "_i" from 1 to 2 do {this addItemToVest _ammo;};

this addWeapon "CUP_hgun_Makarov";
this addHandgunItem "CUP_8Rnd_9x18_Makarov_M";
for "_i" from 1 to 4 do {this addItemToVest "CUP_8Rnd_9x18_Makarov_M";};

//	==== Misc Items ====
this linkItem "ItemMap"; 		// Map
this linkItem "ItemWatch"; 		// Watch
this linkItem "ItemCompass"; 	// Compass