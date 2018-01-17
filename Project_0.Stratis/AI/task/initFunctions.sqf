call compile preprocessFileLineNumbers "AI\task\task.sqf";

AI_fnc_task_load = compile preprocessFileLineNumbers "AI\task\taskScripts\fn_load.sqf";
AI_fnc_task_move = compile preprocessFileLineNumbers "AI\task\taskScripts\fn_move.sqf";

AI_fnc_task_move_landConvoy = compile preprocessFileLineNumbers "AI\task\taskScripts\move\fn_landConvoy.sqf";
call compile preprocessFileLineNumbers "AI\task\taskScripts\move\landConvoy.sqf";