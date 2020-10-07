[
    // Initial vehicle class name
    "O_APC_Tracked_02_cannon_F",

    // This code will be called upon vehicle construction
    {
        params ["_veh"];
[
	_veh,
	["Hex",1], 
	["showTracks",0.5,"showCamonetHull",0.5,"showBags",0.4,"showSLATHull",0.25]
] call BIS_fnc_initVehicle;
    }
]