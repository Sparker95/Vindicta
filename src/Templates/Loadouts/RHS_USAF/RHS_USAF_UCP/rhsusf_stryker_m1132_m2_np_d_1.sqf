[
    // Initial vehicle class name
    "rhsusf_stryker_m1132_m2_np_d",

    // This code will be called upon vehicle construction
    {
        params ["_veh"];
[
	_veh,
	["Tan",1], 
	["hide_SMP",1,"SMP",1,"SMP_L",1,"SMP_R",1,"Hide_CIP",1,"Dispenser_Fold",0,"Hatch_Commander",0,"Hatch_Front",0,"Hatch_Left",0,"Hatch_Right",0,"Ramp",0,"Hide_Antenna_1",0,"Hide_Antenna_2",0,"Hide_Antenna_3",0,"Hide_DEK",0,"Hide_DUKE",0,"Hide_ExDiff",0,"Hide_FCans",0,"Hide_WCans",0,"Hide_GPS",0,"Hide_PioKit",0,"Hide_StgBar",0,"Hide_STORM",0,"Hide_SuspCov",0,"Hide_Towbar",0,"Extend_Mirrors",0,"Hatch_Driver",0]
] call BIS_fnc_initVehicle;
    }
]