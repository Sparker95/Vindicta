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
_RandomHeadgear = selectRandom ["BWA3_CrewmanKSK_Tropen"];
this addHeadgear _RandomHeadgear;
_RandomGoggles = selectRandom ["rhsusf_shemagh2_gogg_od","RHSUSF_Shemagh2_Gogg_Grn","rhs_googles_black","rhs_ess_black"];
this addGoggles _RandomGoggles;
this forceAddUniform "BWA3_Uniform_Tropen";

this addWeapon "BWA3_G38_tan";
this addPrimaryWeaponItem "BWA3_muzzle_snds_Rotex_IIIC";
this addPrimaryWeaponItem "BWA3_acc_VarioRay_irlaser";
this addPrimaryWeaponItem "BWA3_optic_ZO4x30i";
this addPrimaryWeaponItem "BWA3_30Rnd_556x45_G36_Tracer_Dim";
this addWeapon "rhs_weap_M136";
this addWeapon "BWA3_P8";
this addHandgunItem "BWA3_acc_LLM01_irlaser";
this addHandgunItem "BWA3_15Rnd_9x19_P8";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToUniform "BWA3_15Rnd_9x19_P8";};
for "_i" from 1 to 4 do {this addItemToVest "ACE_M84";};
this addItemToVest "I_IR_Grenade";
for "_i" from 1 to 6 do {this addItemToVest "BWA3_30Rnd_556x45_G36_Tracer_Dim";};
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "rhsusf_ANPVS_15";
