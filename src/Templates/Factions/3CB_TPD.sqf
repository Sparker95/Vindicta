_array = [];

_array set [T_SIZE-1, nil];									

_array set [T_NAME, "t3CB_TPD"]; 
_array set [T_DESCRIPTION, "Takistan Police Department. Requires 3CB Factions and RHS"]; 
_array set [T_DISPLAY_NAME, "Takistan Police"]; 
_array set [T_FACTION, T_FACTION_Police]; 
_array set [T_REQUIRED_ADDONS, [
	"rhs_c_troops",		// RHSAFRF
	"rhsusf_c_troops",	// RHSUSAF
	"rhsgref_c_troops",	// RHSGREF
	"uk3cb_factions_TKA", // 3CB Factions
	"ace_compat_rhs_afrf3", // ACE Compat - RHS Armed Forces of the Russian Federation
	"ace_compat_rhs_gref3", // ACE Compat - RHS: GREF
	"ace_compat_rhs_usf3" // ACE Compat - RHS United States Armed Forces
]]; 


_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_DEFAULT,  ["UK3CB_TKP_B_RIF_1"]]; 

_inf set [T_INF_SL, ["UK3CB_TKP_B_SL", "UK3CB_TKP_B_QRF_SL"]];
_inf set [T_INF_TL, ["UK3CB_TKP_B_TL", "UK3CB_TKP_B_QRF_TL"]];
_inf set [T_INF_officer, ["UK3CB_TKP_B_RIF_2", "UK3CB_TKP_B_RIF_1", "UK3CB_TKP_B_MK", "UK3CB_TKP_B_MD", "UK3CB_TKP_B_AR", "UK3CB_TKP_B_ENG", "UK3CB_TKP_B_MG", "UK3CB_TKP_B_QRF_AR", "UK3CB_TKP_B_QRF_ENG", "UK3CB_TKP_B_QRF_MG", "UK3CB_TKP_B_QRF_MK", "UK3CB_TKP_B_QRF_MD", "UK3CB_TKP_B_QRF_RIF_1", "UK3CB_TKP_B_QRF_RIF_2"]];



_veh = []; _veh resize T_VEH_SIZE;
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["UK3CB_TKP_B_Datsun_Pickup"]]; 

_veh set [T_VEH_car_unarmed, ["UK3CB_TKP_B_Datsun_Pickup", "UK3CB_TKP_B_Hilux_Closed", "UK3CB_TKP_B_Datsun_Pickup", "UK3CB_TKP_B_Lada_Police", "UK3CB_TKP_B_LandRover_Closed", "UK3CB_TKP_B_LandRover_Open", "UK3CB_TKP_B_Offroad", "UK3CB_TKP_B_UAZ_Closed", "UK3CB_TKP_B_UAZ_Open"]]; // = 1 – REQUIRED


_drone = []; _drone resize T_DRONE_SIZE;


_cargo = +(tDefault select T_CARGO);


_group = +(tDefault select T_GROUP);




_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, _drone];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, _group];

_array 