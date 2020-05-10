removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

this addHeadgear "rhs_zsh7a_mike_green";
this forceaddUniform "rhsgref_uniform_para_ttsko_urban";
this addVest "rhs_vest_pistol_holster";

this addWeapon "rhsusf_weap_glock17g4";
this addHandgunItem "rhsusf_mag_17Rnd_9x19_FMJ";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToUniform "rhsusf_mag_17Rnd_9x19_FMJ";};

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";

