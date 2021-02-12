comment "Exported from Arsenal by SomethingSimple";

comment "[!] UNIT MUST BE LOCAL [!]";
if (!local this) exitWith {};

comment "Remove existing items";
removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

comment "Add weapons";
this addWeapon "rhs_weap_savz61";
this addPrimaryWeaponItem "rhsgref_20rnd_765x17_vz61";
this addWeapon "rhsusf_weap_glock17g4";
this addHandgunItem "rhsusf_mag_17Rnd_9x19_JHP";

comment "Add containers";
this forceAddUniform "U_B_GEN_Commander_F";
this addVest "V_TacVest_blk_POLICE";

comment "Add items to containers";
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToVest "rhsgref_20rnd_765x17_vz61";};
for "_i" from 1 to 7 do {this addItemToVest "rhsgref_10rnd_765x17_vz61";};
for "_i" from 1 to 3 do {this addItemToVest "rhsusf_mag_17Rnd_9x19_JHP";};
for "_i" from 1 to 2 do {this addItemToVest "Chemlight_blue";};
this addHeadgear "H_Beret_gen_F";

comment "Add items";
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";

comment "Set identity";
[this,"Default","male02gre"] call BIS_fnc_setIdentity;