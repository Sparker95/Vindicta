// Initialize factions
// This variable is necessary for other factions to initialize!
["Templates\Factions\default.sqf", T_FACTION_None]					call t_fnc_initializeTemplateFromFile;

<<<<<<< fix-u-menu-/-add-faction-new-factions
["Templates\Factions\NATO.sqf"]					call t_fnc_initializeTemplateFromFile;
["Templates\Factions\CSAT.sqf"]					call t_fnc_initializeTemplateFromFile;
["Templates\Factions\AAF.sqf"]					call t_fnc_initializeTemplateFromFile;
["Templates\Factions\GUERRILLA.sqf"]				call t_fnc_initializeTemplateFromFile;
["Templates\Factions\POLICE.sqf"]				call t_fnc_initializeTemplateFromFile;
["Templates\Factions\CIVILIAN.sqf"]				call t_fnc_initializeTemplateFromFile;
["Templates\Factions\RHS_AAF2017_elite.sqf"]	call t_fnc_initializeTemplateFromFile;
["Templates\Factions\RHS_AAF2017_police.sqf"]	call t_fnc_initializeTemplateFromFile;
["Templates\Factions\RHS_AFRF.sqf"]	call t_fnc_initializeTemplateFromFile;
["Templates\Factions\RHS_USAF.sqf"]	call t_fnc_initializeTemplateFromFile;
["Templates\Factions\RHS_LDF.sqf"]	call t_fnc_initializeTemplateFromFile;
["Templates\Factions\RHS_LDF_ranger.sqf"]	call t_fnc_initializeTemplateFromFile;
["Templates\Factions\RHS_HIDF.sqf"]	call t_fnc_initializeTemplateFromFile;
["Templates\Factions\WW2_Heer.sqf"]	call t_fnc_initializeTemplateFromFile;
["Templates\Factions\WW2_Heer_police.sqf"]	call t_fnc_initializeTemplateFromFile;
["Templates\Factions\WW2_UK.sqf"]	call t_fnc_initializeTemplateFromFile;
["Templates\Factions\WW2_UK_police.sqf"]	call t_fnc_initializeTemplateFromFile;
=======
["Templates\Factions\NATO.sqf", T_FACTION_Military]					call t_fnc_initializeTemplateFromFile;
["Templates\Factions\CSAT.sqf", T_FACTION_Military]					call t_fnc_initializeTemplateFromFile;
["Templates\Factions\AAF.sqf", T_FACTION_Military]					call t_fnc_initializeTemplateFromFile;
["Templates\Factions\GUERRILLA.sqf", T_FACTION_Police]				call t_fnc_initializeTemplateFromFile;
["Templates\Factions\POLICE.sqf", T_FACTION_Police]					call t_fnc_initializeTemplateFromFile;
["Templates\Factions\CIVILIAN.sqf", T_FACTION_Civ]					call t_fnc_initializeTemplateFromFile;
["Templates\Factions\RHS_AAF2017_elite.sqf", T_FACTION_Military]	call t_fnc_initializeTemplateFromFile;
["Templates\Factions\RHS_AAF2017_police.sqf", T_FACTION_Police]		call t_fnc_initializeTemplateFromFile;
["Templates\Factions\RHS_AFRF.sqf", T_FACTION_Military]				call t_fnc_initializeTemplateFromFile;
["Templates\Factions\RHS_USAF.sqf", T_FACTION_Military]				call t_fnc_initializeTemplateFromFile;
["Templates\Factions\RHS_LDF.sqf", T_FACTION_Military]				call t_fnc_initializeTemplateFromFile;
["Templates\Factions\RHS_LDF_ranger.sqf", T_FACTION_Police]			call t_fnc_initializeTemplateFromFile;
>>>>>>> development