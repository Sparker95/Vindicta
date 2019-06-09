// Hashmap that matches tag to script or code
t_loadouts_hashmap = [false] call CBA_fnc_createNamespace;

// Finally initialize user's custom loadouts
call compile preprocessFileLineNumbers "Templates\Loadouts\init.sqf";