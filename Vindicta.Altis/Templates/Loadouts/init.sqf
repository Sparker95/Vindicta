#include "common.hpp"

ADD_LOADOUT("superDude", "superDude.sqf")

//AAF2017
call compile preprocessFileLineNumbers "Templates\Loadouts\RHS_AAF2017\AAF\init.sqf";
call compile preprocessFileLineNumbers "Templates\Loadouts\RHS_AAF2017\AAF_Elite\init.sqf";
call compile preprocessFileLineNumbers "Templates\Loadouts\RHS_AAF2017\AAF_Recon\init.sqf";
call compile preprocessFileLineNumbers "Templates\Loadouts\RHS_AAF2017\AAF_Police\init.sqf";
//RHS_LDF
call compile preprocessFileLineNumbers "Templates\Loadouts\RHS_LDF\LDF\init.sqf";
call compile preprocessFileLineNumbers "Templates\Loadouts\RHS_LDF\LDF_Ranger\init.sqf";
call compile preprocessFileLineNumbers "Templates\Loadouts\RHS_LDF\LDF_Recon\init.sqf";
//RHS_LDF_NATO
call compile preprocessFileLineNumbers "Templates\Loadouts\RHS_LDF_NATO\LDF_NATO\init.sqf";
call compile preprocessFileLineNumbers "Templates\Loadouts\RHS_LDF_NATO\LDF_Police\init.sqf";
call compile preprocessFileLineNumbers "Templates\Loadouts\RHS_LDF_NATO\LDF_Recon_NATO\init.sqf";
