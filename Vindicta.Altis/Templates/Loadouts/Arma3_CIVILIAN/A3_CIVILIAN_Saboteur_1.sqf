removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

this forceAddUniform "U_C_Poloshirt_salmon";
this addBackpack "B_AssaultPack_blk";
this addHeadgear "H_Bandanna_gry";

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";

[this,"GreekHead_A3_09","male02gre"] call BIS_fnc_setIdentity;
