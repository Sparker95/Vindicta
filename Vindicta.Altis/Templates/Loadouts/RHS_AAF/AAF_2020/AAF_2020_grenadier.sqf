removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomVest = selectRandom ["FGN_AAF_CIRAS_GL","FGN_AAF_CIRAS_GL_Belt","FGN_AAF_CIRAS_GL_Belt_CamB"];
this addVest _RandomVest;
_RandomHeadgear = selectRandom ["FGN_AAF_PASGT","FGN_AAF_PASGT_ESS","FGN_AAF_PASGT_ESS_2","FGN_AAF_PASGT_Type07","FGN_AAF_PASGT_Type07_ESS","FGN_AAF_PASGT_Type07_ESS_2"];
this addHeadgear _RandomHeadgear;
_RandomGoggles = selectRandom ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag","rhs_scarf","","",""];
this forceAddUniform "FGN_AAF_M10_Type07_Summer";
this addBackpack "B_LegStrapBag_coyote_F";

this addWeapon "rhs_weap_m21a_pbg40";
this addPrimaryWeaponItem "rhsgref_30rnd_556x45_m21";
this addPrimaryWeaponItem "rhs_VOG25";

this addItemToUniform "FirstAidKit";
this addItemToUniform "FGN_AAF_PatrolCap_Type07";
for "_i" from 1 to 6 do {this addItemToVest "rhsgref_30rnd_556x45_m21";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_grenade_mkii_mag";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_VG40MD";};
this addItemToBackpack "rhs_GRD40_Green";
this addItemToBackpack "rhs_GRD40_Red";
for "_i" from 1 to 6 do {this addItemToBackpack "rhs_VOG25";};
this addItemToBackpack "rhs_VG40OP_red";
for "_i" from 1 to 4 do {this addItemToBackpack "rhs_VG40OP_white";};
this addItemToBackpack "rhs_VG40OP_green";
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_VOG25P";};

this linkItem "ItemWatch";
this linkItem "ItemRadio";