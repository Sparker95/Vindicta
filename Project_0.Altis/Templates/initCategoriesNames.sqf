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

private _veh = [];
_veh set [T_VEH_default, "Unknown Vehicle"];
_veh set [T_VEH_car_unarmed, "Unarmed Car"]; //	= 1; //Car like Prowler or UAZ
_veh set [T_VEH_car_armed, "Armed Car"]; //		= 2;
_veh set [T_VEH_MRAP_unarmed, "Unarmed MRAP"];//	= 3; //MRAP
_veh set [T_VEH_MRAP_HMG, "HMG MRAP"];//		= 4;
_veh set [T_VEH_MRAP_GMG, "GMG MRAP"];//		= 5;
_veh set [T_VEH_IFV, "IVF"];//			= 6;
_veh set [T_VEH_APC, "APC"];//			= 7;
_veh set [T_VEH_MBT, "Tank"];//			= 8; //Main Battle Tank
_veh set [T_VEH_MRLS, "MRLS"];//			= 9; //Multiple Rocket Launch System
_veh set [T_VEH_SPA, "Self-Propelled Artillery"];//			= 10; //Self-Propelled Artillery
_veh set [T_VEH_SPAA, "Self-Propelled Anti-Aircraft"];//			= 11; //Self-Propelled Anti-Aircraft system
_veh set [T_VEH_stat_HMG_high, "Static HMG"];//	= 12;
_veh set [T_VEH_stat_GMG_high, "Static GMG"];// = 13;
_veh set [T_VEH_stat_HMG_low, "Static HMG"];//	= 14;
_veh set [T_VEH_stat_GMG_low, "Static GMG"];//	= 15;
_veh set [T_VEH_stat_AA, "Static AA"];//		= 16;
_veh set [T_VEH_stat_AT, "Static AT"];//		= 17;
_veh set [T_VEH_stat_mortar_light, "Static Mortar"];// = 18; //Light mortar
_veh set [T_VEH_stat_mortar_heavy, "Static Heavy Mortar"];// = 19; //Heavy mortar, because RHS has some
_veh set [T_VEH_heli_light, "Light Helicopter"];//	= 20; //Light transport helicopter for infantry
_veh set [T_VEH_heli_heavy, "Heavy Helicopter"];//	= 21; //Heavy transport helicopter, both for cargo and infantry
_veh set [T_VEH_heli_cargo, "Cargo Helicopter"];//	= 22; //Heavy transport helicopter only for cargo
_veh set [T_VEH_heli_attack, "Attach Helicopter"];//	= 23; //Attack helicopter
_veh set [T_VEH_plane_attack, "Attack Plane"];//	= 24; //Attack plane, mainly for air-to-ground
_veh set [T_VEH_plane_fighter, "Figter Plane"];// = 25; //Fighter plane
_veh set [T_VEH_plane_cargo, "Cargo Plane"];//	= 26; //Cargo plane
_veh set [T_VEH_plane_unarmed, "Unarmed Plane"];// = 27; //Light unarmed plane like cessna
_veh set [T_VEH_plane_VTOL, "VTOL"];//	= 28; //VTOL
_veh set [T_VEH_boat_unarmed, "Unarmed Boat"];//	= 29; //Unarmed boat
_veh set [T_VEH_boat_armed, "Armed Boat"];//	= 30; //Armed boat
_veh set [T_VEH_personal, "Personal Vehicle"];//		= 31; //Quad bike or something for 1-2 men personal transport
_veh set [T_VEH_truck_inf, "Infantry Truck"];//		= 32; //Truck for infantry transport
_veh set [T_VEH_truck_cargo, "Cargo Truck"];//	= 33; //Truck for general cargo transport
_veh set [T_VEH_truck_ammo, "Ammo Truck"];//	= 34; //Ammo truck
_veh set [T_VEH_truck_repair, "Repair Truck"];//	= 35; //Repair truck
_veh set [T_VEH_truck_medical, "Medical Truck"];// = 36; //Medical truck
_veh set [T_VEH_truck_fuel, "Fuel Truck"];//	= 37; //Fuel truck
_veh set [T_VEH_submarine, "Submarine"];//		= 38; //Submarine

T_NAMES set [T_VEH, _veh];