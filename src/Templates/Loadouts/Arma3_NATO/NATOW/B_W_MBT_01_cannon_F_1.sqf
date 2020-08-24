[
    // Initial vehicle class name
    "B_W_MBT_01_cannon_F",

    // This code will be called upon vehicle construction
    {
        params ["_veh"];
[
	_veh,
	["Olive",1], 
	["showBags",0.4,"showCamonetTurret",0,"showCamonetHull",0]
] call BIS_fnc_initVehicle;

    }
]