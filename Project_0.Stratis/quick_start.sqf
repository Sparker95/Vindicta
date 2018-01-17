//Init one garrison
player allowDamage false;
call compile preprocessFileLineNumbers "initModules.sqf";

loc0 = [getpos player, "temp loc", LOC_TYPE_outpost] call loc_fnc_createLocation;
[loc0, 20] call loc_fnc_setBorderCircle;

gar0 = [] call gar_fnc_createGarrison;
[gar0, WEST] call gar_fnc_setSide;
[gar0, "GAR_0"] call gar_fnc_setName;
[gar0, tNATO] call gar_fnc_setTemplate;
[gar0, loc0] call gar_fnc_setLocation;
[gar0, tNATO, T_GROUP_inf_sentry, -1, G_GT_patrol, [], true] call gar_fnc_addNewGroup;
[gar0, tNATO, T_GROUP_inf_sentry, -1, G_GT_patrol, [], true] call gar_fnc_addNewGroup;
[gar0] call gar_fnc_spawnGarrison;

[gar0, [0,4,1], 3] call gar_fnc_joinGroup;


//////////////////////////////////////////////

player allowDamage false;
call compile preprocessFileLineNumbers "initModules.sqf";
loc = [getPos player, "LOC_0"] call loc_fnc_createLocation;
[loc, 200] call loc_fnc_initializeSpawnPositions;

lo0 = [] call gar_fnc_createGarrison;
[lo0, WEST] call gar_fnc_setSide;
[lo0, "GAR_0"] call gar_fnc_setName;
[lo0, [0, 0, 0]] call gar_fnc_setPos;
[lo0, tNATO] call gar_fnc_setTemplate;
[lo0, loc] call gar_fnc_setLocation;
[lo0] call gar_fnc_startThread;

[lo0, [[T_VEH, T_VEH_stat_GMG_high, 0], [T_VEH, T_VEH_stat_GMG_high, 0], [T_VEH, T_VEH_stat_GMG_high, 0], [T_VEH, T_VEH_stat_GMG_high, 0], [T_VEH, T_VEH_stat_GMG_high, 0], [T_VEH, T_VEH_stat_GMG_high, 0], [T_VEH, T_VEH_stat_GMG_high, 0], [T_VEH, T_VEH_stat_GMG_high, 0]], -1, G_GT_veh_static] call gar_fnc_addNewGroup;

[lo0, T_VEH, T_VEH_MRAP_HMG, 0, -1] call gar_fnc_addNewUnit;
[lo0, T_VEH, T_VEH_MRAP_HMG, 0, -1] call gar_fnc_addNewUnit;

[lo0, T_VEH, T_VEH_stat_mortar_light, 0, -1] call gar_fnc_addNewUnit;

[lo0, T_VEH, T_VEH_stat_HMG_high, 0, -1] call gar_fnc_addNewUnit;

[lo0, T_VEH, T_VEH_stat_HMG_low, 0, -1] call gar_fnc_addNewUnit;


//////////////////////////////
player allowDamage false;
call compile preprocessFileLineNumbers "initModules.sqf";
loc = [getPos player, "LOC_0", 0] call loc_fnc_createLocation;
[loc, 200] call loc_fnc_initSpawnPositions;
gar = [loc] call loc_fnc_getMainGarrison;
[gar, WEST] call gar_fnc_setSide;
[gar, tNATO] call gar_fnc_setTemplate;
[loc, gar, [[T_VEH, T_VEH_stat_HMG_high, 1], [T_VEH, T_VEH_stat_GMG_high, 1]], G_GT_veh_static, 1] call loc_fnc_addUnits;
[loc, gar, [[T_VEH, T_VEH_MRAP_HMG, 1], [T_VEH, T_VEH_MRAP_GMG, 1]], G_GT_veh_non_static, 1] call loc_fnc_addUnits;
[gar] call gar_fnc_spawnGarrison;


//Test base initialization
player allowDamage false;
call compile preprocessFileLineNumbers "initModules.sqf";
allLocations = call compile preprocessFileLineNumbers "Init\createAllLocations.sqf";
[allLocations] call compile preprocessFileLineNumbers "Init\initAllGarrisons.sqf";


///Test the AI behaviour functions
player allowDamage false;
call compile preprocessFileLineNumbers "initModules.sqf";
[[group cursorObject], [getpos player, 40], AI_fnc_behaviour_casual] call AI_fnc_startBehaviourScript;

//Test the patrol script
player allowDamage false;
call compile preprocessFileLineNumbers "initModules.sqf";
_pos = getPos player;
wp = [];
wp pushback (_pos vectorAdd [40+20, 40, 0]);
wp pushback (_pos vectorAdd [40, 40+20, 0]);
wp pushback (_pos vectorAdd [40-20, 40, 0]);
wp pushback (_pos vectorAdd [40, 40-20, 0]);
[[g0], [wp]] spawn AI_fnc_behaviour_patrol;


//Test commander's map interface
UI_fnc_onMapSingleClick =
compile preprocessfilelinenumbers "UI\onMapSingleClick.sqf";
onMapSingleClick {call UI_fnc_onMapSingleClick;};
