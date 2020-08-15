// Should be included into the config file
// Stores objects for the build UI

// Macro for simple objects in build UI, which only have a cost and build resource
#define __BUILD_OBJECT_CLASS(_cfgCat, _cfgVehClassName, _buildResource) class _cfgCat##_cfgVehClassName : BuildObjectBase { \
	className = #_cfgVehClassName; \
	buildResource = _buildResource; \
}
// Object that maps to a faction template item by category and subcategory ids
#define __BUILD_OBJECT_CLASS_CAT(_cfgCat, _cfgVehClassName, _buildResource, _catID, _subCatID) class _cfgCat##_cfgVehClassName : BuildObjectBase { \
	className = #_cfgVehClassName; \
	buildResource = _buildResource; \
	templateCatID = _catID; \
	templateSubcatID = _subCatID; \
}

class BuildObjects
{
	// Base class for all objects here
	class BuildObjectBase {
		// Object's class name from cfgVehicles
		className = "CamoNet_OPFOR_F";

		// Custom name which will be displayed. Leave it "" to take the name from CfgVehicles >> className >> "displayName"
		displayName = "";

		// A slightly longer description of the object. Leave it "" for it to be not shown.
		description = "";

		// How much build resources it costs
		buildResource = 10;

		// Category and subcategory IDs from the templates
		// Most objects have them as -1, -1 because they don't belong to templates and are simple objects
		// If these are not -1, the created object will be created as a Unit OOP object and added to garrison
		// Otherwise it will be just added to location as an object
		templateCatID = -1;
		templateSubcatID = -1;

		// If set to true, will be providing radio functionality
		isRadio = false;
	};

	// Below are buildUI categories, inside which we have actual objects
	class Categories {
		class CatTents {
			displayName = "Tents";

			// Small tents (2 person)
			__BUILD_OBJECT_CLASS(CatTents,Land_TentA_F, 										10);

			// Medium tents (4 person)
			__BUILD_OBJECT_CLASS(CatTents,Land_TentDome_F, 										20);

			// Medium tents (16 person)
			__BUILD_OBJECT_CLASS(CatTents,Land_MedicalTent_01_aaf_generic_open_F, 				80);
			__BUILD_OBJECT_CLASS(CatTents,Land_MedicalTent_01_CSAT_brownhex_generic_open_F, 	80);
			__BUILD_OBJECT_CLASS(CatTents,Land_MedicalTent_01_NATO_generic_open_F, 				80);
			__BUILD_OBJECT_CLASS(CatTents,Land_MedicalTent_01_wdl_generic_open_F, 				80);
		};

		class CatMedical {
			displayName = "Medical";

			__BUILD_OBJECT_CLASS(CatMedical,Land_MedicalTent_01_MTP_closed_F,					60);
			__BUILD_OBJECT_CLASS(CatMedical,Land_MedicalTent_01_digital_closed_F,				60);
			__BUILD_OBJECT_CLASS(CatMedical,Land_MedicalTent_01_brownhex_closed_F,				60);
			__BUILD_OBJECT_CLASS(CatMedical,Land_DeconTent_01_wdl_F,							60);
			__BUILD_OBJECT_CLASS(CatMedical,Land_MedicalTent_01_wdl_closed_F,					60);

			// plain brown
			__BUILD_OBJECT_CLASS(CatMedical,Land_DeconTent_01_NATO_F,							60);

			// plain green
			__BUILD_OBJECT_CLASS(CatMedical,Land_DeconTent_01_NATO_tropic_F,					60);
			
			// plain white
			__BUILD_OBJECT_CLASS(CatMedical,Land_DeconTent_01_white_F,							60);
		};

		class CatStorage {
			displayName = "Storage";

			// Note that we have increased capacity of these boxes through the addon 
			__BUILD_OBJECT_CLASS_CAT(CatStorage,Box_FIA_Support_F,								20, 3, 2);
			//__BUILD_OBJECT_CLASS_CAT(CatStorage,Box_Syndicate_Ammo_F,							20, 3, 1); // Too powerful
			__BUILD_OBJECT_CLASS_CAT(CatStorage,I_supplyCrate_F,								20, 3, 2);
			__BUILD_OBJECT_CLASS_CAT(CatStorage,B_CargoNet_01_ammo_F,							20, 3, 3);
		};

		class CatCamo {
			displayName = "Camouflage";

			// Camo nets
			__BUILD_OBJECT_CLASS(CatCamo,CamoNet_OPFOR_F,										20);
			__BUILD_OBJECT_CLASS(CatCamo,CamoNet_OPFOR_open_F,									20);
			__BUILD_OBJECT_CLASS(CatCamo,CamoNet_OPFOR_big_F,									20);
		};

		class Lighting {
			displayName = "Lighting";

			// Lights
			__BUILD_OBJECT_CLASS(Lighting,Land_TentLamp_01_standing_F,							10);
			__BUILD_OBJECT_CLASS(Lighting,Land_LampShabby_F,									10);
			__BUILD_OBJECT_CLASS(Lighting,Campfire_burning_F,									10);
			__BUILD_OBJECT_CLASS(Lighting,Land_PortableLight_double_F,							10);
			__BUILD_OBJECT_CLASS(Lighting,Land_PortableLight_single_F,							10);
		};

		class Defense {
			displayName = "Defense";

			// cheap makeshift barriers
			__BUILD_OBJECT_CLASS(Defense,Land_SlumWall_01_s_2m_F,								10);
			__BUILD_OBJECT_CLASS(Defense,Land_SlumWall_01_s_4m_F,								20);
			__BUILD_OBJECT_CLASS(Defense,Land_SandbagBarricade_01_hole_F,						20);
			__BUILD_OBJECT_CLASS(Defense,Land_SandbagBarricade_01_F,							20);
			__BUILD_OBJECT_CLASS(Defense,Land_SandbagBarricade_01_half_F,						20);
			__BUILD_OBJECT_CLASS(Defense,Land_Barricade_01_10m_F,								20);
			__BUILD_OBJECT_CLASS(Defense,Land_Barricade_01_4m_F,								20);

			// dirt mound
			__BUILD_OBJECT_CLASS(Defense,Land_Rampart_F,										30);

			// razorwire
			__BUILD_OBJECT_CLASS(Defense,Land_Razorwire_F,										10);

			// garbage
			__BUILD_OBJECT_CLASS(Defense,Land_ConcretePipe_F,									20);
			__BUILD_OBJECT_CLASS(Defense,Land_Bricks_V4_F,										10);
			__BUILD_OBJECT_CLASS(Defense,Land_Timbers_F,										10);

			__BUILD_OBJECT_CLASS(Defense,Land_CncBarrier_F,										20);
			__BUILD_OBJECT_CLASS(Defense,Land_CncBarrierMedium_F,								40);
			__BUILD_OBJECT_CLASS(Defense,Land_CncBarrierMedium4_F,								60);
			__BUILD_OBJECT_CLASS(Defense,Land_CncBarrier_stripes_F,								20);

			// brown h-barriers
			__BUILD_OBJECT_CLASS(Defense,Land_HBarrier_Big_F,									40);
			__BUILD_OBJECT_CLASS(Defense,Land_HBarrier_3_F,										40);
			__BUILD_OBJECT_CLASS(Defense,Land_HBarrierWall6_F,									60);
			__BUILD_OBJECT_CLASS(Defense,Land_HBarrierTower_F,									80);
		};

		class TargetRange {
			displayName = "Shooting Range";

			// small targets
			__BUILD_OBJECT_CLASS(TargetRange,Land_Target_Oval_F,								10);
			__BUILD_OBJECT_CLASS(TargetRange,TargetP_Inf_F,										20);
			__BUILD_OBJECT_CLASS(TargetRange,TargetP_Inf_Acc2_F,								20);

			// concrete targets
			__BUILD_OBJECT_CLASS(TargetRange,Land_Target_Concrete_01_v2_F,						60);
			__BUILD_OBJECT_CLASS(TargetRange,Land_Target_Concrete_01_v1_F,						60);
			__BUILD_OBJECT_CLASS(TargetRange,Land_Target_Concrete_Support_01_F,					20);

			// RPG targets
			__BUILD_OBJECT_CLASS(TargetRange,Land_Wreck_Skodovka_F,								60);
			__BUILD_OBJECT_CLASS(TargetRange,Land_Wreck_Van_F,									60);
			__BUILD_OBJECT_CLASS(TargetRange,Land_Wreck_Truck_dropside_F,						60);
			__BUILD_OBJECT_CLASS(TargetRange,Land_Wreck_BMP2_F,									80);

			__BUILD_OBJECT_CLASS(TargetRange,Land_ShootingPos_Roof_01_F,						20);
		};

		class BuildingsA {
			displayName = "Buildings";

			// towers and bunkers
			__BUILD_OBJECT_CLASS(BuildingsA,Land_GuardTower_01_F,								160);
			__BUILD_OBJECT_CLASS(BuildingsA,Land_BagBunker_Large_F,								160);
			__BUILD_OBJECT_CLASS(BuildingsA,Land_BagBunker_Small_F,								80);
			__BUILD_OBJECT_CLASS(BuildingsA,Land_BagBunker_Tower_F,								160);
			__BUILD_OBJECT_CLASS(BuildingsA,Land_Cargo_Patrol_V2_F,								120);
		};

		class Concealment {
			displayName = "Concealment";

			// walls
			__BUILD_OBJECT_CLASS(Concealment,Land_Wall_Tin_4_2,									10);
			__BUILD_OBJECT_CLASS(Concealment,Land_Wall_Tin_4,									10);
			__BUILD_OBJECT_CLASS(Concealment,Land_TinWall_02_l_4m_F,							10);
			__BUILD_OBJECT_CLASS(Concealment,Land_TinWall_02_l_8m_F,							20);
		};

		class Recreation {
			displayName = "Recreation";

			// tables
			__BUILD_OBJECT_CLASS(Recreation,Land_WoodenTable_02_large_F, 						10);
			__BUILD_OBJECT_CLASS(Recreation,Land_PicnicTable_01_F, 								20);

			// sun chairs
			__BUILD_OBJECT_CLASS(Recreation,Land_Sun_chair_F, 									10);
			__BUILD_OBJECT_CLASS(Recreation,Land_Sun_chair_green_F, 							10);

			// non-sun chairs
			__BUILD_OBJECT_CLASS(Recreation,Land_CampingChair_V2_F, 							10);
			__BUILD_OBJECT_CLASS(Recreation,Land_CampingChair_V2_white_F, 						10);
			__BUILD_OBJECT_CLASS(Recreation,Land_ChairPlastic_F, 								10);
			__BUILD_OBJECT_CLASS(Recreation,Land_ArmChair_01_F, 								20);

			// bench
			__BUILD_OBJECT_CLASS(Recreation,Land_Bench_05_F, 									10);
			
			// gym
			__BUILD_OBJECT_CLASS(Recreation,Land_GymBench_01_F, 								20);

			// others 
			__BUILD_OBJECT_CLASS(Recreation,Land_Carousel_01_F, 								150);
		};

		class Special {
			displayName = "Special";
			class RadioShack : BuildObjectBase {
				className = "Land_TBox_F";
				displayName = "Radio Shack";
				buildResource = 100;
				isRadio = true;
				description = "A small building with radio equipment. Intercepts enemy radio communications in the range of ~5km, if you have the radio cryptokey";
			};
		};
	};
};








