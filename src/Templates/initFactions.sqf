// !! Currently only called on server !!
// Initialize factions
// This variable is necessary for other factions to initialize!
["Templates\Factions\default.sqf"]	call t_fnc_initializeTemplateFromFile;

// !! Factions will be listed in UI in the same order as here !!

//todo: It's not needed to pass faction type any more

// Initialize factions from addons
#ifdef _SQF_VM
private _classes = [];
#else
private _classes = "isClass _x" configClasses (configFile >> "VinExternalFactions");
#endif
{
    private _initFile = getText (_x >> "file");
    if (_initFile != "") then {
        diag_log format ["[Template] Initializing faction from addon: %1, path: %2", configName _x, _initFile];
        [_initFile, true]	call t_fnc_initializeTemplateFromFile;
    };
} forEach _classes;

// Military Factions
{
    [_x] call t_fnc_initializeTemplateFromFile;
} forEach [
    // Vanilla Arma 3 Factions
    "Templates\Factions\NATO.sqf",
    "Templates\Factions\AAF.sqf",
    "Templates\Factions\CSAT.sqf",
    // Vanilla Arma 3 Factions (Mixed)
    "Templates\Factions\NATOAAF.sqf",
    "Templates\Factions\NATOCSAT.sqf",
    "Templates\Factions\AAFCSAT.sqf",
    // Apex DLC Factions
    "Templates\Factions\NATOPacific.sqf",
    "Templates\Factions\CSATPacific.sqf",
    // Contact DLC Factions
    "Templates\Factions\NATOWoodland.sqf",
    "Templates\Factions\LDF.sqf",
    // Spearhead 1944 DLC Factions
    "Templates\Factions\SPE_Wehrmacht.sqf",
    "Templates\Factions\SPE_US_Army.sqf",
    // Spearhead 1944 DLC + Iron Front Factions
    "Templates\Factions\SPE_IFA3_Wehrmacht.sqf",
    "Templates\Factions\SPE_IFA3_US_Army.sqf",
    // S.O.G. Prairie Fire DLC Factions
    "Templates\Factions\VN_US_Army.sqf",
    "Templates\Factions\VN_ARVN.sqf",
    //"Templates\Factions\VN_NVA.sqf",
    //"Templates\Factions\VN_VC.sqf",
    // Global Mobilization - Cold War Germany DLC Factions
    "Templates\Factions\GM_WestGer.sqf",
    "Templates\Factions\GM_EastGer.sqf",
    // RHS Factions
    "Templates\Factions\RHS_USAF.sqf",
    "Templates\Factions\RHS_USAF_UCP.sqf",
    "Templates\Factions\RHS_USMC_W.sqf",
    "Templates\Factions\RHS_USMC_D.sqf",
    "Templates\Factions\RHS_AFRF.sqf",
    "Templates\Factions\RHS_CDF.sqf",
    "Templates\Factions\RHS_HIDF.sqf",
    "Templates\Factions\RHS_LDF.sqf",
    // RHS + AAF 2017 Factions
    "Templates\Factions\RHS_AAF_2010.sqf",
    "Templates\Factions\RHS_AAF_2020.sqf",
    "Templates\Factions\RHS_LAF.sqf",
    // 3CB Factions
    "Templates\Factions\3CB_TNA_B.sqf",
    "Templates\Factions\3CB_TNA_O.sqf",
    // CUP Factions
	"Templates\Factions\CUP_USMC.sqf",
    "Templates\Factions\CUP_AFRF.sqf",
    "Templates\Factions\CUP_CDF.sqf",
    "Templates\Factions\CUP_TKA.sqf",
    // BWMod Factions
    "Templates\Factions\RHS_BWMOD_BW_Fleck.sqf",
    "Templates\Factions\RHS_BWMOD_BW_Trop.sqf",
    "Templates\Factions\RHS_BWMOD_Niarms_BW_Fleck.sqf",
    "Templates\Factions\RHS_BWMOD_Niarms_BW_Trop.sqf",
    // Other Factions
    "Templates\Factions\Russians2035.sqf",
    "Templates\Factions\DAF_Tan.sqf",
    "Templates\Factions\BWA.sqf"
];


// Civilian Factions
{
    [_x] call t_fnc_initializeTemplateFromFile;
} forEach [
    // Vanilla Arma 3 Factions
    "Templates\Factions\CIVILIAN.sqf",
    // Spearhead 1944 DLC Factions
    "Templates\Factions\SPE_CIVILIAN.sqf",
    // Spearhead 1944 DLC + Iron Front Mod Factions
    "Templates\Factions\SPE_IFA3_CIVILIAN.sqf",
    // S.O.G. Prairie Fire DLC Factions
    "Templates\Factions\VN_CIVILIAN.sqf",
    // Global Mobilization - Cold War Germany DLC Factions
    "Templates\Factions\GM_CIVILIAN.sqf",
    // RHS Factions
    "Templates\Factions\CIVILIAN_RHS.sqf",
    // 3CB Factions
    "Templates\Factions\3CB_CCIVS.sqf",
    "Templates\Factions\3CB_TCIV.sqf",
    // CUP Factions
    "Templates\Factions\CUP_RUS_CIVILIAN.sqf",
    "Templates\Factions\CUP_TKA_CIVILIAN.sqf",
    // Other Factions
    "Templates\Factions\GUERRILLA.sqf"
];

// Police factions
{
    [_x] call t_fnc_initializeTemplateFromFile;
} forEach [
    // Vanilla Arma 3 Factions
    "Templates\Factions\POLICE.sqf",
    // Apex DLC + Laws of War DLC + Contact DLC Factions
    "Templates\Factions\POLICE_DLC.sqf",
    // Spearhead 1944 DLC Factions
    "Templates\Factions\SPE_Wehrmacht_police.sqf",
    "Templates\Factions\SPE_US_Army_police.sqf",
    // Spearhead 1944 DLC + Iron Front Factions
    "Templates\Factions\SPE_IFA3_Wehrmacht_police.sqf",
    "Templates\Factions\SPE_IFA3_US_Army_police.sqf",
    // S.O.G. Prairie Fire DLC Factions
    "Templates\Factions\VN_US_Army_police.sqf",
    "Templates\Factions\VN_ARVN_police.sqf",
    //"Templates\Factions\VN_VC_police.sqf",
    // Global Mobilization - Cold War Germany DLC Factions
    "Templates\Factions\GM_WestGer_Police.sqf",
    "Templates\Factions\GM_EastGer_Police.sqf",
    // RHS Factions
    "Templates\Factions\POLICE_RHS.sqf",
    "Templates\Factions\RHS_LDF_ranger.sqf",
    // RHS + AAF 2017 Factions
    "Templates\Factions\RHS_AAF_police.sqf",
    // 3CB Factions
    "Templates\Factions\3CB_TPD.sqf",
    "Templates\Factions\3CB_TPD_O.sqf",
    "Templates\Factions\3CB_CPD.sqf",
    // CUP Factions
    "Templates\Factions\CUP_RUS_Police.sqf",
    // Expansion Mod - Gendarmerie Factions
    "Templates\Factions\GEXP_Police.sqf",
    // Expansion Mod - Police Factions
    "Templates\Factions\Expansion_Police.sqf",
    // GSG9 Factions
    "Templates\Factions\GSG9.sqf",
    // Other Factions
    "Templates\Factions\DSI.sqf",
    "Templates\Factions\AT.sqf"
];