[
    // Initial vehicle class name
    "I_APC_Wheeled_03_cannon_F",

    // This code will be called upon vehicle construction
    {
        params ["_veh"];
[
	_veh,
	["Indep",1], 
	["showCamonetHull",0.5,"showBags",0.5,"showBags2",0.5,"showTools",0.5,"showSLATHull",0.25]
] call BIS_fnc_initVehicle;
    }
]