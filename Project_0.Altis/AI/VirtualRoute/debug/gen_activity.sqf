private _new_grid = [] call ws_fnc_newGridArray;

[] call ws_fnc_unplotGrid;

for "_i" from 0 to 5 + random(20) do {
	private _pos = [] call BIS_fnc_randomPos;
	
	for "_j" from 0 to 5 + random(20) do {
		private _pos2 = [[[_pos, 1000]]] call BIS_fnc_randomPos;
		[_new_grid, _pos2 select 0, _pos2 select 1, 10 * (sqrt (1 + random(100)))] call ws_fnc_setValue; 
	};
};
[_new_grid, activity_grid] call ws_fnc_filterSmooth;

[activity_grid, 100] call ws_fnc_plotGrid;