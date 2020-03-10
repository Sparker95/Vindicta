removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

this addHeadgear "H_Booniehat_dgtl";
_RandomVest = selectRandom ["V_SmershVest_01_F", "V_SmershVest_01_radio_F"];
this addVest _RandomVest;
_RandomUniform = selectRandom ["U_I_CombatUniform", "U_I_CombatUniform_shortsleeve"];
this forceAddUniform _RandomUniform;
this addVest _RandomVest;

this addWeapon "srifle_DMR_04_Tan_F";
this addPrimaryWeaponItem "muzzle_snds_m_khk_F";
this addPrimaryWeaponItem "ACE_acc_pointer_green";
this addPrimaryWeaponItem "optic_MRCO";
this addPrimaryWeaponItem "10Rnd_127x54_Mag";
this addPrimaryWeaponItem "bipod_03_F_oli";
this addWeapon "hgun_ACPC2_F";
this addHandgunItem "muzzle_snds_acp";
this addHandgunItem "acc_flashlight_pistol";
this addHandgunItem "9Rnd_45ACP_Mag";


for "_i" from 1 to 2 do {this addItemToUniform "FirstAidKit";};
for "_i" from 1 to 5 do {this addItemToVest "10Rnd_127x54_Mag";};
for "_i" from 1 to 3 do {this addItemToVest "9Rnd_45ACP_Mag";};
for "_i" from 1 to 2 do {this addItemToVest "SmokeShell";};
for "_i" from 1 to 2 do {this addItemToVest "HandGrenade";};
for "_i" from 1 to 2 do {this addItemToVest "MiniGrenade";};
for "_i" from 1 to 2 do {this addItemToUniform "Chemlight_green";};


this linkItem "ItemMap";
this linkItem "ItemGPS";
this linkItem "ItemRadio";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "NVGoggles_INDEP";
this linkItem "Rangefinder";
