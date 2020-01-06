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

class CfgMissions
{
    // Multiplayer missions
    class MPMissions
    {
        class Vindicta_Altis_v0_21_102
        {
            directory = "z\vindicta\addons\missions\Vindicta_Altis_v0_21_102.Altis";
        };
    };
};
