#include "defineCommon.inc"

profileNamespace setVariable ["bis_fnc_configviewer_selected", typeOf cursorObject];
profileNamespace setVariable ["bis_fnc_configviewer_path", ["configfile","CfgVehicles",typeOf cursorObject]];

call BIS_fnc_configViewer;
