t_fnc_getTemplate = compile preprocessfilelinenumbers "Templates\fn_getTemplate.sqf";
t_fnc_selectArray = compile preprocessfilelinenumbers "Templates\fn_selectArray.sqf";
t_fnc_selectRandom = compile preprocessfilelinenumbers "Templates\fn_selectRandom.sqf";
t_fnc_select = compile preprocessfilelinenumbers "Templates\fn_select.sqf";
t_fnc_selectGroup = compile preprocessFileLineNumbers "Templates\fn_selectGroup.sqf";
t_fnc_checkNil = compile preprocessfilelinenumbers "Templates\fn_checkNil.sqf";
t_fnc_find = compile preprocessfilelinenumbers "Templates\fn_find.sqf";
t_fnc_isValid = compile preprocessfilelinenumbers "Templates\fn_isValid.sqf";
t_fnc_getEfficiency = compile preprocessFileLineNumbers "Templates\fn_getEfficiency.sqf";
t_fnc_getMetadata = compile preprocessFileLineNumbers "Templates\fn_getMetadata.sqf";

t_fnc_convertConfigGroup = compile preprocessFileLineNumbers "Templates\fn_convertConfigGroup.sqf";
t_fnc_getDefaultCrew = compile preprocessFileLineNumbers "Templates\fn_getDefaultCrew.sqf";
t_fnc_canDestroy = compile preprocessFileLineNumbers "Templates\fn_canDestroy.sqf";
t_fnc_validateTemplate = compile preprocessFileLineNumbers "Templates\fn_validateTemplate.sqf";
t_fnc_initializeTemplateFromFile = compile preprocessFileLineNumbers "Templates\fn_initializeTemplateFromFile.sqf";

t_fnc_getAllValidTemplateNames = compile preprocessFileLineNumbers "Templates\fn_getAllValidTemplateNames.sqf";
t_fnc_getAllTemplateNames = compile preprocessFileLineNumbers "Templates\fn_getAllTemplateNames.sqf";

t_fnc_classNameToNumber = compile preprocessFileLineNumbers "Templates\fn_classNameToNumber.sqf";
t_fnc_numberToClassName = compile preprocessFileLineNumbers "Templates\fn_numberToClassName.sqf";
t_fnc_convertTemplateClassNamesToNumbers = compile preprocessFileLineNumbers "Templates\fn_convertTemplateClassNamesToNumbers.sqf";

t_fnc_newCategory = compile preprocessFileLineNumbers "Templates\fn_newCategory.sqf";

// Loadouts
t_fnc_addLoadout = compile preprocessFileLineNumbers "Templates\fn_addLoadout.sqf";
t_fnc_setUnitLoadout = compile preprocessFileLineNumbers "Templates\fn_setUnitLoadout.sqf";
t_fnc_isLoadout = compile preprocessFileLineNumbers "Templates\fn_isLoadout.sqf";

t_fnc_processTemplateItems = compile preprocessFileLineNumbers "Templates\fn_processTemplateItems.sqf";

t_fnc_callAPIOptional = compile preprocessFileLineNumbers "Templates\fn_callAPIOptional.sqf";

t_fnc_addUndercoverItems = compile preprocessFileLineNumbers "Templates\fn_addUndercoverItems.sqf";

call compile preprocessFileLineNumbers "Templates\EfficiencyFunctions.sqf";
call compile preprocessFileLineNumbers "Templates\CompositionFunctions.sqf";