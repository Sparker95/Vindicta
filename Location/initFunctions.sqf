loc_fnc_createLocation = compile preprocessFileLineNumbers "Location\fn_createLocation.sqf";

//Spawn positions
loc_fnc_initSpawnPositions = compile preprocessFileLineNumbers "Location\fn_initSpawnPositions.sqf";
loc_fnc_addSpawnPosition = compile preprocessFileLineNumbers "Location\fn_addSpawnposition.sqf";
loc_fnc_getSpawnPosition = compile preprocessFileLineNumbers "Location\fn_getSpawnPosition.sqf";
loc_fnc_getMaxCapacity = compile preprocessFileLineNumbers "Location\fn_getMaxCapacity.sqf";
loc_fnc_resetSpawnPositionCounters = compile preprocessFileLineNumbers "Location\fn_resetSpawnPositionCounters.sqf";

loc_fnc_addUnits = compile preprocessFileLineNumbers "Location\fn_addUnits.sqf";
loc_fnc_addGroups = compile preprocessFileLineNumbers "Location\fn_addGroups.sqf";

call compile preprocessFileLineNumbers "Location\generalFunctions.sqf";

loc_fnc_startThread = compile preprocessFileLineNumbers "Location\fn_startThread.sqf";
loc_fnc_locationThread = compile preprocessFileLineNumbers "Location\fn_locationThread.sqf";

loc_fnc_spawnAllGarrisons = compile preprocessFileLineNumbers "Location\fn_spawnAllGarrisons.sqf";
loc_fnc_despawnAllGarrisons = compile preprocessFileLineNumbers "Location\fn_despawnAllGarrisons.sqf";

loc_fnc_setBorderCircle = compile preprocessFileLineNumbers "Location\fn_setBorderCircle.sqf";
loc_fnc_setBorderRectangle = compile preprocessFileLineNumbers "Location\fn_setBorderRectangle.sqf";
loc_fnc_insideBorder = compile preprocessFileLineNumbers "Location\fn_insideBorder.sqf";

loc_fnc_isPosSafe = compile preprocessFileLineNumbers "Location\fn_isPosSafe.sqf";
loc_fnc_boundingBoxReal = compile preprocessFileLineNumbers "Location\fn_boundingBoxReal.sqf";

//todo redo the markers
loc_fnc_setMarker = compile preprocessFileLineNumbers "Location\fn_setMarker.sqf";
loc_fnc_updateMarker = compile preprocessFileLineNumbers "Location\fn_updateMarker.sqf";

//Functions to change AI scripts
loc_fnc_restartEnemiesScript	= compile preprocessFileLineNumbers "Location\fn_restartEnemiesScript.sqf";
loc_fnc_stopEnemiesScript		= compile preprocessFileLineNumbers "Location\fn_stopEnemiesScript.sqf";
loc_fnc_restartAlertStateScript	= compile preprocessFileLineNumbers "Location\fn_restartAlertStateScript.sqf";
loc_fnc_stopAlertStateScript	= compile preprocessFileLineNumbers "Location\fn_stopAlertStateScript.sqf";