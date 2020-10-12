[
    // Initial vehicle class name
    "B_T_APC_Wheeled_01_cannon_F",

    // This code will be called upon vehicle construction
    {
        params ["_veh"];
[
	_veh,
	["Olive",1], 
	["showBags",0.4,"showCamonetHull",1,"showCamonetTurret",1,"showSLATHull",0,"showSLATTurret",0]
] call BIS_fnc_initVehicle;
    }
]