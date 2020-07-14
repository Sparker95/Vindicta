#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {
			"cba_ui",
            "cba_xeh",
            "cba_jr",
            "ace_main",
            "ace_gestures",
            "ace_vehiclelock",
            "ace_cargo",
            "ace_interact_menu",
            "ace_interaction"
		};
        author = "";
        authors[] = {"Vindicta Team"};
        authorUrl = "";
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "CfgModuleCategories.hpp"

class CfgLocationTypes {
    class vin_garrison {
        name = "";
        drawStyle = "area";
        texture = "";
        color[] = {0,0,0,0};
        size = 0;
        textSize = 0;
        shadow = 0;
        font = "PuristaMedium";
    };
};