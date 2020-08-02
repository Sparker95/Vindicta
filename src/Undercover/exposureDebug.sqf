fnc_getVisibleSurface = COMPILE_COMMON("Undercover\fn_getVisibleSurface.sqf");

g_surfaceUpdateTime = diag_tickTime;

timeStart = time;

onEachFrame {
	
	//[0, 360, -5, 5] call fnc_countIntersections;
	//[0, 360, 85, 95] call fnc_countIntersections;
	
	
	private _exposure = [20, 120, 0, 360, player] call fnc_getVisibleSurface; // Higher polusphere
	
	if (diag_tickTime - g_surfaceUpdateTime > 0.2) then {
		systemChat format ["Your exposure is: %1", _exposure];
		g_surfaceUpdateTime = diag_tickTime;
	};
	
	if (time > (timeStart + 600)) then {onEachFrame {};};
};