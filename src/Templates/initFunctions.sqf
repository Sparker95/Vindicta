#include "..\common.h"
t_fnc_getTemplate = COMPILE_COMMON("Templates\fn_getTemplate.sqf");
t_fnc_selectArray = COMPILE_COMMON("Templates\fn_selectArray.sqf");
t_fnc_selectRandom = COMPILE_COMMON("Templates\fn_selectRandom.sqf");
t_fnc_select = COMPILE_COMMON("Templates\fn_select.sqf");
t_fnc_selectGroup = COMPILE_COMMON("Templates\fn_selectGroup.sqf");
t_fnc_checkNil = COMPILE_COMMON("Templates\fn_checkNil.sqf");
t_fnc_find = COMPILE_COMMON("Templates\fn_find.sqf");
t_fnc_isValid = COMPILE_COMMON("Templates\fn_isValid.sqf");
t_fnc_getEfficiency = COMPILE_COMMON("Templates\fn_getEfficiency.sqf");
t_fnc_getMetadata = COMPILE_COMMON("Templates\fn_getMetadata.sqf");

t_fnc_convertConfigGroup = COMPILE_COMMON("Templates\fn_convertConfigGroup.sqf");
t_fnc_getDefaultCrew = COMPILE_COMMON("Templates\fn_getDefaultCrew.sqf");
t_fnc_canDestroy = COMPILE_COMMON("Templates\fn_canDestroy.sqf");
t_fnc_validateTemplate = COMPILE_COMMON("Templates\fn_validateTemplate.sqf");
t_fnc_initializeTemplateFromFile = COMPILE_COMMON("Templates\fn_initializeTemplateFromFile.sqf");

t_fnc_getAllValidTemplateNames = COMPILE_COMMON("Templates\fn_getAllValidTemplateNames.sqf");
t_fnc_getAllTemplateNames = COMPILE_COMMON("Templates\fn_getAllTemplateNames.sqf");

t_fnc_classNameToNumber = COMPILE_COMMON("Templates\fn_classNameToNumber.sqf");
t_fnc_numberToClassName = COMPILE_COMMON("Templates\fn_numberToClassName.sqf");
t_fnc_convertTemplateClassNamesToNumbers = COMPILE_COMMON("Templates\fn_convertTemplateClassNamesToNumbers.sqf");

t_fnc_newCategory = COMPILE_COMMON("Templates\fn_newCategory.sqf");

// Loadouts
t_fnc_addLoadout = COMPILE_COMMON("Templates\fn_addLoadout.sqf");
t_fnc_setUnitLoadout = COMPILE_COMMON("Templates\fn_setUnitLoadout.sqf");
t_fnc_isLoadout = COMPILE_COMMON("Templates\fn_isLoadout.sqf");

t_fnc_processTemplateItems = COMPILE_COMMON("Templates\fn_processTemplateItems.sqf");

t_fnc_callAPIOptional = COMPILE_COMMON("Templates\fn_callAPIOptional.sqf");

t_fnc_addUndercoverItems = COMPILE_COMMON("Templates\fn_addUndercoverItems.sqf");

CALL_COMPILE_COMMON("Templates\EfficiencyFunctions.sqf");
CALL_COMPILE_COMMON("Templates\CompositionFunctions.sqf");