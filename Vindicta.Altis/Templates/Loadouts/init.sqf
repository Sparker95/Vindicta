#include "common.hpp"

ADD_LOADOUT("superDude", "superDude.sqf")

gVanillaFaces = [
	"GreekHead_A3_01",
	"GreekHead_A3_02",
	"GreekHead_A3_03",
	"GreekHead_A3_04",
	"GreekHead_A3_05",
	"GreekHead_A3_06",
	"GreekHead_A3_07",
	"GreekHead_A3_08",
	"GreekHead_A3_09",
	"WhiteHead_01",
	"WhiteHead_02",
	"WhiteHead_03",
	"WhiteHead_04",
	"WhiteHead_05",
	"WhiteHead_06",
	"WhiteHead_07",
	"WhiteHead_08",
	"WhiteHead_09",
	"WhiteHead_10",
	"WhiteHead_11",
	"WhiteHead_12",
	"WhiteHead_13",
	"WhiteHead_14",
	"WhiteHead_15",
	"WhiteHead_16",
	"WhiteHead_17",
	"WhiteHead_18",
	"WhiteHead_19",
	"WhiteHead_20",
	"WhiteHead_21",
	"AfricanHead_01",
	"AfricanHead_02",
	"AfricanHead_03",
	"PersianHead_A3_01",
	"PersianHead_A3_02",
	"PersianHead_A3_03",
	"AsianHead_A3_01",
	"AsianHead_A3_02",
	"AsianHead_A3_03"
];

//Arma3_AAF
call compile preprocessFileLineNumbers "Templates\Loadouts\Arma3_AAF\AAF\init.sqf";
call compile preprocessFileLineNumbers "Templates\Loadouts\Arma3_AAF\AAF_Recon\init.sqf";
//Arma3_LDF
call compile preprocessFileLineNumbers "Templates\Loadouts\Arma3_LDF\LDF\init.sqf";
call compile preprocessFileLineNumbers "Templates\Loadouts\Arma3_LDF\LDF_Recon\init.sqf";
//Arma3_POLICE
call compile preprocessFileLineNumbers "Templates\Loadouts\Arma3_POLICE\Police\init.sqf";
//Arma3_CIVILIAN
call compile preprocessFileLineNumbers "Templates\Loadouts\Arma3_CIVILIAN\init.sqf";
//AAF_2010
call compile preprocessFileLineNumbers "Templates\Loadouts\RHS_AAF\AAF_2010\init.sqf";
call compile preprocessFileLineNumbers "Templates\Loadouts\RHS_AAF\AAF_2010_recon\init.sqf";
//AAF_2020
call compile preprocessFileLineNumbers "Templates\Loadouts\RHS_AAF\AAF_2020\init.sqf";
call compile preprocessFileLineNumbers "Templates\Loadouts\RHS_AAF\AAF_2020_recon\init.sqf";
//AAF_police
call compile preprocessFileLineNumbers "Templates\Loadouts\RHS_AAF\AAF_police\init.sqf";
//RHS_LDF
call compile preprocessFileLineNumbers "Templates\Loadouts\RHS_LDF\LDF\init.sqf";
call compile preprocessFileLineNumbers "Templates\Loadouts\RHS_LDF\LDF_Ranger\init.sqf";
call compile preprocessFileLineNumbers "Templates\Loadouts\RHS_LDF\LDF_Recon\init.sqf";
//RHS_HIDF
call compile preprocessFileLineNumbers "Templates\Loadouts\RHS_HIDF\HIDF\init.sqf";
call compile preprocessFileLineNumbers "Templates\Loadouts\RHS_HIDF\HIDF_Recon\init.sqf";
//RHS_MNAF
call compile preprocessFileLineNumbers "Templates\Loadouts\RHS_MNAF\MNAF\init.sqf";
call compile preprocessFileLineNumbers "Templates\Loadouts\RHS_MNAF\MNAF_Recon\init.sqf";
//RHS_LDF_NATO
call compile preprocessFileLineNumbers "Templates\Loadouts\RHS_LDF_NATO\LDF_NATO\init.sqf";
call compile preprocessFileLineNumbers "Templates\Loadouts\RHS_LDF_NATO\LDF_NATO_Police\init.sqf";
call compile preprocessFileLineNumbers "Templates\Loadouts\RHS_LDF_NATO\LDF_NATO_Recon\init.sqf";
//RHS_APD
call compile preprocessFileLineNumbers "Templates\Loadouts\RHS_APD\Police\init.sqf";
//WW2_Heer
call compile preprocessFileLineNumbers "Templates\Loadouts\WW2_Heer\Heer\init.sqf";
call compile preprocessFileLineNumbers "Templates\Loadouts\WW2_Heer\Heer_Recon\init.sqf";
call compile preprocessFileLineNumbers "Templates\Loadouts\WW2_Heer\Heer_Police\init.sqf";
//WW2_Sov
call compile preprocessFileLineNumbers "Templates\Loadouts\WW2_Sov\Red_Army\init.sqf";
call compile preprocessFileLineNumbers "Templates\Loadouts\WW2_Sov\Red_Army_Recon\init.sqf";
call compile preprocessFileLineNumbers "Templates\Loadouts\WW2_Sov\Red_Army_Police\init.sqf";
//WW2_UK
call compile preprocessFileLineNumbers "Templates\Loadouts\WW2_UK\UK\init.sqf";
call compile preprocessFileLineNumbers "Templates\Loadouts\WW2_UK\UK_Recon\init.sqf";
//WW2_UK
call compile preprocessFileLineNumbers "Templates\Loadouts\WW2_Civilian\init.sqf";
//GM_WestGer
call compile preprocessFileLineNumbers "Templates\Loadouts\GM_WestGer\WestGer\init.sqf";
call compile preprocessFileLineNumbers "Templates\Loadouts\GM_WestGer\WestGer_Police\init.sqf";
call compile preprocessFileLineNumbers "Templates\Loadouts\GM_WestGer\WestGer_Recon\init.sqf";
call compile preprocessFileLineNumbers "Templates\Loadouts\GM_CIVILIAN\init.sqf";
//BWMOD
call compile preprocessFileLineNumbers "Templates\Loadouts\RHS_BWMOD\BW_Fleck\init.sqf";
call compile preprocessFileLineNumbers "Templates\Loadouts\RHS_BWMOD\BW_Fleck_Recon\init.sqf";
call compile preprocessFileLineNumbers "Templates\Loadouts\RHS_BWMOD\BW_Trop\init.sqf";
call compile preprocessFileLineNumbers "Templates\Loadouts\RHS_BWMOD\BW_Trop_Recon\init.sqf";
//BWMOD with Niarms
call compile preprocessFileLineNumbers "Templates\Loadouts\RHS_BWMOD\BW_Fleck_Niarms\init.sqf";
call compile preprocessFileLineNumbers "Templates\Loadouts\RHS_BWMOD\BW_Fleck_Niarms_Recon\init.sqf";
call compile preprocessFileLineNumbers "Templates\Loadouts\RHS_BWMOD\BW_Trop_Niarms\init.sqf";
call compile preprocessFileLineNumbers "Templates\Loadouts\RHS_BWMOD\BW_Trop_Niarms_Recon\init.sqf";
// CUP
call compile preprocessFileLineNumbers "Templates\Loadouts\CUP_RUS_CIVILIAN\init.sqf";
call compile preprocessFileLineNumbers "Templates\Loadouts\CUP_TKA_CIVILIAN\init.sqf";
call compile preprocessFileLineNumbers "Templates\Loadouts\CUP_RUS_POLICE\init.sqf";
// Gendermarie Expansion
call compile preprocessFileLineNumbers "Templates\Loadouts\GEXP_POLICE\init.sqf";
// 3CB BAF
call compile preprocessFileLineNumbers "Templates\Loadouts\3CB_BAF\init.sqf";
// 3CB CCIVS
call compile preprocessFileLineNumbers "Templates\Loadouts\3CB_CCIVS\init.sqf";
// 3CB Takistan Civillians
call compile preprocessFileLineNumbers "Templates\Loadouts\3CB_TCIV\init.sqf";
