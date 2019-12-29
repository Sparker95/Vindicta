class Extended_PreStart_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_preStart));
    };
};

class Extended_PreInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_preInit));
    };
};


class Extended_Init_EventHandlers {
    //fuel
    class Car{
        class JN_fuel {
            init = "_this call jn_fnc_fuel_vehicleInit";
        };
    };
    class Tank{
        class JN_fuel {
            init = "_this call jn_fnc_fuel_vehicleInit";
        };
    };
    class Plane{
        class JN_fuel {
            init = "_this call jn_fnc_fuel_vehicleInit";
        };
    };
    class Helicopter{
        class JN_fuel {
            init = "_this call jn_fnc_fuel_vehicleInit";
        };
    };
    class ship{
        class JN_fuel {
            init = "_this call jn_fnc_fuel_vehicleInit";
        };
    };

    //cargo fuel
    class Van_01_fuel_base_F {
        class JN_fuel_cargo {
            init = "_this call jn_fnc_fuel_vehicleInit";
        };
    };
	class B_APC_Tracked_01_CRV_F {
        class JN_fuel_cargo {
            init = "_this call jn_fnc_fuel_vehicleInit";
        };
    };
	class Truck_02_fuel_base_F {
        class JN_fuel_cargo {
            init = "_this call jn_fnc_fuel_vehicleInit";
        };
    };
	class Truck_02_water_base_F {
        class JN_fuel_cargo {
            init = "_this call jn_fnc_fuel_vehicleInit";
        };
    };
	class B_Truck_01_fuel_F {
        class JN_fuel_cargo {
            init = "_this call jn_fnc_fuel_vehicleInit";
        };
    };
	class O_Truck_03_fuel_F {
        class JN_fuel_cargo {
            init = "_this call jn_fnc_fuel_vehicleInit";
        };
    };
	class Land_Pod_Heli_Transport_04_fuel_F {
        class JN_fuel_cargo {
            init = "_this call jn_fnc_fuel_vehicleInit";
        };
    };
	class B_Slingload_01_Fuel_F {
        class JN_fuel_cargo {
            init = "_this call jn_fnc_fuel_vehicleInit";
        };
    };
	class O_Heli_Transport_04_fuel_F {
        class JN_fuel_cargo {
            init = "_this call jn_fnc_fuel_vehicleInit";
        };
    };
	class Land_StorageBladder_01_F {
        class JN_fuel_cargo {
            init = "_this call jn_fnc_fuel_vehicleInit";
        };
    };
	class Land_FlexibleTank_01_F {
        class JN_fuel_cargo {
            init = "_this call jn_fnc_fuel_vehicleInit";
        };
    };
	class Land_Fuelstation_Feed_F {
        class JN_fuel_cargo {
            init = "_this call jn_fnc_fuel_vehicleInit";
        };
    };
	class Land_fs_feed_F {
        class JN_fuel_cargo {
            init = "_this call jn_fnc_fuel_vehicleInit";
        };
    };
	class Land_FuelStation_01_pump_F {
        class JN_fuel_cargo {
            init = "_this call jn_fnc_fuel_vehicleInit";
        };
    };
	class Land_FuelStation_01_pump_malevil_F {
        class JN_fuel_cargo {
            init = "_this call jn_fnc_fuel_vehicleInit";
        };
    };
};