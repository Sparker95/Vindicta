#include "..\common.h"

// Initialize loot tables
CALL_COMPILE_COMMON("Templates\Loot\init.sqf");

// Initialize loot weight per each soldier subcategory
T_LootWeight = [];
T_LootWeight resize T_INF_SIZE;

// These are weights of weapons found in ammo boxes
// These are not probabilities,
// final probabilities will be normalized later

T_LootWeight set [T_INF_default,    0];	//Default if nothing found
T_LootWeight set [T_INF_SL,         20];	/*Squad leader*/
T_LootWeight set [T_INF_TL,         10];	//Team leader
T_LootWeight set [T_INF_officer,    1]; //Officer
T_LootWeight set [T_INF_GL,         15];	//GL soldier
T_LootWeight set [T_INF_rifleman,   100]; //Basic rifleman
T_LootWeight set [T_INF_marksman,   20]; //Marksman
T_LootWeight set [T_INF_sniper,     7];	//Sniper
T_LootWeight set [T_INF_spotter,    5];	//Spotter
T_LootWeight set [T_INF_exp,        10]; //Demo specialist
T_LootWeight set [T_INF_ammo,       5];	//Ammo bearer
T_LootWeight set [T_INF_LAT,        20];	//Light AT
T_LootWeight set [T_INF_AT,         20]; //AT
T_LootWeight set [T_INF_AA,         8]; //Anti-Air
T_LootWeight set [T_INF_LMG,        20]; //Light machinegunner
T_LootWeight set [T_INF_HMG,        10]; //Heavy machinegunner
T_LootWeight set [T_INF_medic,      25]; //Medic
T_LootWeight set [T_INF_engineer,   10]; //Engineer
T_LootWeight set [T_INF_crew,       0]; //Crewman
T_LootWeight set [T_INF_crew_heli,  0];	//Helicopter crew
T_LootWeight set [T_INF_pilot,      0];	//Plane pilot
T_LootWeight set [T_INF_pilot_heli, 0];	//Helicopter pilot
T_LootWeight set [T_INF_survivor,   0]; //Survivor
T_LootWeight set [T_INF_unarmed,    0]; //Unarmed man

//Recon
T_LootWeight set [T_INF_recon_TL,   3];	//Recon team leader
T_LootWeight set [T_INF_recon_rifleman, 3];	//Recon scout
T_LootWeight set [T_INF_recon_medic,    3];	//Recon medic
T_LootWeight set [T_INF_recon_exp,      3];	//Recon demo specialist
T_LootWeight set [T_INF_recon_LAT,      3];	//Recon light AT
T_LootWeight set [T_INF_recon_marksman, 3];	//Recon marksman
T_LootWeight set [T_INF_recon_JTAC,     3];	//Recon JTAC

//Divers
T_LootWeight set [T_INF_diver_TL,       0];	//Diver team leader
T_LootWeight set [T_INF_diver_rifleman, 0];	//Diver rifleman
T_LootWeight set [T_INF_diver_exp,      0];	//Diver explosive specialist

// Normalize values
private _sum = 0;
{
    _sum = _sum + _x;
} forEach T_LootWeight;
{
    T_LootWeight set [_forEachIndex, _x/_sum];
} forEach T_LootWeight;
