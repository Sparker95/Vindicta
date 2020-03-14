removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

this forceAddUniform selectRandom [
	"U_LIB_CIV_Citizen_1",
	"U_LIB_CIV_Citizen_2",
	"U_LIB_CIV_Citizen_3",
	"U_LIB_CIV_Citizen_4",
	"U_LIB_CIV_Citizen_5",
	"U_LIB_CIV_Citizen_6",
	"U_LIB_CIV_Citizen_7",
	"U_LIB_CIV_Citizen_8",
	"U_LIB_CIV_Functionary_1",
	"U_LIB_CIV_Functionary_2",
	"U_LIB_CIV_Functionary_3",
	"U_LIB_CIV_Functionary_4",
	"U_GELIB_FRA_CitizenFF01",
	"U_GELIB_FRA_CitizenFF02",
	"U_GELIB_FRA_CitizenFF03",
	"U_GELIB_FRA_CitizenFF04",
	"U_GELIB_FRA_WoodlanderFF01",
	"U_GELIB_FRA_WoodlanderFF04",
	"U_GELIB_FRA_AssistantFF",
	"U_GELIB_FRA_FunctionaryFF01",
	"U_GELIB_FRA_FunctionaryFF02",
	"U_GELIB_FRA_VillagerFF01",
	"U_GELIB_FRA_VillagerFF02",
	"U_GELIB_FRA_Citizen01",
	"U_GELIB_FRA_Citizen02",
	"U_GELIB_FRA_Citizen03",
	"U_GELIB_FRA_Citizen04",
	"U_LIB_CIV_Rocker_1"
];

if(random 10 > 5) then { this linkItem "ItemWatch" };

[this, selectRandom gVanillaFaces, "ace_novoice"] call BIS_fnc_setIdentity;

this addBackpack selectRandom [
	"B_LIB_SOV_RA_Rucksack",
	"B_LIB_SOV_RA_Rucksack_Green",
	"B_LIB_UK_HSack",
	"B_LIB_UK_HSack_Blanco"
];

this linkItem "ItemMap";
this linkItem "LIB_GER_ItemCompass";
this linkItem "LIB_GER_ItemWatch";
