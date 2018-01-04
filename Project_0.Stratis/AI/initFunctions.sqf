//Scripts for behaviour at bases
AI_fnc_behaviourCasual = compile preprocessFileLineNumbers "AI\lowLevel\behaviourCasual.sqf";
AI_fnc_behaviourCasualCrew = compile preprocessFileLineNumbers "AI\lowLevel\behaviourCasualCrew.sqf";
AI_fnc_behaviourPatrol = compile preprocessFileLineNumbers "AI\lowLevel\behaviourPatrol.sqf";

//Medium level scripts for alert state behaviours
AI_fnc_alertStateSafe = compile preprocessFileLineNumbers "AI\mediumLevel\fn_alertStateSafe.sqf";
AI_fnc_alertStateAware = compile preprocessFileLineNumbers "AI\mediumLevel\fn_alertStateAware.sqf";
AI_fnc_alertStateCombat = compile preprocessFileLineNumbers "AI\mediumLevel\fn_alertStateCombat.sqf";

//Script for managing spotted enemies
AI_fnc_manageSpottedEnemies = compile preprocessFileLineNumbers "AI\mediumLevel\fn_manageSpottedEnemies.sqf";
call compile preprocessFileLineNumbers "AI\mediumLevel\manageSpottedEnemies.sqf";

//Scripts to start/stop medium level scripts
AI_fnc_startMediumLevelScript = compile preprocessFileLineNumbers "AI\fn_startMediumLevelScript.sqf";
AI_fnc_stopMediumLevelScript = compile preprocessFileLineNumbers "AI\fn_stopMediumLevelScript.sqf";

//Register script handle in script object's array
AI_fnc_registerScriptHandle = compile preprocessFileLineNumbers "AI\fn_registerScriptHandle.sqf";