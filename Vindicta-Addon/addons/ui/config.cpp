#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"vindicta_main"};
        author = "";
        authors[] = {""};
        VERSION_CONFIG;
    };
};

class CfgMarkerClasses {
	class Vindicta {
		displayName = "Vindicta";
	};
};

class CfgMarkers {
	
	class vin_notification_base_
	{
		color[] = {0, 0, 0, 1};
		size = 32;
		shadow = false;
		scope = 0;
		markerClass = "Vindicta";
		
		icon = QPATHTOF(markers\notification_top_right.paa);
		name = "no name";
	};
	
	class vin_notification_top_right : vin_notification_base_
	{
		name = "Notification top-right";
		icon = QPATHTOF(markers\notification_top_right.paa);
		scope = 1;
	};

	class vin_notification_top_right_exclamation : vin_notification_base_
	{
		name = "Notification top-right exclamation";
		icon = QPATHTOF(markers\MI_notification.paa);
		color[] = {1, 1, 1, 1};
		scope = 1;
	};

	// Location icons made by Marvis

	class vin_location_base_
	{
		color[] = {1, 0, 0, 1};
		size = 32;
		shadow = false;
		scope = 0;
		markerClass = "Vindicta";		
		icon = QPATHTOF(markers\MapIcons.paa);
		name = "no name";
	};

	class vin_selector : vin_location_base_
	{
		name = "Selector";
		icon = QPATHTOF(markers\MI_marker_selected.paa);
		scope = 1;
	};

	class vin_location_background : vin_location_base_
	{
		name = "Location Background";
		icon = QPATHTOF(markers\MI_BG_white.paa);
		scope = 1;
	};

	class vin_location_power_plant : vin_location_base_
	{
		name = "Power Plant";
		icon = QPATHTOF(markers\MapIcons.paa);
		scope = 1;
	};

	class vin_location_depot : vin_location_base_
	{
		name = "Depot";
		icon = QPATHTOF(markers\MapIcons2.paa);
		scope = 1;
	};

	class vin_location_police_station : vin_location_base_
	{
		name = "Police Station";
		icon = QPATHTOF(markers\MapIcons3.paa);
		scope = 1;
	};

	class vin_location_radio_station : vin_location_base_
	{
		name = "Radio Station";
		icon = QPATHTOF(markers\MapIcons4.paa);
		scope = 1;
	};

	class vin_location_city : vin_location_base_
	{
		name = "City";
		icon = QPATHTOF(markers\MapIcons5.paa);
		scope = 1;
	};

	class vin_location_airport : vin_location_base_
	{
		name = "Airport";
		icon = QPATHTOF(markers\MapIcons6.paa);
		scope = 1;
	};

	class vin_location_outpost : vin_location_base_
	{
		name = "Outpost";
		icon = QPATHTOF(markers\MapIcons7.paa);
		scope = 1;
	};

	class vin_location_roadblock : vin_location_base_
	{
		name = "Roadblock";
		icon = QPATHTOF(markers\MapIcons8.paa);
		scope = 1;
	};

	class vin_location_camp : vin_location_base_
	{
		name = "Camp";
		icon = QPATHTOF(markers\MapIcons9.paa);
		scope = 1;
	};

};

class CfgUnitInsignia
{
	class Vindicta
	{
		displayName = "Vindicta";
		author = "Vindicta Team";
		texture = QPATHTOF(pictures\insignia_v.paa);
		textureVehicle = "";
	};
};