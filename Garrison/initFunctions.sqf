//call compile preprocessFileLineNumbers "Garrison\initFunctions.sqf";

//Functions that can be used by external modules in the mission
gar_fnc_createGarrison = compile preprocessFileLineNumbers "Garrison\fn_createGarrison.sqf";
gar_fnc_spawnGarrison = compile preprocessFileLineNumbers "Garrison\fn_spawnGarrison.sqf";
gar_fnc_despawnGarrison = compile preprocessFileLineNumbers "Garrison\fn_despawnGarrison.sqf";
//gar_fnc_addExistingUnit = compile preprocessFileLineNumbers "Garrison\fn_addExistingUnit.sqf";
gar_fnc_addExistingGroup = compile preprocessFileLineNumbers "Garrison\fn_addExistingGroup.sqf"; //Private function
gar_fnc_addNewUnit = compile preprocessFileLineNumbers "Garrison\fn_addNewUnit.sqf";
gar_fnc_addNewGroup = compile preprocessFileLineNumbers "Garrison\fn_addNewGroup.sqf";
gar_fnc_removeUnit = compile preprocessFileLineNumbers "Garrison\fn_removeUnit.sqf";
//gar_fnc_moveUnit = compile preprocessFileLineNumbers "Garrison\fn_moveUnit.sqf"; //You shouldn't move units without group
gar_fnc_moveGroup = compile preprocessFileLineNumbers "Garrison\fn_moveGroup.sqf";
gar_fnc_findUnits = compile preprocessFileLineNumbers "Garrison\fn_findUnits.sqf";
gar_fnc_countUnits = compile preprocessFileLineNumbers "Garrison\fn_countUnits.sqf";

gar_fnc_garrisonThread = compile preprocessFileLineNumbers "Garrison\fn_garrisonThread.sqf";
gar_fnc_startThread = compile preprocessFileLineNumbers "Garrison\fn_startThread.sqf";
gar_fnc_stopThread = compile preprocessFileLineNumbers "Garrison\fn_stopThread.sqf";

gar_fnc_getUnit = compile preprocessFileLineNumbers "Garrison\fn_getUnit.sqf";
gar_fnc_getGroup = compile preprocessFileLineNumbers "Garrison\fn_getGroup.sqf";

//gar_fnc_startAIThread = compile preprocessFileLineNumbers "Garrison\fn_startAIThread.sqf";

//Functions called only from the thread
gar_fnc_t_spawnGarrison = compile preprocessFileLineNumbers "Garrison\fn_t_spawnGarrison.sqf";
gar_fnc_t_despawnGarrison = compile preprocessFileLineNumbers "Garrison\fn_t_despawnGarrison.sqf";
gar_fnc_t_spawnUnit = compile preprocessFileLineNumbers "Garrison\fn_t_spawnUnit.sqf";
gar_fnc_t_despawnUnit = compile preprocessFileLineNumbers "Garrison\fn_t_despawnUnit.sqf";
gar_fnc_t_addExistingUnit = compile preprocessFileLineNumbers "Garrison\fn_t_addExistingUnit.sqf";
gar_fnc_t_addNewUnit = compile preprocessFileLineNumbers "Garrison\fn_t_addNewUnit.sqf";
gar_fnc_t_addNewGroup = compile preprocessFileLineNumbers "Garrison\fn_t_addNewGroup.sqf";
gar_fnc_t_addExistingGroup = compile preprocessFileLineNumbers "Garrison\fn_t_addExistingGroup.sqf";
gar_fnc_t_removeUnit = compile preprocessFileLineNumbers "Garrison\fn_t_removeUnit.sqf";
gar_fnc_t_removeGroup = compile preprocessFileLineNumbers "Garrison\fn_t_removeGroup.sqf";
//gar_fnc_t_moveUnit = compile preprocessFileLineNumbers "Garrison\fn_t_moveUnit.sqf";
gar_fnc_t_moveGroup = compile preprocessFileLineNumbers "Garrison\fn_t_moveGroup.sqf";
gar_fnc_t_assignVehicleRoles = compile preprocessFileLineNumbers "Garrison\fn_t_assignVehicleRoles.sqf";

/*
gar_fnc_t_startAIThread = compile preprocessFileLineNumbers "Garrison\fn_t_startAIThread.sqf";
gar_fnc_t_stopAIThread = compile preprocessFileLineNumbers "Garrison\fn_t_stopAIThread.sqf";
gar_fnc_t_startEnemiesThread = compile preprocessFileLineNumbers "Garrison\fn_t_startEnemiesThread.sqf";
gar_fnc_t_stopEnemiesThread = compile preprocessFileLineNumbers "Garrison\fn_t_stopEnemiesThread.sqf";
*/

//Event handlers
gar_fnc_EH_killed = compile preprocessFileLineNumbers "Garrison\fn_EH_killed.sqf";
gar_fnc_EH_handleDamage = compile preprocessFileLineNumbers "Garrison\fn_EH_handleDamage.sqf";

//General functions
call compile preprocessFileLineNumbers "Garrison\generalFunctions.sqf";
gar_fnc_requestDone = compile preprocessFileLineNumbers "Garrison\fn_requestDone.sqf";

//Other functions
gar_fnc_reportSpottedEnemies = compile preprocessFileLineNumbers "Garrison\fn_reportSpottedEnemies.sqf";