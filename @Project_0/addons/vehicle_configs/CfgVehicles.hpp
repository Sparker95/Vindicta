class CfgVehicles {
	class LandVehicle;
	class Truck_03_base_F;
    class O_Truck_03_ammo_F: Truck_03_base_F {
        transportAmmo = 0;
        jn_transportAmmo = 12000;
    };

    class Truck_02_base_F;
    class Truck_02_Ammo_base_F: Truck_02_base_F {
        transportAmmo = 0;
       jn_transportAmmo = 12000;
    };

    class B_Truck_01_mover_F;
    class B_Truck_01_ammo_F: B_Truck_01_mover_F {
        transportAmmo = 0;
        jn_transportAmmo = 12000;
    };

    class B_APC_Tracked_01_base_F;
    class B_APC_Tracked_01_CRV_F: B_APC_Tracked_01_base_F {
        transportAmmo = 0;
        jn_transportAmmo = 12000;
    };

    class Heli_Transport_04_base_F;
    class O_Heli_Transport_04_ammo_F: Heli_Transport_04_base_F {
        transportAmmo = 0;
        jn_transportAmmo = 12000;
    };

    class Pod_Heli_Transport_04_base_F;
    class Land_Pod_Heli_Transport_04_ammo_F: Pod_Heli_Transport_04_base_F {
        transportAmmo = 0;
        jn_transportAmmo = 12000;
    };

    class Slingload_01_Base_F;
    class B_Slingload_01_Ammo_F: Slingload_01_Base_F {
        transportAmmo = 0;
        jn_transportAmmo = 12000;
    };

    class ReammoBox_F;
    class NATO_Box_Base: ReammoBox_F{};
    class Box_NATO_AmmoVeh_F: NATO_Box_Base {
        transportAmmo = 0;
        jn_transportAmmo = 12000;
    };
    class EAST_Box_Base: ReammoBox_F{};
    class Box_East_AmmoVeh_F: EAST_Box_Base {
        transportAmmo = 0;
        jn_transportAmmo = 12000;
    };
    class IND_Box_Base: ReammoBox_F{};
    class Box_IND_AmmoVeh_F: IND_Box_Base {
        transportAmmo = 0;
        jn_transportAmmo = 12000;
    };
	
}