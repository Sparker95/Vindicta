#include "\z\vindicta\addons\main\classFactory.hpp"

class CfgMagazines
{
	class CA_Magazine;
	class vin_document_0: CA_Magazine
	{
		mass=0;
		scope=2;
		count = 1;
		displayName="Military documents";
		descriptionShort = "A few military documents. Pick it up to study the intel.";
		picture = "\A3\EditorPreviews_F\Data\CfgVehicles\Land_Document_01_F.jpg";
		model = "\A3\Structures_F_EPC\Items\Documents\Document_01_F.p3d";
	};

	class vin_document_1: CA_Magazine
	{
		mass=0;
		scope=2;
		count = 1;
		displayName="Military documents";
		descriptionShort = "Some military documents. Pick it up to study the intel.";
		picture = "\A3\EditorPreviews_F\Data\CfgVehicles\Land_FilePhotos_F.jpg";
		model = "\A3\Structures_F\Items\Documents\FilePhotos_F.p3d";
	};

	class vin_tablet_0: CA_Magazine
	{
		mass = 0.1;
		scope=2;
		count = 1;
		displayName="Tactical tablet";
		descriptionShort = "A military tactical tablet. Pick it up to study the intel.";
		picture = "\A3\EditorPreviews_F\Data\CfgVehicles\Land_Tablet_02_F.jpg";
		model = "\A3\Props_F_Exp_A\Military\Equipment\Tablet_02_F.p3d";
	};

	class vin_tablet_1: CA_Magazine
	{
		mass = 0.1;
		scope=2;
		count = 1;
		displayName="Personal tablet";
		descriptionShort = "A personal tablet. Pick it up to study the intel";
		picture = "\A3\EditorPreviews_F\Data\CfgVehicles\Land_Tablet_01_F.jpg";
		model = "\A3\Structures_F_Heli\Items\Electronics\Tablet_01_F.p3d";
	};
	
	
	COPY_CLASS_512(vin_document_0, vin_document_0)
	COPY_CLASS_512(vin_document_1, vin_document_1)
	COPY_CLASS_512(vin_tablet_0, vin_tablet_0)
	COPY_CLASS_512(vin_tablet_1, vin_tablet_1)

	class vin_build_res_0: CA_Magazine
	{
		buildResource = 10; // Amount of build resources, used by the scenario
		count = 1; // Ammount of bullets, we make it so that one box = one box in the arsenal, ok?
		mass = 80; // In arma it's really volume, not mass
		scope=2;
		displayName="Construction resources (x10)";
		descriptionShort = "Resources to build different things";
		picture = "\A3\EditorPreviews_F_Orange\Data\CfgVehicles\Land_PaperBox_01_small_closed_brown_F.jpg";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\A3\Props_F_Orange\Humanitarian\Supplies\Data\PaperBox_01_small_brown_CO.paa"};
		model = "\A3\Props_F_Orange\Humanitarian\Supplies\PaperBox_01_small_closed_F.p3d";
	};

	class vin_pills: CA_Magazine
	{
		count = 1;
		mass = 0.1;
		scope = 2;
		displayName="Strange pills";
		descriptionShort = "Take it and double-click to use (carefully)";
		picture = "\A3\EditorPreviews_F\Data\CfgVehicles\Land_Antibiotic_F.jpg";
		model = "\A3\Structures_F_EPA\Items\Medical\Antibiotic_F.p3d";
	};
};