[] execVM "AI\VirtualRoute\gps_core\init.sqf";

call compile preprocessFileLineNumbers "AI\VirtualRoute\VirtualRoute.sqf";

[] execVM "AI\VirtualRoute\debug\init.sqf";