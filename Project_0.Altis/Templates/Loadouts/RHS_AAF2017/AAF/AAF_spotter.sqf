
removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

this forceAddUniform "FGN_AAF_M93_Lizard";
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToUniform "rhs_mag_762x25_8";};
this addVest "FGN_AAF_M99Vest_Lizard_Rifleman_Radio";
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_rgd5";};
for "_i" from 1 to 5 do {this addItemToVest "rhs_30Rnd_545x39_7N6M_plum_AK";};
this addBackpack "rhs_sidor";
this addItemToBackpack "SatchelCharge_Remote_Mag";
for "_i" from 1 to 2 do {this addItemToBackpack "APERSTripMine_Wire_Mag";};
_RandomGoggles = ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag","rhs_scarf","","","",""] call BIS_fnc_selectRandom;  
  

this addGoggles _RandomGoggles;
_RandomHeadgear = ["FGN_AAF_Boonie_Lizard","H_Bandanna_khk_hs","H_Bandanna_khk"] call BIS_fnc_selectRandom;  
  

this addHeadgear _RandomHeadgear;

this addWeapon "rhs_weap_aks74un";
this addPrimaryWeaponItem "rhs_acc_pgs64_74un";
this addWeapon "rhs_weap_tt33";
this addWeapon "rhssaf_zrak_rd7j";

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";






