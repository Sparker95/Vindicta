#ifdef _SQF_VM
#define IS_SERVER true
#else
#define IS_SERVER isServer
#endif

diag_log "[Templates] initVariables";

#ifndef _SQF_VM
// Hashmap that matches class name to number
t_classnames_hashmap = [true] call CBA_fnc_createNamespace;
t_classnames_array = [];
publicVariable "t_classnames_array";
#endif

// Array with all valid template names
t_validTemplates = [];
t_allTemplates = [];

call compile preprocessFileLineNumbers "Templates\Loot\init.sqf";
call compile preprocessFileLineNumbers "Templates\initCategories.sqf";
call compile preprocessFileLineNumbers "Templates\initCategoriesNames.sqf";
call compile preprocessFileLineNumbers "Templates\initEfficiency.sqf";
call compile preprocessFileLineNumbers "Templates\initComposition.sqf";
call compile preprocessFileLineNumbers "Templates\initLoadouts.sqf";
call compile preprocessFileLineNumbers "Templates\combatTips.sqf";

if (IS_SERVER) then {
	call compile preprocessFileLineNumbers "Templates\initFactions.sqf";
	#ifndef _SQF_VM
	publicVariable "t_validTemplates";
	publicVariable "t_allTemplates";
	#endif
};