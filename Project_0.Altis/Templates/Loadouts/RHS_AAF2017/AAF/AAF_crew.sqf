

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
this addVest "rhs_vest_pistol_holster";
for "_i" from 1 to 3 do {this addItemToVest "rhsgref_20rnd_765x17_vz61";};
_RandomHeadgear = ["rhs_tsh4","rhs_tsh4_bala","rhs_tsh4_ess","rhs_tsh4_ess_bala"] call BIS_fnc_selectRandom;  
  

this addHeadgear _RandomHeadgear;
_RandomGoggles = ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag","","","",""] call BIS_fnc_selectRandom;  
  

this addGoggles _RandomGoggles;

this addWeapon "rhs_weap_savz61";
this addWeapon "rhssaf_zrak_rd7j";

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemRadio";






