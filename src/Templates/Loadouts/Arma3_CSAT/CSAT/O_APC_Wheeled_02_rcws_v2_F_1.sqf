[
    // Initial vehicle class name
    "O_APC_Wheeled_02_rcws_v2_F",

    // This code will be called upon vehicle construction
    {
        params ["_veh"];
[
	_veh,
	["Hex",1], 
	["showBags",0.4,"showCanisters",0.7,"showTools",0.6,"showCamonetHull",0.5,"showSLATHull",0.25]
] call BIS_fnc_initVehicle;
    }
]