[
    // Initial vehicle class name
    "B_T_MBT_01_TUSK_F",

    // This code will be called upon vehicle construction
    {
        params ["_veh"];
[
	_veh,
	["Olive",1], 
	["showCamonetTurret",0,"showCamonetHull",0,"showBags",0.35]
] call BIS_fnc_initVehicle;
    }
]