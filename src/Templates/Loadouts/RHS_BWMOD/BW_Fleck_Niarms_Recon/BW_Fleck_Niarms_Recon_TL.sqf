removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomVest = selectRandom ["BWA3_Vest_JPC_Radioman_Fleck","BWA3_Vest_JPC_Rifleman_Fleck","BWA3_Vest_JPC_Leader_Fleck"];
this addVest _RandomVest;
_RandomHeadgear = selectRandom ["rhsusf_bowman_cap","H_Cap_oli_hs","BWA3_Booniehat_Fleck"];
this addHeadgear _RandomHeadgear;
_RandomGoggles = selectRandom ["rhsusf_shemagh2_gogg_od","RHSUSF_Shemagh2_Gogg_Grn","rhs_googles_black","rhs_ess_black"];
this addGoggles _RandomGoggles;
this forceAddUniform "BWA3_Uniform_Fleck";
this addBackpack "BWA3_AssaultPack_Fleck";

this addWeapon "hlc_rifle_416D165";
this addPrimaryWeaponItem "BWA3_muzzle_snds_Rotex_IIIC";
this addPrimaryWeaponItem "BWA3_acc_VarioRay_irlaser";
this addPrimaryWeaponItem "BWA3_optic_ZO4x30i_MicroT2";
this addPrimaryWeaponItem "hlc_30rnd_556x45_MDim_PMAG";
this addWeapon "BWA3_P8";
this addHandgunItem "BWA3_acc_LLM01_irlaser";
this addHandgunItem "BWA3_15Rnd_9x19_P8";
this addWeapon "BWA3_Vector";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToUniform "BWA3_15Rnd_9x19_P8";};
for "_i" from 1 to 2 do {this addItemToVest "BWA3_DM51A1";};
for "_i" from 1 to 2 do {this addItemToVest "BWA3_DM25";};
this addItemToVest "I_IR_Grenade";
for "_i" from 1 to 6 do {this addItemToVest "hlc_30rnd_556x45_MDim_PMAG";};
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "rhsusf_ANPVS_15";
this linkItem "ItemGPS"
