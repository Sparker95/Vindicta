removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["rhs_tsh4","rhs_tsh4_bala","rhs_tsh4_ess","rhs_tsh4_ess_bala"];
this addHeadgear _RandomHeadgear;
this forceaddUniform "rhsgref_uniform_para_ttsko_urban";
this addVest "rhs_vydra_3m";

this addWeapon "rhs_weap_savz61";
this addPrimaryWeaponItem "rhsgref_20rnd_765x17_vz61";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 4 do {this addItemToVest "rhsgref_20rnd_765x17_vz61";};

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
