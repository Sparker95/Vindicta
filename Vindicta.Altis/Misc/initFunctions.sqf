//Auxiliary functions
misc_fnc_getFullCrew = compile preprocessFileLineNumbers "Misc\fn_getFullCrew.sqf";
misc_fnc_getTurrets = compile preprocessFileLineNumbers "Misc\fn_getTurrets.sqf";
misc_fnc_currentWeaponSilenced = compile preprocessFileLineNumbers "Misc\fn_currentWeaponSilenced.sqf";
misc_fnc_getCargoInfantryCapacity = compile preprocessFileLineNumbers "Misc\fn_getCargoInfantryCapacity.sqf";
misc_fnc_vectorMoreOrEqual = compile preprocessFileLineNumbers "Misc\fn_vectorMoreOrEqual.sqf";
#ifndef _SQF_VM
gBBoxCache = [false] call CBA_fnc_createNamespace;
#endif
misc_fnc_boundingBoxReal = compile preprocessFileLineNumbers "Misc\fn_boundingBoxReal.sqf";
misc_fnc_getVehicleWidth = compile preprocessFileLineNumbers "Misc\fn_getVehicleWidth.sqf";
misc_fnc_isVehicleFlipped = compile preprocessFileLineNumbers "Misc\fn_isVehicleFlipped.sqf";
misc_fnc_actionDropAllWeapons = compile preprocessFileLineNumbers "Misc\fn_actionDropAllWeapons.sqf";
misc_fnc_mapDrawLine = compile preprocessFileLineNumbers "Misc\fn_mapDrawLine.sqf";
misc_fnc_mapDrawLineLocal = compile preprocessFileLineNumbers "Misc\fn_mapDrawLineLocal.sqf";
misc_fnc_dateToNumber = compile preprocessFileLineNumbers "Misc\fn_dateToNumber.sqf";

misc_fnc_getRoadDirection = compile preprocessFileLineNumbers "Misc\fn_getRoadDirection.sqf";
misc_fnc_getRoadWidth = compile preprocessFileLineNumbers "Misc\fn_getRoadWidth.sqf";

misc_fnc_polygonCollision = compile preprocessFileLineNumbers "Misc\Math\fn_polygonCollision.sqf";

misc_fnc_createCampComposition = compile preprocessFileLineNumbers "Misc\fn_createCampComposition.sqf";

misc_fnc_dateToISO8601 = compile preprocessFileLineNumbers "Misc\fn_dateToISO8601.sqf";
misc_fnc_getVehiclesInBuilding = compile preprocessFileLineNumbers "Misc\fn_getVehiclesInBuilding.sqf";


misc_fnc_getVersion = compile preprocessFileLineNumbers "Misc\fn_getVersion.sqf";
misc_fnc_getSaveVersion = compile preprocessFileLineNumbers "Misc\fn_getSaveVersion.sqf";
misc_fnc_getSaveBreakVersion = compile preprocessFileLineNumbers "Misc\fn_getSaveBreakVersion.sqf";

misc_fnc_isAdminLocal = compile preprocessFileLineNumbers "Misc\fn_isAdminLocal.sqf";

#ifndef _SQF_VM
gStaticStringHashmap = [false] call CBA_fnc_createNamespace;
#endif
misc_fnc_createStaticString = compile preprocessFileLineNumbers "Misc\fn_createStaticString.sqf";

misc_fnc_findSafeSpawnPos = compile preprocessFileLineNumbers "Misc\fn_findSafeSpawnPos.sqf";