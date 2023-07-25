_array = [];

_array set [T_SIZE-1, nil];

// Name, description, faction, addons, etc
_array set [T_NAME, "tSPE_US_Army_police_IFA3"];
_array set [T_DESCRIPTION, "World War 2 US Army made using content from Spearhead 1944 DLC + Iron Front."];
_array set [T_DISPLAY_NAME, "SPE DLC + IFA3 - US Army (Police)"];
_array set [T_FACTION, T_FACTION_Police];
_array set [T_REQUIRED_ADDONS, [
		"A3_Characters_F",
		"WW2_SPE_Core_c_Core_c",
		"WW2_Core_c_WW2_Core_c"
		]];

//==== API ====

//==== Infantry ====
_inf = []; _inf resize T_INF_size;
_inf set [T_INF_SIZE-1, nil];
_inf set [T_INF_default, ["SPE_US_Rifleman"]];

_inf set [T_INF_SL, ["SPE_US_Rifleman"]];
_inf set [T_INF_TL, ["SPE_US_Rifleman"]];
_inf set [T_INF_officer, ["SPE_US_Rifleman"]];

//==== Vehicles ====
_veh = []; _veh resize T_VEH_SIZE;
_veh set [T_VEH_DEFAULT, ["LIB_US_Willys_MB"]];
_veh set [T_VEH_car_unarmed, ["LIB_US_Willys_MB_Hood"]];

//==== Drones ====
_drone = []; _drone resize T_DRONE_SIZE;
_drone set [T_DRONE_SIZE-1, nil];

//==== Cargo ====
_cargo = +(tDefault select T_CARGO);

//==== Groups ====
_group = +(tDefault select T_GROUP);

//==== API ====
_api = []; _api resize T_API_SIZE;
_api set [T_API_SIZE-1, nil];
_api set [T_API_fnc_VEH_siren, {}];

//==== Arrays ====
_array set [T_API, _api];
_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, _drone];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, _group];

_array