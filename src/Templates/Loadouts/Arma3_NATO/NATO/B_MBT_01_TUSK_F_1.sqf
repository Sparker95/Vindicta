[
    // Initial vehicle class name
    "B_MBT_01_cannon_F",

    // This code will be called upon vehicle construction
    {
        params ["_veh"];
[
	_veh,
	["Sand",1], 
	["showCamonetTurret",0,"showCamonetHull",0,"showBags",0.2]
] call BIS_fnc_initVehicle;
    }
]