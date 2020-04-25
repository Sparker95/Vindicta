removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

[this, selectRandom gVanillaFaces, "ace_novoice"] call BIS_fnc_setIdentity;

private _uniforms = [
	"U_C_Poloshirt_blue",
	"U_C_Poloshirt_burgundy",
	"U_C_Poloshirt_redwhite",
	"U_C_Poloshirt_salmon",
	"U_C_Poloshirt_stripped",
	"U_C_Poloshirt_tricolour",
	"U_Marshal",
	"U_I_C_Soldier_Bandit_5_F",
	"U_I_C_Soldier_Bandit_3_F",
	"U_C_Man_casual_1_F",
	"U_C_Man_casual_2_F",
	"U_C_Man_casual_3_F",
	"U_C_man_sport_2_F",
	"U_C_Man_casual_6_F",
	"U_C_Man_casual_4_F",
	"U_C_Man_casual_5_F",
	"U_C_Uniform_Farmer_01_F",
	"U_C_E_LooterJacket_01_F",
	"U_I_L_Uniform_01_tshirt_black_F",
	"U_I_L_Uniform_01_tshirt_skull_F",
	"U_I_L_Uniform_01_tshirt_sport_F",
	"U_C_Uniform_Scientist_01_formal_F",
	"U_C_Uniform_Scientist_01_F",
	"U_C_Uniform_Scientist_02_formal_F",
	"U_O_R_Gorka_01_black_F",
	"U_C_Mechanic_01_F"
];

this forceAddUniform selectRandom _uniforms;

this addBackpack selectRandom [
	"B_AssaultPack_blk",
	"B_AssaultPack_cbr",
	"B_AssaultPack_rgr",
	"B_AssaultPack_khk",
	"B_Messenger_Black_F",
	"B_Messenger_Coyote_F",
	"B_Messenger_Gray_F",
	"B_Messenger_Olive_F"
];

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
