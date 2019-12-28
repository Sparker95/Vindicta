class CfgWeapons
{
	class ItemCore;
	class vin_build_res_0: ItemCore
	{
		buildResource = 10;
		mass = 80; // In arma it's really volume, not mass
		scope=2;
		displayName="Construction resources (x10)";
		descriptionShort = "Resources to build different things";
		picture = "\A3\EditorPreviews_F_Orange\Data\CfgVehicles\Land_PaperBox_01_small_closed_brown_F.jpg";
		hiddenSelections[] = {"Camo"};
		hiddenSelectionsTextures[] = {"\A3\Props_F_Orange\Humanitarian\Supplies\Data\PaperBox_01_small_brown_CO.paa"};
		model = "\A3\Props_F_Orange\Humanitarian\Supplies\PaperBox_01_small_closed_F.p3d";
	};
};