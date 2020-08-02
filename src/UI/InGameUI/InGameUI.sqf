#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\Resources\defineCommonGrids.hpp"
#include "..\..\common.h"
#include "InGameUI_Macros.h"
#include "..\Resources\UIProfileColors.h"

/*
Class inGameUI
In-game user interface overlay.

Author: Sparker 19 september 2019
*/

#define pr private

#define OOP_CLASS_NAME InGameUI
CLASS("InGameUI", "") 

	STATIC_VARIABLE("instance");

	METHOD(new)
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
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];
		OOP_ERROR_0("ARE YOU SURE THAT YOU WANT TO DELETE THAT?");
	ENDMETHOD;

	public METHOD(setLocationText)
		params [P_THISOBJECT, P_STRING("_text"), P_COLOR("_color")];
		pr _display = uiNamespace getVariable "p0_InGameUI_display";
		if(_text == "") then {
			(_display displayCtrl IDC_INGAME_STATIC_LOCATION_NAME) ctrlShow false;
			(_display displayCtrl IDC_INGAME_STATIC_LOCATION_NAME_DESCR) ctrlShow false;
		} else {
			(_display displayCtrl IDC_INGAME_STATIC_LOCATION_NAME) ctrlShow true;
			(_display displayCtrl IDC_INGAME_STATIC_LOCATION_NAME_DESCR) ctrlShow true;
			(_display displayCtrl IDC_INGAME_STATIC_LOCATION_NAME) ctrlSetText _text;
			(_display displayCtrl IDC_INGAME_STATIC_LOCATION_NAME) ctrlSetTextColor _color;
		};
	ENDMETHOD;

	public METHOD(setBuildResourcesAmount)
		params [P_THISOBJECT, P_NUMBER("_value")];
		pr _display = uiNamespace getVariable "p0_InGameUI_display";

		if (_value < 0) then {
			(_display displayCtrl IDC_INGAME_STATIC_CONSTRUCTION_RESOURCES) ctrlShow false;
			(_display displayCtrl IDC_INGAME_STATIC_CONSTRUCTION_RESOURCES_DESCR) ctrlShow false;
			// (_display displayCtrl IDC_INGAME_STATIC_CONSTRUCTION_RESOURCES) ctrlSetText "";
		} else {
			(_display displayCtrl IDC_INGAME_STATIC_CONSTRUCTION_RESOURCES) ctrlShow true;
			(_display displayCtrl IDC_INGAME_STATIC_CONSTRUCTION_RESOURCES_DESCR) ctrlShow true;
			(_display displayCtrl IDC_INGAME_STATIC_CONSTRUCTION_RESOURCES) ctrlSetText format ["%1", _value];
		};
	ENDMETHOD;

/*
	public METHOD(setLocationCapacityInf)
		params [P_THISOBJECT, P_NUMBER("_capacity")];
		pr _display = uiNamespace getVariable "p0_InGameUI_display";
		if (_capacity < 0) then {
			(_display displayCtrl IDC_INGAME_STATIC_MAX_INF) ctrlSetText "";
		} else {
			pr _text = format ["Max infantry: %1", _capacity];
			(_display displayCtrl IDC_INGAME_STATIC_MAX_INF) ctrlSetText _text;
		};
	ENDMETHOD;
*/

ENDCLASS;