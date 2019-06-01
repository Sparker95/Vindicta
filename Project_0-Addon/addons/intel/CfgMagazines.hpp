//#includes QPATHTOEF (main,classFactory.hpp);

class CfgMagazines
{
	class CA_Magazine;
	class vin_document_0: CA_Magazine
	{
		mass=0;
		scope=2;
		displayName="Military documents";
		descriptionShort = "A few military documents. Pick it up and double-click to study the intel.";
		picture = "\A3\EditorPreviews_F\Data\CfgVehicles\Land_Document_01_F.jpg";
		model = "\A3\Structures_F_EPC\Items\Documents\Document_01_F.p3d";
	};

	class vin_document_1: CA_Magazine
	{
		mass=0;
		scope=2;
		displayName="Military documents";
		descriptionShort = "Some military documents. Pick it up and double-click to study the intel.";
		picture = "\A3\EditorPreviews_F\Data\CfgVehicles\Land_FilePhotos_F.jpg";
		model = "\A3\Structures_F\Items\Documents\FilePhotos_F.p3d";
	};

	class vin_tablet_0: CA_Magazine
	{
		mass = 0.1;
		scope=2;
		displayName="Tactical tablet";
		descriptionShort = "A military tactical tablet. Pick it up and double-click to study the intel.";
		picture = "\A3\EditorPreviews_F\Data\CfgVehicles\Land_Tablet_02_F.jpg";
		model = "\A3\Props_F_Exp_A\Military\Equipment\Tablet_02_F.p3d";
	};

	class vin_tablet_1: CA_Magazine
	{
		mass = 0.1;
		scope=2;
		displayName="Personal tablet";
		descriptionShort = "A personal tablet. Pick it up and double-click to study the intel";
		picture = "\A3\EditorPreviews_F\Data\CfgVehicles\Land_Tablet_01_F.jpg";
		model = "\A3\Structures_F_Heli\Items\Electronics\Tablet_01_F.p3d";
	};
	
	
	//COPY_CLASS_200(vin_document_0, vin_document_0)
};