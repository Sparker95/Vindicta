removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

//	==== Head Gear ====
this addHeadgear "gm_ge_headgear_m62_net";

//	==== Uniform ====
this forceAddUniform "gm_ge_army_uniform_soldier_80_ols";
this addItemToUniform "FirstAidKit";
this addItemToUniform "gm_ge_facewear_m65";
this addItemToUniform "gm_ge_headgear_beret_grn_infantry";

//	==== Vest ====
this addVest "gm_ge_army_vest_80_rifleman";

//	==== Backpack ====

//	==== Weapons ====

//	==== Misc Items ====
this linkItem "ItemMap";
this linkItem "gm_ge_army_conat2";
this linkItem "gm_watch_kosei_80";