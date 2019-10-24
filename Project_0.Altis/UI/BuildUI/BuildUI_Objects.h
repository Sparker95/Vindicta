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
			//__BUILD_OBJECT_CLASS(Tent0,Land_MedicalTent_01_wdl_generic_inner_F, __TENT_BIG_COST)
			__BUILD_OBJECT_CLASS(Tent1,Land_MedicalTent_01_aaf_generic_inner_F, __TENT_BIG_COST)
			__BUILD_OBJECT_CLASS(Tent2,Land_MedicalTent_01_CSAT_brownhex_generic_inner_F, __TENT_BIG_COST)
			__BUILD_OBJECT_CLASS(Tent3,Land_MedicalTent_01_NATO_generic_inner_F, __TENT_BIG_COST)
			//__BUILD_OBJECT_CLASS(Tent4,Land_MedicalTent_01_CSAT_greenhex_generic_inner_F, __TENT_BIG_COST)
			//__BUILD_OBJECT_CLASS(Tent5,Land_MedicalTent_01_NATO_tropic_generic_inner_F, __TENT_BIG_COST)
		};

		class CatMedical {
			displayName = "Medical";
			#define __TENT_BIG_MEDICAL_COST 40
			__BUILD_OBJECT_CLASS(Tent0,Land_MedicalTent_01_digital_closed_F, __TENT_BIG_MEDICAL_COST)
			__BUILD_OBJECT_CLASS(Tent1,Land_MedicalTent_01_brownhex_closed_F, __TENT_BIG_MEDICAL_COST)
		};

		class CatStorage {
			displayName = "Storage";
			class Box0 : BuildObjectBase {
				className = "Box_FIA_Support_F";
				buildResource = 20;
				templateCatID = 3;
				templateSubcatID = 2;
			};
			class Box1 : BuildObjectBase {
				className = "Box_Syndicate_Ammo_F";
				buildResource = 10;
				templateCatID = 3;
				templateSubcatID = 1;
			};
			class Box2 : BuildObjectBase {
				className = "I_supplyCrate_F";
				buildResource = 20;
				templateCatID = 3;
				templateSubcatID = 2;
			};
			class Box3 : BuildObjectBase {
				className = "B_CargoNet_01_ammo_F";
				buildResource = 30;
				templateCatID = 3;
				templateSubcatID = 3;
			};
		};

		class CatCamo {
			displayName = "Camouflage";
			// Camo nets
			__BUILD_OBJECT_CLASS(Camo0,CamoNet_OPFOR_F, 30)
			__BUILD_OBJECT_CLASS(Camo1,CamoNet_OPFOR_open_F, 30)
			__BUILD_OBJECT_CLASS(Camo2,CamoNet_OPFOR_big_F, 30)
		};

		class Special {
			displayName = "Special";
			class RadioShack : BuildObjectBase {
				className = "Land_TBox_F";
				displayName = "Radio Shack";
				buildResource = 100;
				isRadio = true;
				description = "Small building with radio equipment. Intercepts enemy radio communications in the range of ~5km, if you have the radio key";
			};
		};
	};
};
