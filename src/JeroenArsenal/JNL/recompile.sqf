//TODO remove me!

//main
jn_fnc_logistics_init = COMPILE_COMMON("JeroenArsenal\JNL\fn_logistics_init.sqf");
jn_fnc_logistics_load = COMPILE_COMMON("JeroenArsenal\JNL\fn_logistics_load.sqf");
jn_fnc_logistics_unLoad = COMPILE_COMMON("JeroenArsenal\JNL\fn_logistics_unLoad.sqf");
jn_fnc_logistics_addAction = COMPILE_COMMON("JeroenArsenal\JNL\fn_logistics_addAction.sqf");
jn_fnc_logistics_removeAction = COMPILE_COMMON("JeroenArsenal\JNL\fn_logistics_removeAction.sqf");

//functions
//jn_fnc_logistics_canLoad = COMPILE_COMMON("JeroenArsenal\JNL\functions\fn_logistics_canLoad.sqf");
//jn_fnc_logistics_getCargo = COMPILE_COMMON("JeroenArsenal\JNL\functions\fn_logistics_getCargo.sqf");
//jn_fnc_logistics_getCargoType = COMPILE_COMMON("JeroenArsenal\JNL\functions\fn_logistics_getCargoType.sqf");
//jn_fnc_logistics_getNodes = COMPILE_COMMON("JeroenArsenal\JNL\functions\fn_logistics_getNodes.sqf");

//Actions
jn_fnc_logistics_addActionGetInWeapon = COMPILE_COMMON("JeroenArsenal\JNL\Actions\fn_logistics_addActionGetInWeapon.sqf");
jn_fnc_logistics_addActionLoad = COMPILE_COMMON("JeroenArsenal\JNL\Actions\fn_logistics_addActionLoad.sqf");
jn_fnc_logistics_addActionUnload = COMPILE_COMMON("JeroenArsenal\JNL\Actions\fn_logistics_addActionUnload.sqf");
jn_fnc_logistics_addEventGetOutWeapon = COMPILE_COMMON("JeroenArsenal\JNL\Actions\fn_logistics_addEventGetOutWeapon.sqf");

jn_fnc_logistics_removeActionGetInWeapon = COMPILE_COMMON("JeroenArsenal\JNL\Actions\fn_logistics_removeActionGetInWeapon.sqf");
jn_fnc_logistics_removeActionLoad = COMPILE_COMMON("JeroenArsenal\JNL\Actions\fn_logistics_removeActionLoad.sqf");
jn_fnc_logistics_removeActionUnload = COMPILE_COMMON("JeroenArsenal\JNL\Actions\fn_logistics_removeActionUnload.sqf");
jn_fnc_logistics_removeEventGetOutWepon = COMPILE_COMMON("JeroenArsenal\JNL\Actions\fn_logistics_removeEventGetOutWeapon.sqf");

call jn_fnc_logistics_init;

/*
CALL_COMPILE_COMMON("JeroenArsenal\JNL\recompile.sqf");
cursorObject call jn_fnc_logistics_addAction;
*/
