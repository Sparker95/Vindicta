class CfgVehicles {

	class ReammoBox_F;
	class FIA_Box_Base_F;
	class CargoNet_01_ammo_base_F;
	class B_supplyCrate_F;

	class IG_supplyCrate_F : ReammoBox_F {
		maximumLoad = 40000; // 10x
	};

	class Box_Syndicate_Ammo_F : ReammoBox_F {
		maximumLoad = 10000; // 10x
	};

	class Box_FIA_Support_F : FIA_Box_Base_F {
		maximumLoad = 20000; // 10x
	};

	class B_CargoNet_01_ammo_F : CargoNet_01_ammo_base_F {
		maximumLoad = 220000; // 10x
	};

	class I_supplyCrate_F : B_supplyCrate_F {
		maximumLoad = 40000; // 10x
	};

};