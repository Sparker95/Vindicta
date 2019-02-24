#include "defineCommon.inc"

[] spawn {
	profileNamespace setVariable ["bis_fnc_configviewer_selected", typeOf cursorObject];
	profileNamespace setVariable ["bis_fnc_configviewer_path", ["configfile","CfgVehicles",typeOf cursorObject]];
	sleep 0.1;
	call BIS_fnc_configViewer;
};