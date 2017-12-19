player allowDamage false;
call compile preprocessFileLineNumbers "initModules.sqf";

lo0 = [] call gar_fnc_createGarrison;
[lo0, WEST] call gar_fnc_setSide;
[lo0, "GAR_0"] call gar_fnc_setName;
[lo0, [0, 0, 0]] call gar_fnc_setPos;
[lo0, tNATO] call gar_fnc_setTemplate;
[lo0] call gar_fnc_startThread;
[lo0, T_INF, T_INF_SL, -1] call gar_fnc_addNewUnit;
[lo0, T_INF, T_INF_GL, -1] call gar_fnc_addNewUnit;
[lo0, T_INF, T_INF_rifleman, -1] call gar_fnc_addNewUnit;

lo1 = [] call gar_fnc_createGarrison;
[lo1, WEST] call gar_fnc_setSide;
[lo1, "GAR_1"] call gar_fnc_setName;
[lo1, [50, 0, 0]] call gar_fnc_setPos;
[lo1, tNATO] call gar_fnc_setTemplate;
[lo1] call gar_fnc_startThread;
[lo1, T_INF, T_INF_crew, -1] call gar_fnc_addNewUnit;
[lo1, T_INF, T_INF_pilot, -1] call gar_fnc_addNewUnit;
[lo1, T_INF, T_INF_pilot_heli, -1] call gar_fnc_addNewUnit;

[lo0] call gar_fnc_spawnGarrison;
[lo1] call gar_fnc_spawnGarrison;
//[lo0, lo1, [0,1,0]] call gar_fnc_moveUnit;


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