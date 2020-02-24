// Should be included into the config file
// Stores objects for the build UI

// Macro for simple objects in build UI, which only have a cost and build resource
#define __BUILD_OBJECT_CLASS(_cfgClassName, _cfgVehClassName, _buildResource) class _cfgClassName : BuildObjectBase { \
	className = #_cfgVehClassName; \
	buildResource = _buildResource; \
};


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
			// Big tents
			#define __TENT_BIG_COST 40
			
			__BUILD_OBJECT_CLASS(Tent0,Land_MedicalTent_01_white_generic_closed_F, __TENT_BIG_COST)
			__BUILD_OBJECT_CLASS(Tent1,Land_MedicalTent_01_NATO_generic_closed_F, __TENT_BIG_COST)
			__BUILD_OBJECT_CLASS(Tent2,Land_MedicalTent_01_NATO_tropic_generic_closed_F, __TENT_BIG_COST)			
		};

		class CatMedical {
			displayName = "Medical";
			#define __TENT_BIG_MEDICAL_COST 60

			// plain brown
			__BUILD_OBJECT_CLASS(Tent0,Land_MedicalTent_01_NATO_generic_outer_F, __TENT_BIG_MEDICAL_COST)
			__BUILD_OBJECT_CLASS(Tent1,Land_MedicalTent_01_NATO_generic_inner_F, __TENT_BIG_MEDICAL_COST)
			__BUILD_OBJECT_CLASS(Tent2,Land_DeconTent_01_NATO_F, __TENT_BIG_MEDICAL_COST)

			// plain green
			__BUILD_OBJECT_CLASS(Tent3,Land_MedicalTent_01_NATO_tropic_generic_outer_F, __TENT_BIG_MEDICAL_COST)
			__BUILD_OBJECT_CLASS(Tent4,Land_MedicalTent_01_wdl_generic_inner_F, __TENT_BIG_MEDICAL_COST)
			__BUILD_OBJECT_CLASS(Tent5,Land_DeconTent_01_NATO_tropic_F, __TENT_BIG_MEDICAL_COST)
			
			// plain white
			__BUILD_OBJECT_CLASS(Tent6,Land_MedicalTent_01_white_generic_outer_F, __TENT_BIG_MEDICAL_COST)
			__BUILD_OBJECT_CLASS(Tent7,Land_MedicalTent_01_white_generic_inner_F, __TENT_BIG_MEDICAL_COST)
			__BUILD_OBJECT_CLASS(Tent8,Land_DeconTent_01_white_F, __TENT_BIG_MEDICAL_COST)

		};

		class CatStorage {
			displayName = "Storage";
			// Note that we have increased capacity of these boxes through the addon 
			class Box0 : BuildObjectBase {
				className = "Box_FIA_Support_F";
				buildResource = 40;
				templateCatID = 3;
				templateSubcatID = 2;
			};
			class Box1 : BuildObjectBase {
				className = "Box_Syndicate_Ammo_F";
				buildResource = 20;
				templateCatID = 3;
				templateSubcatID = 1;
			};
			class Box2 : BuildObjectBase {
				className = "I_supplyCrate_F";
				buildResource = 40;
				templateCatID = 3;
				templateSubcatID = 2;
			};
			class Box3 : BuildObjectBase {
				className = "B_CargoNet_01_ammo_F";
				buildResource = 80;
				templateCatID = 3;
				templateSubcatID = 3;
			};
		};

		class CatCamo {
			displayName = "Camouflage";
			// Camo nets
			__BUILD_OBJECT_CLASS(Camo0,CamoNet_OPFOR_F, 20)
			__BUILD_OBJECT_CLASS(Camo1,CamoNet_OPFOR_open_F, 20)
			__BUILD_OBJECT_CLASS(Camo2,CamoNet_OPFOR_big_F, 20)

		};

		class Lighting {
			displayName = "Lighting";
			// Lights
			__BUILD_OBJECT_CLASS(Light0,Land_TentLamp_01_standing_F, 10)
			__BUILD_OBJECT_CLASS(Light1,Land_LampShabby_F, 10)
			__BUILD_OBJECT_CLASS(Light2,Campfire_burning_F, 10)
			__BUILD_OBJECT_CLASS(Light3,Land_PortableLight_double_F, 10)
			__BUILD_OBJECT_CLASS(Light4,Land_PortableLight_single_F, 10)
			
		};

		class Defense {
			displayName = "Defense";
			// brown h-barriers
			__BUILD_OBJECT_CLASS(Defense0,Land_HBarrier_Big_F, 20)
			__BUILD_OBJECT_CLASS(Defense1,Land_HBarrier_3_F, 20)
			__BUILD_OBJECT_CLASS(Defense2,Land_HBarrierWall6_F, 40)
			__BUILD_OBJECT_CLASS(Defense3,Land_HBarrierTower_F, 40)

			// cheap makeshift barriers
			__BUILD_OBJECT_CLASS(Defense4,Land_SandbagBarricade_01_hole_F, 40)
			__BUILD_OBJECT_CLASS(Defense5,Land_SandbagBarricade_01_F, 40)
			__BUILD_OBJECT_CLASS(Defense6,Land_SandbagBarricade_01_half_F, 40)
			__BUILD_OBJECT_CLASS(Defense7,Land_Barricade_01_10m_F, 40)
			__BUILD_OBJECT_CLASS(Defense8,Land_Barricade_01_4m_F, 40)

			// dirt mound
			__BUILD_OBJECT_CLASS(Defense9,Dirthump_1_F, 60)

			// razorwire
			__BUILD_OBJECT_CLASS(Defense10,Land_Razorwire_F, 10)

			// garbage
			__BUILD_OBJECT_CLASS(Defense11,Land_ConcretePipe_F, 20)
			__BUILD_OBJECT_CLASS(Defense12,Land_Bricks_V4_F, 10)
			__BUILD_OBJECT_CLASS(Defense13,Land_Timbers_F, 10)

			__BUILD_OBJECT_CLASS(Defense14,Land_CncBarrier_F, 20)
			__BUILD_OBJECT_CLASS(Defense15,Land_CncBarrierMedium_F, 40)
			__BUILD_OBJECT_CLASS(Defense16,Land_CncBarrierMedium4_F, 60)
			__BUILD_OBJECT_CLASS(Defense17,Land_CncBarrier_stripes_F, 20)
		
		};

		class TargetRange {
			displayName = "Shooting Range";
			// small targets
			__BUILD_OBJECT_CLASS(TargetR0,Land_Target_Dueling_01_F, 10)
			__BUILD_OBJECT_CLASS(TargetR1,Zombie_PopUp_Moving_F, 20)
			__BUILD_OBJECT_CLASS(TargetR2,Zombie_PopUp_Moving_90deg_F, 20)

			// concrete targets
			__BUILD_OBJECT_CLASS(TargetR3,Land_Target_Concrete_01_v2_F, 60)
			__BUILD_OBJECT_CLASS(TargetR4,Land_Target_Concrete_01_v1_F, 60)
			__BUILD_OBJECT_CLASS(TargetR5,Land_Target_Concrete_Support_01_F, 20)

			// RPG targets
			__BUILD_OBJECT_CLASS(TargetR6,Land_Wreck_Skodovka_F, 60)
			__BUILD_OBJECT_CLASS(TargetR7,Land_Wreck_Van_F, 60)
			__BUILD_OBJECT_CLASS(TargetR8,Land_Wreck_Truck_dropside_F, 60)
			__BUILD_OBJECT_CLASS(TargetR9,Land_Wreck_BMP2_F, 80)

		};

		class BuildingsA {
			displayName = "Buildings";
			
			// towers and bunkers
			__BUILD_OBJECT_CLASS(Buildings0,Land_GuardTower_01_F, 160)
			__BUILD_OBJECT_CLASS(Buildings1,Land_BagBunker_Large_F, 160)
			__BUILD_OBJECT_CLASS(Buildings3,Land_BagBunker_Small_F, 80)
			__BUILD_OBJECT_CLASS(Buildings4,Land_BagBunker_Tower_F, 160)
			__BUILD_OBJECT_CLASS(Buildings5,Land_Cargo_Patrol_V2_F, 120)

		};

		class Concealment {
			displayName = "Concealment";
			
			// towers and bunkers
			__BUILD_OBJECT_CLASS(ConcealM0,Land_Wall_Tin_4_2, 10)
			__BUILD_OBJECT_CLASS(ConcealM1,Land_Wall_Tin_4, 10)
			__BUILD_OBJECT_CLASS(ConcealM2,Land_TinWall_02_l_4m_F, 10)
			__BUILD_OBJECT_CLASS(ConcealM3,Land_TinWall_02_l_8m_F, 20)

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








