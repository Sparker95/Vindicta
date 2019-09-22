#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\Resources\defineCommonGrids.hpp"
#include "..\..\OOP_Light\OOP_Light.h"
#include "InGameUI_Macros.h"
#include "..\Resources\UIProfileColors.h"

/*
Class inGameUI
In-game user interface overlay.

Author: Sparker 19 september 2019
*/

#define pr private

CLASS("InGameUI", "") 

	STATIC_VARIABLE("instance");

	METHOD("new") {
		params [P_THISOBJECT];

		pr _inst = GETSV("InGameUI", "instance");
		if (!isNil "_inst") then {
			OOP_ERROR_1("Attempt to create a second instance of InGameUI: %1", _thisObject);
		};
		SETSV("InGameUI", "instance", _thisObject);

		// Register a layer, create a rsc
		g_rscLayerInGameUI = ["rscLayerInGameUI"] call BIS_fnc_rscLayer;
		uiNamespace setVariable ["p0_InGameUI_display", displayNull];
		g_rscLayerInGameUI cutRsc ["Vin_InGameUI", "PLAIN", -1, false];
	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];
		OOP_ERROR_0("ARE YOU SURE THAT YOU WANT TO DELETE THAT?");
	} ENDMETHOD;

	METHOD("setLocationText") {
		params [P_THISOBJECT, P_STRING("_text")];
		pr _display = uiNamespace getVariable "p0_InGameUI_display";
		(_display displayCtrl IDC_INGAME_STATIC_LOCATION_NAME) ctrlSetText _text;
	} ENDMETHOD;

	METHOD("setBuildResourcesAmount") {
		params [P_THISOBJECT, P_NUMBER("_value")];
		pr _display = uiNamespace getVariable "p0_InGameUI_display";

		if (_value < 0) then {
			(_display displayCtrl IDC_INGAME_STATIC_CONSTRUCTION_RESOURCES) ctrlSetText "";
		} else {
			pr _text = format ["Construction resources: %1", _value];
			(_display displayCtrl IDC_INGAME_STATIC_CONSTRUCTION_RESOURCES) ctrlSetText _text;
		};
	} ENDMETHOD;

ENDCLASS;