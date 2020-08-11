
//██╗     ██████╗ ███████╗
//██║     ██╔══██╗██╔════╝
//██║     ██║  ██║█████╗  
//██║     ██║  ██║██╔══╝  
//███████╗██████╔╝██║     
//╚══════╝╚═════╝ ╚═╝ 
//http://patorjk.com/software/taag/#p=display&v=3&f=ANSI%20Shadow&t=LDF

//Updated: March 2020 by Marvis


_array = [];

_array set [T_SIZE-1, nil];

_array set [T_NAME, "tLDF"]; 														//Template name + variable (not displayed)
_array set [T_DESCRIPTION, "Standard Livonian Defense Forces from Contact DLC."]; 	//Template display description
_array set [T_DISPLAY_NAME, "Arma 3 LDF"]; 											//Template display name
_array set [T_FACTION, T_FACTION_Military]; 										//Faction type: police, T_FACTION_military, T_FACTION_Police
_array set [T_REQUIRED_ADDONS, ["A3_Characters_F"]]; 								//Addons required to play this template

//==== Infantry ====
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_default,  ["I_E_Soldier_F"]];							//Default infantry if nothing is found

_inf set [T_INF_SL, ["I_E_Soldier_SL_F"]];
_inf set [T_INF_TL, ["I_E_Soldier_TL_F", 2, "I_E_RadioOperator_F", 1]];
_inf set [T_INF_officer, ["I_E_Officer_F"]];
_inf set [T_INF_GL, ["I_E_Soldier_GL_F"]];
_inf set [T_INF_rifleman, ["I_E_Soldier_F", 3, "I_E_Soldier_lite_F", 1, "I_E_Soldier_Pathfinder_F", 1]];
_inf set [T_INF_marksman, ["I_E_Soldier_M_F"]];
_inf set [T_INF_sniper, ["Arma3_LDF_sniper"]];
_inf set [T_INF_spotter, ["Arma3_LDF_spotter"]];
_inf set [T_INF_exp, ["I_E_Soldier_exp_F", "I_E_soldier_Mine_F"]];
_inf set [T_INF_ammo, ["I_E_Soldier_A_F"]];
_inf set [T_INF_LAT, ["I_E_Soldier_LAT2_F"]];
_inf set [T_INF_AT, ["I_E_Soldier_LAT_F", 5, "I_E_Soldier_AT_F", 1]];
_inf set [T_INF_AA, ["I_E_Soldier_AA_F"]];
_inf set [T_INF_LMG, ["I_E_Soldier_AR_F"]];
_inf set [T_INF_HMG, ["Arma3_LDF_HMG"]];
_inf set [T_INF_medic, ["I_E_Medic_F"]];
_inf set [T_INF_engineer, ["I_E_Engineer_F", "I_E_Soldier_Repair_F"]];
_inf set [T_INF_crew, ["I_E_Crew_F"]];
_inf set [T_INF_crew_heli, ["I_E_Helicrew_F"]];
_inf set [T_INF_pilot, ["Arma3_LDF_pilot"]];
_inf set [T_INF_pilot_heli, ["I_E_Helipilot_F"]];
_inf set [T_INF_survivor, ["I_E_Survivor_F"]];
_inf set [T_INF_unarmed, ["I_E_Soldier_unarmed_F"]];
//==== Recon ====
_inf set [T_INF_recon_TL, ["Arma3_LDF_recon_TL"]];
_inf set [T_INF_recon_rifleman, ["Arma3_LDF_recon_rifleman", 3, "Arma3_LDF_recon_autorifleman", 1]];
_inf set [T_INF_recon_medic, ["Arma3_LDF_recon_medic"]];
_inf set [T_INF_recon_exp, ["Arma3_LDF_recon_explosives"]];
_inf set [T_INF_recon_LAT, ["Arma3_LDF_recon_LAT"]];
//_inf set [T_INF_recon_LMG, ["Arma3_LDF_recon_autorifleman"]]; // There is no T_INF_recon_LMG right now
_inf set [T_INF_recon_marksman, ["Arma3_LDF_recon_marksman"]];
_inf set [T_INF_recon_JTAC, ["Arma3_LDF_recon_JTAC"]];
//==== Drivers ====
_inf set [T_INF_diver_TL, ["I_diver_TL_F"]];
_inf set [T_INF_diver_rifleman, ["I_diver_F"]];
_inf set [T_INF_diver_exp, ["I_diver_exp_F"]];


//==== Vehicles ====
_veh = []; _veh resize T_VEH_SIZE;
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["I_E_Offroad_01_F"]];

_veh set [T_VEH_car_unarmed, ["I_E_Offroad_01_F", "I_E_Offroad_01_comms_F", "I_E_Offroad_01_covered_F"]];
_veh set [T_VEH_car_armed, ["I_G_Offroad_01_armed_F"]];

_veh set [T_VEH_MRAP_unarmed, ["B_T_MRAP_01_F"]];
_veh set [T_VEH_MRAP_HMG, ["B_T_MRAP_01_hmg_F"]];
_veh set [T_VEH_MRAP_GMG, ["B_T_MRAP_01_gmg_F"]];

_veh set [T_VEH_IFV, ["B_T_APC_Wheeled_01_cannon_F", "I_E_APC_tracked_03_cannon_F"]];
_veh set [T_VEH_APC, ["B_T_APC_Tracked_01_rcws_F"]];
_veh set [T_VEH_MBT, ["B_MBT_01_cannon_F", "B_MBT_01_TUSK_F"]];
_veh set [T_VEH_MRLS, ["I_E_Truck_02_MRL_F"]];
_veh set [T_VEH_SPA, ["B_MBT_01_arty_F"]];
_veh set [T_VEH_SPAA, ["B_APC_Tracked_01_AA_F"]];

_veh set [T_VEH_stat_HMG_high, ["I_E_HMG_01_high_F", 1,"I_HMG_02_high_F", 4]];
_veh set [T_VEH_stat_GMG_high, ["I_E_GMG_01_high_F"]];
_veh set [T_VEH_stat_HMG_low, ["I_E_HMG_01_F"]];
_veh set [T_VEH_stat_GMG_low, ["I_E_GMG_01_F"]];
_veh set [T_VEH_stat_AA, ["I_E_static_AA_F"]];
_veh set [T_VEH_stat_AT, ["I_E_static_AT_F", "ace_dragon_staticAssembled"]];
_veh set [T_VEH_stat_mortar_light, ["I_E_Mortar_01_F"]];
//_veh set [T_VEH_stat_mortar_heavy, ["I_Mortar_01_F"]];

_veh set [T_VEH_heli_light, ["B_Heli_Light_01_F"]];
_veh set [T_VEH_heli_heavy, ["I_E_Heli_light_03_unarmed_F", "B_Heli_Transport_01_F"]];
_veh set [T_VEH_heli_cargo, ["B_Heli_Transport_03_unarmed_F"]];
_veh set [T_VEH_heli_attack, ["I_E_Heli_light_03_dynamicLoadout_F", "B_Heli_Light_01_dynamicLoadout_F"]];

_veh set [T_VEH_plane_attack, ["B_Plane_CAS_01_dynamicLoadout_F"]];
_veh set [T_VEH_plane_fighter , ["B_Plane_Fighter_01_F"]];
//_veh set [T_VEH_plane_cargo, [""]];
//_veh set [T_VEH_plane_unarmed , [""]];
//_veh set [T_VEH_plane_VTOL, [""]];

_veh set [T_VEH_boat_unarmed, ["B_Boat_Transport_01_F"]];
_veh set [T_VEH_boat_armed, ["B_Boat_Armed_01_minigun_F"]];

_veh set [T_VEH_personal, ["I_E_Quadbike_01_F"]];

_veh set [T_VEH_truck_inf, ["I_E_Truck_02_F", "I_E_Truck_02_transport_F", "I_E_Van_02_transport_F"]];
_veh set [T_VEH_truck_cargo, ["I_E_Truck_02_F", "I_E_Van_02_vehicle_F"]];
_veh set [T_VEH_truck_ammo, ["I_E_Truck_02_ammo_F"]];
_veh set [T_VEH_truck_repair, ["I_E_Truck_02_box_F"]];
_veh set [T_VEH_truck_medical , ["I_E_Truck_02_medical_F", "I_E_Van_02_medevac_F"]];
_veh set [T_VEH_truck_fuel, ["I_E_Truck_02_fuel_F"]];

_veh set [T_VEH_submarine, ["I_SDV_01_F"]];


//==== Drones ====
_drone = []; _drone resize T_DRONE_SIZE;
_drone set [T_DRONE_SIZE-1, nil];
_drone set [T_DRONE_DEFAULT, ["I_E_UGV_01_F"]];
_drone set [T_DRONE_UGV_unarmed, ["I_E_UGV_01_F"]];
_drone set [T_DRONE_UGV_armed, ["I_E_UGV_01_rcws_F"]];
//_drone set [T_DRONE_plane_attack, ["I_UAV_02_dynamicLoadout_F"]];
//_drone set [T_DRONE_plane_unarmed, ["I_UAV_02_dynamicLoadout_F"]];
//_drone set [T_DRONE_heli_attack, ["I_UAV_02_dynamicLoadout_F"]];
_drone set [T_DRONE_quadcopter, ["I_E_UAV_01_F"]];
//_drone set [T_DRONE_designator, ["I_UAV_02_dynamicLoadout_F"]];
_drone set [T_DRONE_stat_HMG_low, ["I_E_HMG_01_A_F"]];
_drone set [T_DRONE_stat_GMG_low, ["I_E_GMG_01_A_F"]];
//_drone set [T_DRONE_stat_AA, ["I_E_SAM_System_03_F"]];

//==== Cargo ====
_cargo = +(tDefault select T_CARGO);

// Note that we have increased their capacity through the addon, other boxes are going to have reduced capacity
//_cargo set [T_CARGO_default,	["I_supplyCrate_F"]];
//_cargo set [T_CARGO_box_small,	["Box_Syndicate_Ammo_F"]];
//_cargo set [T_CARGO_box_medium,	["I_supplyCrate_F"]];
//_cargo set [T_CARGO_box_big,	["B_CargoNet_01_ammo_F"]];


//==== Groups ====
_group = +(tDefault select T_GROUP);

//==== Arrays ====
_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, _drone];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, _group];

_array