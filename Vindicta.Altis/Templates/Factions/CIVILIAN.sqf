/*
Civilian template for ARMA III
*/

// //==== Infantry ====
_inf = [];
_inf resize T_INF_SIZE;
 _inf set [T_INF_DEFAULT, ["I_L_Looter_SG_F"]];				//Default infantry if nothing is found
for "_i" from 1 to (T_INF_SIZE-1) do {
    _inf set [_i, []];
};
// _inf set [T_INF_SL, ["B_Captain_Dwarden_F"]];
// _inf set [T_INF_TL, ["B_Captain_Dwarden_F"]];
// _inf set [T_INF_officer, ["B_GEN_Commander_F"]];
// _inf set [T_INF_GL, ["B_GEN_Soldier_F"]];
// _inf set [T_INF_rifleman, ["B_GEN_Soldier_F"]];
// _inf set [T_INF_marksman, ["B_GEN_Soldier_F"]];
// _inf set [T_INF_sniper, ["B_GEN_Soldier_F"]];
// _inf set [T_INF_spotter, ["B_GEN_Soldier_F"]];
// _inf set [T_INF_exp, ["B_GEN_Soldier_F"]];
// _inf set [T_INF_ammo, ["B_GEN_Soldier_F"]];
// _inf set [T_INF_LAT, ["B_GEN_Soldier_F"]];
// _inf set [T_INF_AT, ["B_GEN_Soldier_F"]];
// _inf set [T_INF_AA, ["B_GEN_Soldier_F"]];
// _inf set [T_INF_LMG, ["B_GEN_Soldier_F"]];
// _inf set [T_INF_HMG, ["B_GEN_Soldier_F"]];
// _inf set [T_INF_medic, ["B_GEN_Soldier_F"]];
// _inf set [T_INF_engineer, ["B_GEN_Soldier_F"]];
// _inf set [T_INF_crew, ["B_GEN_Soldier_F"]];
// _inf set [T_INF_crew_heli, ["B_GEN_Soldier_F"]];
// _inf set [T_INF_pilot, ["B_GEN_Soldier_F"]];
// _inf set [T_INF_pilot_heli, ["B_GEN_Soldier_F"]];
// _inf set [T_INF_survivor, ["B_GEN_Soldier_F"]];
// _inf set [T_INF_unarmed, ["B_GEN_Soldier_F"]];

//==== Vehicles ====
_veh = +(tDefault select T_VEH);
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_default, [
    "C_Hatchback_01_sport_F",
    "C_Hatchback_01_F",
    "C_Truck_02_box_F",
    "C_Truck_02_fuel_F",
    "C_Offroad_02_unarmed_F",
    "C_Van_01_fuel_F",
    "C_Truck_02_transport_F",
    "C_Truck_02_covered_F",
    "C_Offroad_01_F",
    "C_Offroad_01_repair_F",
    "C_Quadbike_01_F",
    "C_SUV_01_F",
    "C_Van_01_transport_F",
    "C_Van_02_medevac_F",
    "C_Van_02_vehicle_F",
    "C_Van_02_service_F",
    "C_Van_02_transport_F"
]];
_vehWeights = [];
_vehWeights set [T_VEH_SIZE-1, nil];
_vehWeights set [T_VEH_default, [
    5, /* "C_Hatchback_01_sport_F" */
    20, /* "C_Hatchback_01_F" */
    3, /* "C_Truck_02_box_F" */
    0.1, /* "C_Truck_02_fuel_F" */
    10, /* "C_Offroad_02_unarmed_F" */
    0.1, /* "C_Van_01_fuel_F" */
    3, /* "C_Truck_02_transport_F" */
    3, /* "C_Truck_02_covered_F" */
    5, /* "C_Offroad_01_F" */
    0.1, /* "C_Offroad_01_repair_F" */
    1, /* "C_Quadbike_01_F" */
    3, /* "C_SUV_01_F" */
    1, /* "C_Van_01_transport_F" */
    1, /* "C_Van_02_medevac_F" */
    1, /* "C_Van_02_vehicle_F" */
    1, /* "C_Van_02_service_F" */
    1 /* "C_Van_02_transport_F" */
]];
// _veh set [T_VEH_car_unarmed, ["B_MRAP_01_F"]];
// _veh set [T_VEH_car_armed, ["B_MRAP_01_hmg_F"]];
// _veh set [T_VEH_MRAP_unarmed, ["B_MRAP_01_F"]];
// _veh set [T_VEH_MRAP_HMG, ["B_MRAP_01_hmg_F"]];
// _veh set [T_VEH_MRAP_GMG, ["B_MRAP_01_gmg_F"]];
// _veh set [T_VEH_IFV, ["B_APC_Wheeled_01_cannon_F"]]; //Marshal IFV
// _veh set [T_VEH_APC, ["B_APC_Tracked_01_rcws_F"]]; //Panther
// _veh set [T_VEH_MBT, ["B_MBT_01_cannon_F", "B_MBT_01_TUSK_F"]];
// _veh set [T_VEH_MRLS, ["B_MBT_01_mlrs_F"]];
// _veh set [T_VEH_SPA, ["B_MBT_01_arty_F"]];
// _veh set [T_VEH_SPAA, ["B_APC_Tracked_01_AA_F"]];
// _veh set [T_VEH_stat_HMG_high, ["B_HMG_01_high_F"]];
// _veh set [T_VEH_stat_GMG_high, ["B_GMG_01_high_F"]];
// _veh set [T_VEH_stat_HMG_low, ["B_HMG_01_F"]];
// _veh set [T_VEH_stat_GMG_low, ["B_GMG_01_F"]];
// _veh set [T_VEH_stat_AA, ["B_static_AA_F"]];
// _veh set [T_VEH_stat_AT, ["B_static_AT_F"]];
// _veh set [T_VEH_stat_mortar_light, ["B_Mortar_01_F"]];
// //_veh set [T_VEH_stat_mortar_heavy, ["B_Mortar_01_F"]];
// _veh set [T_VEH_heli_light, ["B_Heli_Light_01_F"]];
// _veh set [T_VEH_heli_heavy, ["B_Heli_Transport_01_F"]];
// _veh set [T_VEH_heli_cargo, ["B_Heli_Transport_03_unarmed_F"]];
// _veh set [T_VEH_heli_attack, ["B_Heli_Attack_01_dynamicLoadout_F"]];
// _veh set [T_VEH_plane_attack, ["B_Plane_CAS_01_dynamicLoadout_F"]];
// _veh set [T_VEH_plane_fighter , ["B_Plane_Fighter_01_F"]];
// //_veh set [T_VEH_plane_cargo, [" "]];
// //_veh set [T_VEH_plane_unarmed , [" "]];
// //_veh set [T_VEH_plane_VTOL, [" "]];
// _veh set [T_VEH_boat_unarmed, ["B_Boat_Transport_01_F"]];
// _veh set [T_VEH_boat_armed, ["B_Boat_Armed_01_minigun_F"]];
// _veh set [T_VEH_personal, ["B_GEN_Offroad_01_gen_F"]];
// _veh set [T_VEH_truck_inf, ["B_GEN_Van_02_transport_F"]];
// _veh set [T_VEH_truck_cargo, ["B_GEN_Van_02_vehicle_F"]];
// _veh set [T_VEH_truck_ammo, ["B_Truck_01_ammo_F"]];
// _veh set [T_VEH_truck_repair, ["B_Truck_01_Repair_F"]];
// _veh set [T_VEH_truck_medical , ["B_Truck_01_medical_F"]];
// _veh set [T_VEH_truck_fuel, ["B_Truck_01_fuel_F"]];
// _veh set [T_VEH_submarine, ["B_SDV_01_F"]];


// //==== Drones ====
// +(tDefault select T_DRONE);
// _drone set [T_DRONE_SIZE-1, nil];
// _drone set [T_DRONE_DEFAULT, ["O_UAV_01_F"]];

// _drone set [T_DRONE_UGV_unarmed, ["O_UGV_01_F"]];
// _drone set [T_DRONE_UGV_armed, ["O_UGV_01_rcws_F"]];
// _drone set [T_DRONE_plane_attack, ["O_UAV_02_dynamicLoadout_F"]];
// //_drone set [T_DRONE_plane_unarmed, ["O_UAV_02_dynamicLoadout_F"]];
// //_drone set [T_DRONE_heli_attack, ["O_T_UAV_04_CAS_F"]];
// _drone set [T_DRONE_quadcopter, ["O_UAV_01_F"]];
// _drone set [T_DRONE_designator, ["O_Static_Designator_02_F"]];
// _drone set [T_DRONE_stat_HMG_low, ["O_HMG_01_A_F"]];
// _drone set [T_DRONE_stat_GMG_low, ["O_GMG_01_A_F"]];
// //_drone set [T_DRONE_stat_AA, ["O_SAM_System_04_F"]];

//==== Cargo ====
_cargo = +(tDefault select T_CARGO);

//==== Set arrays ====
_array = [];

_array set [T_SIZE*2-1, nil]; //Make an array having the size equal to the number of categories first

// Name, description, faction, addons, etc
_array set [T_NAME, "tCivilian"];
_array set [T_DESCRIPTION, "Arma 3 Altis civilians"];
_array set [T_DISPLAY_NAME, "Arma III - Altis Civilians"];
_array set [T_FACTION, T_FACTION_Civ];
_array set [T_REQUIRED_ADDONS, ["A3_Characters_F"]];

_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, []];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, []];
_array set [T_VEH+T_WEIGHTS_OFFSET, _vehWeights];

_array
