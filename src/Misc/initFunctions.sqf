#include "..\common.h"

//Auxiliary functions
misc_fnc_getFullCrew = COMPILE_COMMON("Misc\fn_getFullCrew.sqf");
misc_fnc_getTurrets = COMPILE_COMMON("Misc\fn_getTurrets.sqf");
misc_fnc_currentWeaponSilenced = COMPILE_COMMON("Misc\fn_currentWeaponSilenced.sqf");
misc_fnc_getCargoInfantryCapacity = COMPILE_COMMON("Misc\fn_getCargoInfantryCapacity.sqf");
misc_fnc_vectorMoreOrEqual = COMPILE_COMMON("Misc\fn_vectorMoreOrEqual.sqf");
#ifndef _SQF_VM
gBBoxCache = [false] call CBA_fnc_createNamespace;
#endif
misc_fnc_boundingBoxReal = COMPILE_COMMON("Misc\fn_boundingBoxReal.sqf");
misc_fnc_getVehicleWidth = COMPILE_COMMON("Misc\fn_getVehicleWidth.sqf");
misc_fnc_isVehicleFlipped = COMPILE_COMMON("Misc\fn_isVehicleFlipped.sqf");
misc_fnc_actionDropAllWeapons = COMPILE_COMMON("Misc\fn_actionDropAllWeapons.sqf");
misc_fnc_mapDrawLine = COMPILE_COMMON("Misc\fn_mapDrawLine.sqf");
misc_fnc_mapDrawLineLocal = COMPILE_COMMON("Misc\fn_mapDrawLineLocal.sqf");
misc_fnc_dateToNumber = COMPILE_COMMON("Misc\fn_dateToNumber.sqf");

misc_fnc_getRoadDirection = COMPILE_COMMON("Misc\fn_getRoadDirection.sqf");
misc_fnc_getRoadWidth = COMPILE_COMMON("Misc\fn_getRoadWidth.sqf");

misc_fnc_polygonCollision = COMPILE_COMMON("Misc\Math\fn_polygonCollision.sqf");

misc_fnc_createCampComposition = COMPILE_COMMON("Misc\fn_createCampComposition.sqf");

misc_fnc_numberToStringZeroPad = COMPILE_COMMON("Misc\fn_numberToStringZeroPad.sqf");
misc_fnc_dateToISO8601 = COMPILE_COMMON("Misc\fn_dateToISO8601.sqf");
misc_fnc_systemTimeToISO8601 = COMPILE_COMMON("Misc\fn_systemTimeToISO8601.sqf");
misc_fnc_getVehiclesInBuilding = COMPILE_COMMON("Misc\fn_getVehiclesInBuilding.sqf");


misc_fnc_getVersion = COMPILE_COMMON("Misc\fn_getVersion.sqf");
misc_fnc_getSaveVersion = COMPILE_COMMON("Misc\fn_getSaveVersion.sqf");
misc_fnc_getSaveBreakVersion = COMPILE_COMMON("Misc\fn_getSaveBreakVersion.sqf");

misc_fnc_isAdminLocal = COMPILE_COMMON("Misc\fn_isAdminLocal.sqf");

#ifndef _SQF_VM
gStaticStringHashmap = [false] call CBA_fnc_createNamespace;
#endif
misc_fnc_createStaticString = COMPILE_COMMON("Misc\fn_createStaticString.sqf");

misc_fnc_findSafeSpawnPos = COMPILE_COMMON("Misc\fn_findSafeSpawnPos.sqf");

misc_fnc_bearingString = COMPILE_COMMON("Misc\fn_bearingString.sqf");