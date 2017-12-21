//Just a quick file to initialize the modules already made in needed order

//Initialize templates
call compile preprocessFileLineNumbers "Templates\initCategories.sqf";
call compile preprocessFileLineNumbers "Templates\initCategoriesNames.sqf";
call compile preprocessFileLineNumbers "Templates\initFunctions.sqf";
//Initialize the NATO template
tNATO = call compile preprocessFileLineNumbers "Templates\NATO.sqf";
tCSAT = call compile preprocessFileLineNumbers "Templates\CSAT.sqf";
//a = [classesNATO, T_VEH, T_VEH_default] call t_fnc_select;
//[classesNATO] call t_fnc_checkNil;

//Initialize misc functions
call compile preprocessFileLineNumbers "Misc\initFunctions.sqf";

//Initialize garrison
call compile preprocessFileLineNumbers "Garrison\initFunctions.sqf";
call compile preprocessFileLineNumbers "Garrison\initVariablesServer.sqf";

//Initialize location
call compile preprocessFileLineNumbers "Location\initFunctions.sqf";
call compile preprocessFileLineNumbers "Location\initVariablesServer.sqf";

//Initialize AI scripts
call compile preprocessFileLineNumbers "AI\initFunctions.sqf";

//Initialize UI functions
call compile preprocessFileLineNumbers "UI\initFunctions.sqf";