#include "script_component.hpp"

class CfgPatches
{
	class ADDON
	{
		units[] = {"Project_0_SectorLocation", "Project_0_WaypointLocation"};
		requiredVersion = 1.0;
		requiredAddons[] = {"A3_Modules_F"};
	};
};

#include "CfgFactionClasses.hpp"
#include "CfgVehicles.hpp"
#include "CfgFunctions.hpp"

class CfgMagazines
{
	class CA_Magazine;
	class vin_Land_Document_01_F: CA_Magazine
	{
		mass=0;
		scope=2;
		author="Sparker";
		displayName="Military documents";
		descriptionShort = "Pick it up and double-click to study the intel";
		picture = "\A3\EditorPreviews_F\Data\CfgVehicles\Land_Document_01_F.jpg";
		model = "\A3\Structures_F_EPC\Items\Documents\Document_01_F.p3d";
	};
};