#include "..\common.h"

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

CALL_COMPILE_COMMON("Templates\initCategories.sqf");
CALL_COMPILE_COMMON("Templates\initLoot.sqf");
CALL_COMPILE_COMMON("Templates\initCategoriesNames.sqf");
CALL_COMPILE_COMMON("Templates\initEfficiency.sqf");
CALL_COMPILE_COMMON("Templates\initComposition.sqf");
CALL_COMPILE_COMMON("Templates\initLoadouts.sqf");
CALL_COMPILE_COMMON("Templates\combatTips.sqf");

if (IS_SERVER) then {
	CALL_COMPILE_COMMON("Templates\initFactions.sqf");
	#ifndef _SQF_VM
	publicVariable "t_validTemplates";
	publicVariable "t_allTemplates";
	#endif
};