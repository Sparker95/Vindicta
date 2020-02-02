#ifndef _SQF_VM
// Hashmap that matches tag to script or code
t_loadouts_hashmap = [false] call CBA_fnc_createNamespace;
#else
t_loadouts_hashmap = "_loadouts_hashmap_" createVehicle [0, 0, 0];
#endif

// Finally initialize user's custom loadouts
call compile preprocessFileLineNumbers "Templates\Loadouts\init.sqf";