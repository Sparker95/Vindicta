// ==== Remove items ====
removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

// ==== Identity ====
private _voice = [
	"male01engb",
	"male02engb",
	"male03engb",
	"male04engb",
	"male05engb"
];

[this, selectRandom gVanillaFaces, _voice] call BIS_fnc_setIdentity;

// ==== Uniform ====
this forceAddUniform "UK3CB_BAF_U_CombatUniform_MTP";

//	==== Armor ====
private _vests = [
	"UK3CB_BAF_V_Osprey_Rifleman_A",
	"UK3CB_BAF_V_Osprey_Rifleman_B",
	"UK3CB_BAF_V_Osprey_Rifleman_C",
	"UK3CB_BAF_V_Osprey_Rifleman_D",
	"UK3CB_BAF_V_Osprey_Rifleman_E"
];

this addVest selectRandom _vests;

//	==== Backpack ====
private _backpack = [
	"UK3CB_BAF_B_Bergen_MTP_Rifleman_L_B",
	"UK3CB_BAF_B_Bergen_MTP_Rifleman_L_C",
	"UK3CB_BAF_B_Bergen_MTP_Rifleman_L_D"
];

this addBackpack selectRandom _backpack;

// ==== BackPack Contents ====
for "_i" from 1 to 3 do {this addItemToBackpack "NLAW_F";};

// ==== Weapon ====
this addWeapon "UK3CB_BAF_L22";
this addPrimaryWeaponItem "RKSL_optic_LDS";
this addPrimaryWeaponItem "UK3CB_BAF_556_30Rnd";
for "_i" from 1 to 6 do {this addItemToVest "UK3CB_BAF_556_30Rnd";};

// ==== Helmets ====
private _helmet = [
	"UK3CB_BAF_H_Mk7_Camo_A",
	"UK3CB_BAF_H_Mk7_Camo_B",
	"UK3CB_BAF_H_Mk7_Camo_C",
	"UK3CB_BAF_H_Mk7_Camo_D",
	"UK3CB_BAF_H_Mk7_Camo_E",
	"UK3CB_BAF_H_Mk7_Camo_F"
];

this addHeadgear selectRandom _helmet;

// ==== Goggles (Glasses and stuff) ====
if (random 10 < 4) then {
private _goggles = [
	"UK3CB_BAF_G_Tactical_Black",
	"UK3CB_BAF_G_Tactical_Clear",
	"UK3CB_BAF_G_Tactical_Orange",
	"UK3CB_BAF_G_Tactical_Grey",
	"UK3CB_BAF_G_Tactical_Yellow"
];
this addGoggles selectRandom _goggles;
};

// Miscellaneous items
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";