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

		// Custom name which will be displayed. Leave it "_default_" to take the name from CfgVehicles >> className >> "displayName"
		displayName = "_default_";

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
			__BUILD_OBJECT_CLASS(tent0, Land_MedicalTent_01_wdl_generic_inner_F, __TENT_BIG_COST);
			__BUILD_OBJECT_CLASS(tent1, Land_MedicalTent_01_aaf_generic_inner_F, __TENT_BIG_COST);
			__BUILD_OBJECT_CLASS(tent2, Land_MedicalTent_01_CSAT_brownhex_generic_inner_F, __TENT_BIG_COST);
			__BUILD_OBJECT_CLASS(tent3, Land_MedicalTent_01_NATO_generic_inner_F, __TENT_BIG_COST);
			__BUILD_OBJECT_CLASS(tent4, Land_MedicalTent_01_CSAT_greenhex_generic_inner_F, __TENT_BIG_COST);
			__BUILD_OBJECT_CLASS(tent5, Land_MedicalTent_01_NATO_tropic_generic_inner_F, __TENT_BIG_COST);
		};

		class CatCamo {
			displayName = "Camouflage";
			// Camo nets
			__BUILD_OBJECT_CLASS(camo0, CamoNet_OPFOR_F, 30);
			__BUILD_OBJECT_CLASS(camo0, CamoNet_OPFOR_open_F, 30);
			__BUILD_OBJECT_CLASS(camo0, CamoNet_OPFOR_big_F, 30);
		};

		class CatStorage {
			displayName = "Storage";
			/*
				["Box_FIA_Support_F",	"Supply cache",							20,	T_CARGO, T_CARGO_box_medium],
				["Box_Syndicate_Ammo_F", "Supply Box (small)",					10,	T_CARGO, T_CARGO_box_small],
				["I_supplyCrate_F",		"Supply Box (medium)",					20,	T_CARGO, T_CARGO_box_medium],
				["B_CargoNet_01_ammo_F", "Supply Box (large)",					30, T_CARGO, T_CARGO_box_big]
			*/

		};
	};

};