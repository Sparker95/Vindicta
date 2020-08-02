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

    class vin_helperLocation {
        name = "";
        drawStyle = "area";
        texture = "";
        color[] = {0,0,0,0};
        size = 0;
        textSize = 0;
        shadow = 0;
        font = "PuristaMedium";
    };

    class vin_garrison : vin_helperLocation {
    };

    class vin_location : vin_helperLocation {
    };
};

// External faction addons add entries here
class VinExternalFactions {
    class VinExternalFactionBase {
        loadoutsInitFile = "";  // "" if loadouts are not used
        file = "";              // Must contain valid bath, otherwise it is ignored
        version = -1;           // Must be overriden with a valid version
    };
};