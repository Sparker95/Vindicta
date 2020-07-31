_array = [];

_array set [T_SIZE-1, nil];									

_array set [T_NAME, "t3CB_CPD"]; 
_array set [T_DESCRIPTION, "Chernarus Police Department. Requires 3CB Factions and RHS"]; 
_array set [T_DISPLAY_NAME, "Chernarus Police"]; 
_array set [T_FACTION, T_FACTION_Police]; 
_array set [T_REQUIRED_ADDONS, [
	"rhs_c_troops",		// RHSAFRF
	"rhsusf_c_troops",	// RHSUSAF
	"rhsgref_c_troops",	// RHSGREF
	"UK3CB_Factions_CPD", // 3CB Factions
	"ace_compat_rhs_afrf3", // ACE Compat - RHS Armed Forces of the Russian Federation
	"ace_compat_rhs_gref3", // ACE Compat - RHS: GREF
	"ace_compat_rhs_usf3" // ACE Compat - RHS United States Armed Forces
]]; 


_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_DEFAULT,  ["UK3CB_CPD_B_PAT"]]; 

_inf set [T_INF_SL, ["UK3CB_CPD_B_ARU_SL", "UK3CB_CPD_B_ARU_TL"]];
_inf set [T_INF_TL, ["UK3CB_TKP_B_TL", "UK3CB_TKP_B_QRF_TL"]];
_inf set [T_INF_officer, ["UK3CB_CPD_B_PAT", "UK3CB_CPD_B_PAT_RIF_BOLT", "UK3CB_CPD_B_PAT_RIF_LITE", "UK3CB_CPD_B_ARU_RIF_1", "UK3CB_CPD_B_ARU_ENG", "UK3CB_CPD_B_ARU_MK", "UK3CB_CPD_B_ARU_MD", "UK3CB_CPD_B_ARU_RIF_2"]];



_veh = []; _veh resize T_VEH_SIZE;
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["UK3CB_CPD_B_TIGR"]]; 

_veh set [T_VEH_car_unarmed, ["UK3CB_CPD_B_TIGR", "UK3CB_CPD_B_TIGR_FFV", "UK3CB_CPD_B_Gaz24", "UK3CB_CPD_B_Offroad_Unarmed", "UK3CB_CPD_B_S1203", "UK3CB_CPD_B_UAZ_Closed", "UK3CB_CPD_B_UAZ_Open", "UK3CB_CPD_B_Hilux_Closed", "UK3CB_CPD_B_Hilux_Open"]]; // = 1 – REQUIRED


_drone = []; _drone resize T_DRONE_SIZE;


_cargo = +(tDefault select T_CARGO);


_group = +(tDefault select T_GROUP);




_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, _drone];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, _group];

_array 