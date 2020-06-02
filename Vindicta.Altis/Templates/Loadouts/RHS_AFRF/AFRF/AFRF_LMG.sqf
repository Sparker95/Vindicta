removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["rhs_fieldcap_digi","rhs_6b27m_digi","rhs_6b27m_digi_bala","rhs_6b27m_digi_ess","rhs_6b27m_digi_ess_bala","rhs_6b27m_green","rhs_6b27m_green_bala","rhs_6b27m_green_ess","rhs_6b27m_green_ess_bala"];
this addHeadgear _RandomHeadgear;
this addVest "rhs_6b23_digi";
this forceaddUniform "rhs_uniform_emr_patchless";
this addBackpack "rhs_assault_umbts";

this addWeapon "rhs_weap_pkp";
this addPrimaryWeaponItem "rhs_100Rnd_762x54mmR_green";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToBackpack "rhs_100Rnd_762x54mmR_green";};
this linkItem "ItemWatch";