call compile preprocessFileLineNumbers "AI\mission\mission.sqf";
AI_fnc_mission_registerGarrisons = compile preprocessFileLineNumbers "AI\mission\fn_registerGarrisons.sqf";
AI_fnc_mission_startMissions = compile preprocessFileLineNumbers "AI\mission\fn_startMissions.sqf";
AI_fnc_mission_missionMonitor = compile preprocessFileLineNumbers "AI\mission\fn_missionMonitor.sqf";
AI_fnc_mission_calculateEfficiency = compile preprocessFileLineNumbers "AI\mission\fn_calculateEfficiency.sqf";
AI_fnc_mission_allocateUnits = compile preprocessFileLineNumbers "AI\mission\fn_allocateUnits.sqf";
AI_fnc_mission_garrisonThread = compile preprocessFileLineNumbers "AI\mission\fn_garrisonThread.sqf";
AI_fnc_mission_assignGarrison = compile preprocessFileLineNumbers "AI\mission\fn_assignGarrison.sqf";

//Mission scripts
AI_fnc_mission_SAD = compile preprocessFileLineNumbers "AI\mission\missionScripts\fn_SAD.sqf";
AI_fnc_mission_capture = compile preprocessFileLineNumbers "AI\mission\missionScripts\fn_capture.sqf";
AI_fnc_mission_moveAndMerge = compile preprocessFileLineNumbers "AI\mission\missionScripts\fn_moveAndMerge.sqf";