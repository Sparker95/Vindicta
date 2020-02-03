// !! Currently only called on server !!
// Initialize factions
// This variable is necessary for other factions to initialize!
["Templates\Factions\default.sqf", T_FACTION_None]					call t_fnc_initializeTemplateFromFile;

// !! Factions will be listed in UI in the same order as here !! 

// Military factions
["Templates\Factions\AAF.sqf", T_FACTION_Military]					call t_fnc_initializeTemplateFromFile;
["Templates\Factions\RHS_AAF_2020.sqf", T_FACTION_Military]			call t_fnc_initializeTemplateFromFile;
["Templates\Factions\RHS_AAF_2010.sqf", T_FACTION_Military]			call t_fnc_initializeTemplateFromFile;
["Templates\Factions\RHS_LDF.sqf", T_FACTION_Military]				call t_fnc_initializeTemplateFromFile;
["Templates\Factions\RHS_AFRF.sqf", T_FACTION_Military]				call t_fnc_initializeTemplateFromFile;
["Templates\Factions\RHS_USAF.sqf", T_FACTION_Military]				call t_fnc_initializeTemplateFromFile;
["Templates\Factions\NATO.sqf", T_FACTION_Military]					call t_fnc_initializeTemplateFromFile;
["Templates\Factions\CSAT.sqf", T_FACTION_Military]					call t_fnc_initializeTemplateFromFile;

// Other factions
["Templates\Factions\CIVILIAN.sqf", T_FACTION_Civ]					call t_fnc_initializeTemplateFromFile;
["Templates\Factions\GUERRILLA.sqf", T_FACTION_Guer]				call t_fnc_initializeTemplateFromFile;

// Police factions
["Templates\Factions\POLICE.sqf", T_FACTION_Police]					call t_fnc_initializeTemplateFromFile;
["Templates\Factions\RHS_AAF_police.sqf", T_FACTION_Police]			call t_fnc_initializeTemplateFromFile;
["Templates\Factions\RHS_LDF_ranger.sqf", T_FACTION_Police]			call t_fnc_initializeTemplateFromFile;