[
    // Initial vehicle class name
    "B_GEN_Van_02_transport_F",

    // This code will be called upon vehicle construction
    {
        params ["_veh"];
[
	_veh,
	["Gendarmerie",1], 
	["Door_1_source",0,"Door_2_source",0,"Door_3_source",0,"Door_4_source",0,"Hide_Door_1_source",0,"Hide_Door_2_source",0,"Hide_Door_3_source",0,"Hide_Door_4_source",0,"lights_em_hide",0,"ladder_hide",0.75,"spare_tyre_holder_hide",0.5,"spare_tyre_hide",0.5,"reflective_tape_hide",0.15,"roof_rack_hide",0.2,"LED_lights_hide",0.15,"sidesteps_hide",0.5,"rearsteps_hide",0.5,"side_protective_frame_hide",0.5,"front_protective_frame_hide",0.15,"beacon_front_hide",0.2,"beacon_rear_hide",0.2]
] call BIS_fnc_initVehicle;

    }
]