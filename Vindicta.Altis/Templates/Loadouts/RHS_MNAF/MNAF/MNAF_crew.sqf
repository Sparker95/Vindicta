removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["rhsusf_cvc_green_alt_helmet","rhsusf_cvc_green_ess"];
this addHeadgear _RandomHeadgear;
this forceaddUniform "mnaf_tankersuit";
this addVest "malden_vest";

this addWeapon "SMG_02_F";
this addPrimaryWeaponItem "rhsusf_acc_M952V";
this addPrimaryWeaponItem "30Rnd_9x21_Mag_SMG_02";
this addWeapon "rhsusf_weap_m1911a1";
this addHandgunItem "rhsusf_mag_7x45acp_MHP";

this addItemToUniform "FirstAidKit";
this addItemToUniform "rhs_grenade_anm8_mag";
for "_i" from 1 to 3 do {this addItemToVest "rhsusf_mag_7x45acp_MHP";};
for "_i" from 1 to 4 do {this addItemToVest "30Rnd_9x21_Mag_SMG_02";};
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";

