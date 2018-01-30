T_NAMES = [];

//Infantry names
private _inf = [];
//Main infantry
_inf set [T_INF_default, "Rifleman"]; //		= 0; //Default if nothing found
_inf set [T_INF_SL, "Squad leader"]; //			= 1; //Squad leader
_inf set [T_INF_TL, "Team leader"]; //			= 2; //Team leader
_inf set [T_INF_officer, "Officer"]; //		= 3; //Officer
_inf set [T_INF_GL, "Rifleman GL"]; //			= 4; //GL soldier
_inf set [T_INF_rifleman, "Rifleman"]; //		= 5; //Basic rifleman
_inf set [T_INF_marksman, "Marksman"]; //		= 6; //Marksman
_inf set [T_INF_sniper, "Sniper"]; //		= 7; //Sniper
_inf set [T_INF_spotter, "Spotter"]; //		= 8; //Spotter
_inf set [T_INF_exp, "Demo specialist"]; //			= 9; //Demo specialist
_inf set [T_INF_ammo, "Ammo bearer"]; //			= 10; //Ammo bearer
_inf set [T_INF_LAT, "Rifleman AT"]; //			= 11; //Light AT
_inf set [T_INF_AT, "AT Specialist"]; //			= 12; //AT
_inf set [T_INF_AA, "AA Specialist"]; //			= 13; //Anti-Air
_inf set [T_INF_LMG, "Machine Gunner"]; //			= 14; //Light machinegunner
_inf set [T_INF_HMG, "Heavy Machine Gunner"]; //			= 15; //Heavy machinegunner
_inf set [T_INF_medic, "Medic"]; //			= 16; //Medic
_inf set [T_INF_engineer, "Engineer"]; //		= 17; //Engineer
_inf set [T_INF_crew, "Crewman"]; //			= 18; //Crewman
_inf set [T_INF_crew_heli, "Heli. Crewman"]; //		= 19; //Helicopter crew
_inf set [T_INF_pilot, "Pilot"]; //			= 20; //Plane pilot
_inf set [T_INF_pilot_heli, "Heli. Pilot"]; //	= 21; //Helicopter pilot
_inf set [T_INF_survivor, "Survivor"]; //		= 22; //Survivor
_inf set [T_INF_unarmed, "Unarmed"]; //		= 23; //Unarmed man

//Recon
_inf set [T_INF_recon_TL, "Recon Team Leader"]; //			= 24; //Recon team leader
_inf set [T_INF_recon_rifleman, "Recon Rifleman"]; //	= 25; //Recon scout
_inf set [T_INF_recon_medic, "Recon Medic"]; //		= 26; //Recon medic
_inf set [T_INF_recon_exp, "Recon Explosive Specialist"]; //			= 27; //Recon demo specialist
_inf set [T_INF_recon_LAT, "Recon Rifleman AT"]; //			= 28; //Recon light AT
_inf set [T_INF_recon_marksman, "Recon Marksman"]; //	= 29; //Recon marksman
_inf set [T_INF_recon_JTAC, "Recon JTAC"]; //		= 30; //Recon JTAC

//Divers
_inf set [T_INF_diver_TL, "Diver Team Leader"]; //			= 31; //Diver team leader
_inf set [T_INF_diver_rifleman, "Diver Rifleman"]; //	= 32; //Diver rifleman
_inf set [T_INF_diver_exp, "Diver Explosive Specialist"]; //			= 33; //Diver explosive specialist

T_NAMES set [T_INF, _inf];
