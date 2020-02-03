removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

this addWeapon "arifle_SPAR_01_blk_F";
this addPrimaryWeaponItem "acc_flashlight";
this addPrimaryWeaponItem "optic_Hamr";
this addPrimaryWeaponItem "30Rnd_556x45_Stanag";
this addWeapon "hgun_Rook40_F";
this addHandgunItem "16Rnd_9x21_Mag";

this forceAddUniform "spu_uniform_02b";
this addVest "spu_spcs_black";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 4 do {this addItemToVest "30Rnd_556x45_Stanag";};
this addItemToVest "SmokeShell";
this addItemToVest "16Rnd_9x21_Mag";
this addHeadgear "H_Beret_gen_F";
_RandomGoggles = selectRandom ["G_Shades_Red","G_Shades_Green",""];
this addGoggles _RandomGoggles;

this linkItem "ItemWatch";
this linkItem "ItemRadio";

[this,"spu_armpatch"] call BIS_fnc_setUnitInsignia;