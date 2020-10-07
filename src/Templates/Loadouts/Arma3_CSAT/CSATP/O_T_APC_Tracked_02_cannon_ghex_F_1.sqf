[
    // Initial vehicle class name
    "O_T_APC_Tracked_02_cannon_ghex_F",

    // This code will be called upon vehicle construction
    {
        params ["_veh"];
[
	_veh,
	["GreenHex",1], 
	["showTracks",0.4,"showCamonetHull",0.5,"showBags",0.8,"showSLATHull",0.25]
] call BIS_fnc_initVehicle;
    }
]