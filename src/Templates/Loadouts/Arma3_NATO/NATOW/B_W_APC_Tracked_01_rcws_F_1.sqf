[
    // Initial vehicle class name
    "B_W_APC_Tracked_01_rcws_F",

    // This code will be called upon vehicle construction
    {
        params ["_veh"];
        private _randomCamo = selectRandom[0,1];
        private _randomSLAT = selectRandom[0,1];
[
	_veh,
	["Olive",1], 
	["showCamonetHull",0.5,"showBags",0.4]
] call BIS_fnc_initVehicle;
    }
]