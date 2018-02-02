//Scripts for behaviour at bases
AI_fnc_behaviourCasual = compile preprocessFileLineNumbers "AI\lowLevel\fn_behaviourCasual.sqf";
AI_fnc_behaviourCasualCrew = compile preprocessFileLineNumbers "AI\lowLevel\fn_behaviourCasualCrew.sqf";
AI_fnc_behaviourPatrol = compile preprocessFileLineNumbers "AI\lowLevel\fn_behaviourPatrol.sqf";

//Medium level scripts for alert state behaviours
AI_fnc_alertStateSafe = compile preprocessFileLineNumbers "AI\mediumLevel\scripts\fn_alertStateSafe.sqf";
AI_fnc_alertStateAware = compile preprocessFileLineNumbers "AI\mediumLevel\scripts\fn_alertStateAware.sqf";
AI_fnc_alertStateCombat = compile preprocessFileLineNumbers "AI\mediumLevel\scripts\fn_alertStateCombat.sqf";

//Other medium level scripts
//AI_fnc_landConvoy = compile preprocessFileLineNumbers "AI\mediumLevel\scripts\fn_landConvoy.sqf";
//call compile preprocessFileLineNumbers "AI\mediumLevel\scripts\landConvoy.sqf";

//Script for managing spotted enemies
AI_fnc_manageSpottedEnemies = compile preprocessFileLineNumbers "AI\mediumLevel\scripts\fn_manageSpottedEnemies.sqf";
call compile preprocessFileLineNumbers "AI\mediumLevel\scripts\manageSpottedEnemies.sqf";

//Scripts to start/stop medium level scripts
AI_fnc_startMediumLevelScript = compile preprocessFileLineNumbers "AI\mediumLevel\fn_startMediumLevelScript.sqf";
AI_fnc_stopMediumLevelScript = compile preprocessFileLineNumbers "AI\mediumLevel\fn_stopMediumLevelScript.sqf";

//Register script handle in script object's array
AI_fnc_registerScriptHandle = compile preprocessFileLineNumbers "AI\mediumLevel\fn_registerScriptHandle.sqf";

//Functions
AI_fnc_assignInfantryCargo = compile preprocessFileLineNumbers "AI\functions\fn_assignInfantryCargo.sqf";
AI_fnc_deleteAllWaypoints = compile preprocessFileLineNumbers "AI\functions\fn_deleteAllWaypoints.sqf";
AI_fnc_formVehicleGroup = compile preprocessFileLineNumbers "AI\functions\fn_formVehicleGroup.sqf";
AI_fnc_splitVehicleGroup = compile preprocessFileLineNumbers "AI\functions\fn_splitVehicleGroup.sqf";
AI_fnc_moveInAssigned = compile preprocessFileLineNumbers "AI\functions\fn_moveInAssigned.sqf";
AI_fnc_rejoinGarrisonGroup = compile preprocessFileLineNumbers "AI\functions\fn_rejoinGarrisonGroup.sqf";

//Tasks
call compile preprocessFileLineNumbers "AI\task\initFunctions.sqf";

//Missions
call compile preprocessFileLineNumbers "AI\mission\initFunctions.sqf";