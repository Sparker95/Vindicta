removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomVest = selectRandom ["BWA3_Vest_JPC_Radioman_Tropen","BWA3_Vest_JPC_Rifleman_Tropen","BWA3_Vest_JPC_Leader_Tropen"];
this addVest _RandomVest;
_RandomHeadgear = selectRandom ["rhsusf_bowman_cap","H_Cap_oli_hs","BWA3_Booniehat_Tropen"];
this addHeadgear _RandomHeadgear;
_RandomGoggles = selectRandom ["rhsusf_shemagh2_gogg_od","RHSUSF_Shemagh2_Gogg_Grn","rhs_googles_black","rhs_ess_black"];
this addGoggles _RandomGoggles;
this forceAddUniform "BWA3_Uniform_Tropen";

this addWeapon "BWA3_G28_Patrol";
this addPrimaryWeaponItem "BWA3_muzzle_snds_Rotex_IIA";
this addPrimaryWeaponItem "BWA3_optic_PMII_ShortdotCC";
this addPrimaryWeaponItem "BWA3_20Rnd_762x51_G28_AP";
this addWeapon "BWA3_P8";
this addHandgunItem "BWA3_acc_LLM01_irlaser";
this addHandgunItem "BWA3_15Rnd_9x19_P8";
this addWeapon "BWA3_Vector";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToUniform "ACE_M84";};
this addItemToVest "I_IR_Grenade";
for "_i" from 1 to 6 do {this addItemToVest "BWA3_20Rnd_762x51_G28_AP";};
for "_i" from 1 to 2 do {this addItemToVest "BWA3_15Rnd_9x19_P8";};
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "rhsusf_ANPVS_15";
