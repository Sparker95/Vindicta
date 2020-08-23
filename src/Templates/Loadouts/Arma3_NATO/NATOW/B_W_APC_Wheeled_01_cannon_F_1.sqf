[
    // Initial vehicle class name
    "B_W_APC_Wheeled_01_cannon_F",

    // This code will be called upon vehicle construction
    {
        params ["_veh"];
        private _randomCamo = selectRandom[0,1];
        private _randomSLAT = selectRandom[0,1];
[
	_veh,
	["Olive",1], 
	["showBags",0.4,"showCamonetHull",_randomCamo,"showCamonetTurret",_randomCamo,"showSLATHull",_randomSLAT,"showSLATTurret",_randomSLAT]
] call BIS_fnc_initVehicle;
    }
]