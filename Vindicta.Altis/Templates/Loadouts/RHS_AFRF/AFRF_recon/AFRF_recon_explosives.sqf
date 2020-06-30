removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["rhs_6b47_ess","rhs_6b47","rhs_6b47_bala","rhs_6b47_ess_bala"];
this addHeadgear _RandomHeadgear;
this forceAddUniform "rhs_uniform_gorka_r_g";
this addVest "rhs_6b13_EMR_6sh92";
this addBackpack "rhs_sidor";

this addWeapon "rhs_weap_asval_grip";
this addPrimaryWeaponItem "rhs_acc_perst1ik_ris";
this addPrimaryWeaponItem "rhs_20rnd_9x39mm_SP5";
this addPrimaryWeaponItem "rhsusf_acc_kac_grip";
this addWeapon "rhs_weap_rshg2";
this addWeapon "rhs_weap_pya";
this addHandgunItem "rhs_mag_9x19_17";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToUniform "rhs_mag_9x19_17";};
this addItemToUniform "O_R_IR_Grenade";
this addItemToVest "rhs_mag_rdg2_black";
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_fakel";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_fakels";};
this addItemToVest "rhs_mag_rgn";
this addItemToVest "rhs_mag_rgo";
for "_i" from 1 to 2 do {this addItemToVest "rhs_20rnd_9x39mm_SP6";};
for "_i" from 1 to 4 do {this addItemToVest "rhs_20rnd_9x39mm_SP5";};
for "_i" from 1 to 2 do {this addItemToBackpack "DemoCharge_Remote_Mag";};
this addItemToBackpack "SatchelCharge_Remote_Mag";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "rhs_1PN138";