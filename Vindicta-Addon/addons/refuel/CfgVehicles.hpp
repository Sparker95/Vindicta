class CfgVehicles {



	class ThingX;
    class All;
    class Static: All {};
    class Building: Static {};
    class NonStrategic: Building {};
    class HouseBase: NonStrategic {};
    class House: HouseBase {};
    class House_F: House {};
    class House_Small_F: House_F {};

    class AllVehicles: All {};
    class Land: AllVehicles {};
    class LandVehicle: Land {};
    class Car: LandVehicle {};

    class Tank: LandVehicle {};

    class Air: AllVehicles {};

    class Helicopter: Air {};

    class Helicopter_Base_F: Helicopter {};
    class Helicopter_Base_H: Helicopter_Base_F {};

    class Plane: Air {};

    class Plane_Base_F: Plane {};

    class Ship: AllVehicles {};

    class Ship_F: Ship {};

    class Boat_Civil_01_base_F: Ship_F {
        jn_fuel_capacity = 200;
    };

    class Boat_F: Ship_F {};

    class Boat_Armed_01_base_F: Boat_F {
        jn_fuel_capacity = 300;
    };
    class Rubber_duck_base_F: Boat_F  {
        jn_fuel_capacity = 30;
    };

    class Car_F: Car {
        jn_fuel_capacity = 60;
    };

    class Kart_01_Base_F: Car_F {
        jn_fuel_capacity = 8;
    };

    class Offroad_01_base_F: Car_F {};

    class Wheeled_APC_F: Car_F {
        jn_fuel_capacity = 300;
    };

    class Hatchback_01_base_F: Car_F {
        jn_fuel_capacity = 50;
    };

    class Quadbike_01_base_F: Car_F {
        jn_fuel_capacity = 10;
    };

    class MRAP_01_base_F: Car_F {
        jn_fuel_capacity = 230;
    };

    class MRAP_02_base_F: Car_F {
        jn_fuel_capacity = 230;
    };

    class MRAP_03_base_F: Car_F {
        jn_fuel_capacity = 230;
    };

    class APC_Wheeled_01_base_F: Wheeled_APC_F {
        jn_fuel_capacity = 269;
    };

    class Truck_F: Car_F {
        jn_fuel_capacity = 400;
    };

    class Truck_01_base_F: Truck_F {
        jn_fuel_capacity = 583;
    };

    class B_Truck_01_transport_F: Truck_01_base_F {};

    class B_Truck_01_mover_F: B_Truck_01_transport_F {};

    class Truck_02_base_F: Truck_F {
        jn_fuel_capacity = 400;
    };

    class Truck_03_base_F: Truck_F {
        jn_fuel_capacity = 600;
    };

    class Van_01_base_F: Truck_F {
        jn_fuel_capacity = 80;
    };

    class Van_01_fuel_base_F: Van_01_base_F {
        jn_fuel_cargoCapacity = 2000;
    };
    class C_Van_01_fuel_F: Van_01_fuel_base_F {
        transportFuel = 0;
    };
    class I_G_Van_01_fuel_F: Van_01_fuel_base_F {
        transportFuel = 0;
    };

    class Tank_F: Tank {
        jn_fuel_capacity = 1200;
    };

    class APC_Tracked_01_base_F: Tank_F {
        jn_fuel_capacity = 1400;
    };

    class B_APC_Tracked_01_base_F: APC_Tracked_01_base_F {};

    class B_APC_Tracked_01_CRV_F: B_APC_Tracked_01_base_F {
        transportFuel = 0;
        jn_fuel_cargoCapacity = 1000;
    };

    class APC_Tracked_02_base_F: Tank_F {
        jn_fuel_capacity = 1000;
    };

    class APC_Tracked_03_base_F: Tank_F {
        jn_fuel_capacity = 660;
    };

    class MBT_01_base_F: Tank_F {
        jn_fuel_capacity = 1400;
    };

    class MBT_02_base_F: Tank_F {
        jn_fuel_capacity = 1100;
    };

    class MBT_03_base_F: Tank_F {
        jn_fuel_capacity = 1160;
    };

    class MBT_01_arty_base_F: MBT_01_base_F {
        jn_fuel_capacity = 830;
    };

    class MBT_02_arty_base_F: MBT_02_base_F {
        jn_fuel_capacity = 830;
    };

    class Heli_Light_02_base_F: Helicopter_Base_H {
        jn_fuel_capacity = 1450;
    };

    class Heli_light_03_base_F: Helicopter_Base_F {
        jn_fuel_capacity = 1004;
    };

    class Heli_Transport_01_base_F: Helicopter_Base_H  {
        jn_fuel_capacity = 1360;
    };

    class Heli_Transport_02_base_F: Helicopter_Base_H {
        jn_fuel_capacity = 3222;
    };

    class Heli_Transport_03_base_F: Helicopter_Base_H {
        jn_fuel_capacity = 3914;
    };

    class Heli_Transport_04_base_F: Helicopter_Base_H {
        jn_fuel_capacity = 3914;
    };

    class Plane_CAS_01_base_F: Plane_Base_F {
        jn_fuel_capacity = 6223;
    };

    class Plane_CAS_02_base_F: Plane_Base_F {
        jn_fuel_capacity = 2099;
    };

    class UAV: Plane {};

    class UAV_02_base_F: UAV {
        jn_fuel_capacity = 270;
    };

    class Plane_Fighter_03_base_F: Plane_Base_F {
        jn_fuel_capacity = 1914;
    };

    class Truck_02_fuel_base_F: Truck_02_base_F {
        transportFuel = 0;
        jn_fuel_cargoCapacity = 10000;
    };
    class Truck_02_water_base_F: Truck_02_fuel_base_F {
        jn_fuel_cargoCapacity = REFUEL_DISABLED_FUEL;
    };

    class B_Truck_01_fuel_F: B_Truck_01_mover_F {
        transportFuel = 0; 
        jn_fuel_cargoCapacity = 10000;
    };

    class O_Truck_03_fuel_F: Truck_03_base_F {
        transportFuel = 0;
        jn_fuel_cargoCapacity = 10000;
    };
	class ReammoBox_F: ThingX {};
	class Slingload_base_F: ReammoBox_F {};
    class Pod_Heli_Transport_04_base_F: Slingload_base_F {};
    class Land_Pod_Heli_Transport_04_fuel_F: Pod_Heli_Transport_04_base_F {
        transportFuel = 0;
        jn_fuel_cargoCapacity = 10000;
    };

    class Slingload_01_Base_F: Slingload_base_F {};
    class B_Slingload_01_Fuel_F: Slingload_01_Base_F {
        transportFuel = 0;
        jn_fuel_cargoCapacity = 10000;
    };

    class O_Heli_Transport_04_fuel_F: Heli_Transport_04_base_F  {
        transportFuel = 0;
        jn_fuel_cargoCapacity = 10000;
    };

    class StorageBladder_base_F: NonStrategic {};
    class Land_StorageBladder_01_F: StorageBladder_base_F {
        transportFuel = 0;
        jn_fuel_cargoCapacity = 60000;
    };

    class FlexibleTank_base_F: ThingX {};
    class Land_FlexibleTank_01_F: FlexibleTank_base_F {
        transportFuel = 0;
        jn_fuel_cargoCapacity = 300;
    };

    class Land_Fuelstation_Feed_F: House_Small_F {
        transportFuel = 0;
        jn_fuel_cargoCapacity = 50000;
    };

    class Land_fs_feed_F: House_Small_F {
        transportFuel = 0;
        jn_fuel_cargoCapacity = 50000;
    };

    class Land_FuelStation_01_pump_F: House_F {
        transportFuel = 0;
        jn_fuel_cargoCapacity = 50000;
    };
    class Land_FuelStation_01_pump_malevil_F: House_F {
        transportFuel = 0;
        jn_fuel_cargoCapacity = 50000;
    };
	
};
