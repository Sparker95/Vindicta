[
    // Initial vehicle class name
    "O_T_APC_Wheeled_02_rcws_v2_ghex_F",

    // This code will be called upon vehicle construction
    {
        params ["_veh"];
[
	_veh,
	["GreenHex",1], 
	["showBags",0.5,"showCanisters",0.5,"showTools",0.4,"showCamonetHull",0.5,"showSLATHull",0.25]
] call BIS_fnc_initVehicle;
    }
]