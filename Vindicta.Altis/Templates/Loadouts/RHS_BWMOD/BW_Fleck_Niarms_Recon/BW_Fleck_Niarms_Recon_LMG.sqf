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
_RandomHeadgear = selectRandom ["BWA3_CrewmanKSK_Fleck"];
this addHeadgear _RandomHeadgear;
_RandomGoggles = selectRandom ["rhsusf_shemagh2_gogg_od","RHSUSF_Shemagh2_Gogg_Grn","rhs_googles_black","rhs_ess_black"];
this addGoggles _RandomGoggles;
this forceAddUniform "BWA3_Uniform_Fleck";
this addBackpack "BWA3_AssaultPack_Fleck";

this addWeapon "BWA3_MG4";
this addPrimaryWeaponItem "BWA3_acc_VarioRay_irlaser_black";
this addPrimaryWeaponItem "rhsusf_acc_g33_xps3";
this addPrimaryWeaponItem "BWA3_200Rnd_556x45_Tracer";
this addWeapon "BWA3_P8";
this addHandgunItem "BWA3_acc_LLM01_irlaser";
this addHandgunItem "BWA3_15Rnd_9x19_P8";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToUniform "BWA3_15Rnd_9x19_P8";};
for "_i" from 1 to 2 do {this addItemToVest "ACE_M84";};
this addItemToVest "I_IR_Grenade";
for "_i" from 1 to 2 do {this addItemToVest "BWA3_200Rnd_556x45_Tracer";};
for "_i" from 1 to 2 do {this addItemToBackpack "BWA3_200Rnd_556x45_Tracer";};
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "rhsusf_ANPVS_15";
