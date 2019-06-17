#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"project_0_main"};
        author = "";
        authors[] = {""};
        VERSION_CONFIG;
    };
};

class CfgMarkerClasses {
	class Project_0 {
		displayName = "Vindicta";
	};
};

class CfgMarkers {
	
	class p0_notification_base
	{
		color[] = {0, 0, 0, 1};
		size = 32;
		shadow = false;
		scope = 0;
		markerClass = "Project_0";
		
		icon = QPATHTOF(markers\notification_top_right.paa);
		name = "no name";
	};
	
	class p0_notification_top_right : p0_notification_base
	{
		name = "Notification top-right";
		icon = QPATHTOF(markers\notification_top_right.paa);
		
		scope = 1;
	};
};