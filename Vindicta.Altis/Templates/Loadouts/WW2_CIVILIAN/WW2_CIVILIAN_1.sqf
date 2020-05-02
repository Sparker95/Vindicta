removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

//===Headgear===
if (random 10 < 3) then {
	private _headgear = [
		"H_Hat_blue",
		"H_Hat_brown",
		"H_Hat_checker",
		"H_Hat_grey",
		"H_Hat_tan",
		"H_StrawHat",
		"H_StrawHat_dark",
		"H_LIB_CIV_Villager_Cap_1",
		"H_LIB_CIV_Villager_Cap_2",
		"H_LIB_CIV_Villager_Cap_3",
		"H_LIB_CIV_Villager_Cap_4",
		"H_LIB_CIV_Worker_Cap_1",
		"H_LIB_CIV_Worker_Cap_2",
		"H_LIB_CIV_Worker_Cap_3",
		"H_LIB_CIV_Worker_Cap_4",
		"GEH_Beret_blue",
		"GEH_Beret_blk",
		"H_Hat_Safari_olive_F",
		"H_Hat_Safari_sand_F"
	];

	this addHeadgear selectRandom _headgear;
};

//===Vest===
if (random 10 < 3) then {
	private _Vest = [
		"V_LIB_SOV_RA_Belt"
	];

	this addVest selectRandom _Vest;
};

//===Facewear===
if (random 10 < 3) then {
	private _Facewear = [
		"G_GEHeadBandage_Bloody",
		"G_GEHeadBandage_Clean",
		"G_GEHeadBandage_Stained",
		"G_LIB_Dienst_Brille",
		"G_LIB_Dienst_Brille2",
		"G_LIB_GER_Gloves4",
		"G_LIB_GER_Gloves2",
		"G_LIB_GER_Gloves1",
		"G_LIB_GER_Gloves3",
		"G_LIB_Watch2",
		"G_LIB_Watch1"
	];

	this addGoggles selectRandom _Facewear;
};

//===Uniform===
this forceAddUniform selectRandom [
		"U_LIB_CIV_Assistant",
		"U_LIB_CIV_Assistant_2",
		"U_LIB_CIV_Citizen_1",
		"U_LIB_CIV_Citizen_2",
		"U_LIB_CIV_Citizen_3",
		"U_LIB_CIV_Citizen_4",
		"U_LIB_CIV_Citizen_5",
		"U_LIB_CIV_Citizen_6",
		"U_LIB_CIV_Citizen_7",
		"U_LIB_CIV_Citizen_8",
		"U_LIB_CIV_Doctor",
		"U_LIB_CIV_Priest",
		"U_LIB_CIV_Rocker_1",
		"U_LIB_CIV_Schoolteacher",
		"U_LIB_CIV_Schoolteacher_2",
		"U_LIB_CIV_Villager_1",
		"U_LIB_CIV_Villager_2",
		"U_LIB_CIV_Villager_3",
		"U_LIB_CIV_Villager_4",
		"U_LIB_CIV_Woodlander_1",
		"U_LIB_CIV_Woodlander_2",
		"U_LIB_CIV_Woodlander_3",
		"U_LIB_CIV_Woodlander_4",
		"U_LIB_CIV_Worker_1",
		"U_LIB_CIV_Worker_2",
		"U_LIB_CIV_Worker_3",
		"U_LIB_CIV_Worker_4",
		"U_LIB_CIV_Functionary_1",
		"U_LIB_CIV_Functionary_2",
		"U_LIB_CIV_Functionary_3",
		"U_LIB_CIV_Functionary_4"
];

if(random 10 > 5) then { this linkItem "ItemWatch" };

[this, selectRandom gVanillaFaces, "ace_novoice"] call BIS_fnc_setIdentity;

this addItemToUniform "FirstAidKit";