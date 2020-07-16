removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

this addHeadgear "H_MilCap_dgtl";
_RandomVest = selectRandom ["V_SmershVest_01_F", "V_SmershVest_01_radio_F"];
this addVest _RandomVest;
_RandomUniform = selectRandom ["U_I_CombatUniform", "U_I_CombatUniform_shortsleeve"];
this forceAddUniform _RandomUniform;
this addBackpack "B_FieldPack_green_F";

this addWeapon "arifle_SPAR_01_GL_snd_F";
this addPrimaryWeaponItem "muzzle_snds_m_khk_F";
this addPrimaryWeaponItem "ACE_acc_pointer_green";
this addPrimaryWeaponItem "optic_ERCO_khk_F";
this addPrimaryWeaponItem "30Rnd_556x45_Stanag_Sand";
this addWeapon "hgun_ACPC2_F";
this addHandgunItem "muzzle_snds_acp";
this addHandgunItem "acc_flashlight_pistol";
this addHandgunItem "9Rnd_45ACP_Mag";


for "_i" from 1 to 2 do {this addItemToUniform "FirstAidKit";};
for "_i" from 1 to 5 do {this addItemToVest "30Rnd_556x45_Stanag_Sand";};
for "_i" from 1 to 3 do {this addItemToVest "9Rnd_45ACP_Mag";};
for "_i" from 1 to 2 do {this addItemToVest "SmokeShell";};
for "_i" from 1 to 2 do {this addItemToVest "HandGrenade";};
for "_i" from 1 to 2 do {this addItemToVest "MiniGrenade";};
for "_i" from 1 to 2 do {this addItemToUniform "Chemlight_green";};
for "_i" from 1 to 4 do {this addItemToBackpack "1Rnd_Smoke_Grenade_shell";};
for "_i" from 1 to 6 do {this addItemToBackpack "1Rnd_HE_Grenade_shell";};


this linkItem "ItemMap";
this linkItem "ItemGPS";
this linkItem "ItemRadio";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "NVGoggles_INDEP";
this linkItem "Rangefinder";

[[],[],[],["U_I_CombatUniform_shortsleeve",[]],[],[],"","G_Tactical_Clear",[],["","","","","",""]]