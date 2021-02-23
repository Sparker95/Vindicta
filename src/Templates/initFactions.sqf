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


// Military factions
{
    [_x] call t_fnc_initializeTemplateFromFile;
} forEach [
    "Templates\Factions\AAF.sqf",
    "Templates\Factions\LDF.sqf",
    "Templates\Factions\NATO.sqf", 	
    "Templates\Factions\NATOPacific.sqf", 	
    "Templates\Factions\NATOWoodland.sqf",
    "Templates\Factions\CSAT.sqf", 
    "Templates\Factions\CSATPacific.sqf",	
    "Templates\Factions\RHS_AAF_2020.sqf",
    "Templates\Factions\RHS_AAF_2010.sqf",
    "Templates\Factions\RHS_LDF.sqf",
    "Templates\Factions\RHS_LAF.sqf", 	
    "Templates\Factions\RHS_HIDF.sqf", 
    "Templates\Factions\RHS_AFRF.sqf", 
    "Templates\Factions\RHS_USAF.sqf",
    "Templates\Factions\RHS_USAF_UCP.sqf", 
	"Templates\Factions\RHS_USMC_W.sqf", 
    "Templates\Factions\RHS_CDF.sqf",	
    "Templates\Factions\CUP_TKA.sqf", 	
    "Templates\Factions\CUP_AFRF.sqf", 
    "Templates\Factions\CUP_USMC.sqf", 
    "Templates\Factions\3CB_TNA_B.sqf", 				
    "Templates\Factions\3CB_TNA_O.sqf", 				
    "Templates\Factions\Russians2035.sqf", 			
    "Templates\Factions\DAF_Tan.sqf", 					
    "Templates\Factions\BWA.sqf",		
    "Templates\Factions\GM_WestGer.sqf",
    "Templates\Factions\GM_EastGer.sqf",
    "Templates\Factions\RHS_BWMOD_BW_Fleck.sqf",
    "Templates\Factions\RHS_BWMOD_BW_Trop.sqf",
    "Templates\Factions\RHS_BWMOD_Niarms_BW_Fleck.sqf",
    "Templates\Factions\RHS_BWMOD_Niarms_BW_Trop.sqf",
    "Templates\Factions\NATOAAF.sqf",
    "Templates\Factions\AAFCSAT.sqf",
    "Templates\Factions\NATOCSAT.sqf"
];


// Other factions
{
    [_x] call t_fnc_initializeTemplateFromFile;
} forEach [
    "Templates\Factions\CIVILIAN.sqf", 
    "Templates\Factions\CIVILIAN_RHS.sqf",
    "Templates\Factions\GM_CIVILIAN.sqf", 
    "Templates\Factions\CUP_RUS_CIVILIAN.sqf",
    "Templates\Factions\CUP_TKA_CIVILIAN.sqf",
    "Templates\Factions\3CB_CCIVS.sqf",
    "Templates\Factions\3CB_TCIV.sqf",
    "Templates\Factions\GUERRILLA.sqf"
];

// Police factions
{
    [_x] call t_fnc_initializeTemplateFromFile;
} forEach [
    "Templates\Factions\POLICE.sqf",
    "Templates\Factions\POLICE_DLC.sqf",
    "Templates\Factions\POLICE_RHS.sqf",
    "Templates\Factions\RHS_AAF_police.sqf",
    "Templates\Factions\RHS_LDF_ranger.sqf",
    "Templates\Factions\CUP_RUS_Police.sqf",
    "Templates\Factions\GSG9.sqf",
    "Templates\Factions\GM_WestGer_Police.sqf",
    "Templates\Factions\GM_EastGer_Police.sqf",
    "Templates\Factions\GEXP_Police.sqf",
    "Templates\Factions\3CB_TPD.sqf",
    "Templates\Factions\3CB_TPD_O.sqf",
    "Templates\Factions\3CB_CPD.sqf",
    "Templates\Factions\Expansion_Police.sqf",
    "Templates\Factions\DSI.sqf",
    "Templates\Factions\AT.sqf" 
];