removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

this forceAddUniform "mnaf_sweater";
this addVest "rhs_vest_pistol_holster";
this addHeadgear "rhsusf_hgu56p_visor_tan";

this addWeapon "rhsusf_weap_m1911a1";
this addHandgunItem "rhsusf_mag_7x45acp_MHP";

this addItemToUniform "FirstAidKit";
this addItemToUniform "rhs_grenade_anm8_mag";
for "_i" from 1 to 3 do {this addItemToVest "rhsusf_mag_7x45acp_MHP";};
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";