removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

this forceaddUniform "U_I_pilotCoveralls";
this addVest "rhs_vest_pistol_holster";
this addHeadgear "rhs_zsh7a_alt";

this addWeapon "rhs_weap_makarov_pm";
this addHandgunItem "rhs_mag_9x18_8_57N181S";

this addItemToUniform "FirstAidKit";
this addItemToVest "rhs_mag_rdg2_black";
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_9x18_8_57N181S";};
this addHeadgear "rhs_zsh7a_alt";
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";