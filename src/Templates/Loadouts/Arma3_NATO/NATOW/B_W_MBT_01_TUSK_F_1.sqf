[
    // Initial vehicle class name
    "B_W_MBT_01_TUSK_F",

    // This code will be called upon vehicle construction
    {
        params ["_veh"];
        private _randomCamo = selectRandom[0,1];
[
	_veh,
	["Olive",1], 
	["showCamonetTurret",_randomCamo,"showCamonetHull",_randomCamo,"showBags",0.4]
] call BIS_fnc_initVehicle;
    }
]