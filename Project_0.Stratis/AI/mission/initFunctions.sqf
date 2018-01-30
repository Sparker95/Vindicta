call compile preprocessFileLineNumbers "AI\mission\mission.sqf";
AI_fnc_mission_registerGarrisons = compile preprocessFileLineNumbers "AI\mission\fn_registerGarrisons.sqf";
AI_fnc_mission_startMissions = compile preprocessFileLineNumbers "AI\mission\fn_startMissions.sqf";
AI_fnc_mission_missionMonitor = compile preprocessFileLineNumbers "AI\mission\fn_missionMonitor.sqf";
AI_fnc_mission_calculateEfficiency = compile preprocessFileLineNumbers "AI\mission\fn_calculateEfficiency.sqf";
AI_fnc_mission_garrisonThread = compile preprocessFileLineNumbers "AI\mission\fn_garrisonThread.sqf";

//Mission scripts
AI_fnc_mission_SAD = compile preprocessFileLineNumbers "AI\mission\missionScripts\fn_SAD.sqf";
AI_fnc_mission_capture = compile preprocessFileLineNumbers "AI\mission\missionScripts\fn_capture.sqf";