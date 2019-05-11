#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Undercover\undercoverMonitor.hpp"
#include "..\Resources\UndercoverUI\UndercoverUI_Macros.h"

/*
Class: UndercoverUI
Passes values from undercoverMonitor to display them on the Undercover UI

Author: Marvis
*/

#define CLASS_NAME "UndercoverUI"
#define pr private

// string for each hint key
g_UM_Hints = [
	HK_INCAPACITATED, "INCAPACITATED",
	HK_SURRENDER, "SURRENDERED",
	HK_HOSTILITY, "WEAPON DISCHARGED!",
	HK_WEAPON, "VISIBLE WEAPON!",
	HK_SUSPGEAR, "SUSPICIOUS OUTFIT!",
	HK_MILVEH, "THIS IS A MILITARY VEHICLE!",
	HK_SUSPGEARVEH, "DO NOT GET CLOSE TO ENEMY IN THIS OUTFIT!",
	HK_CLOSINGIN, "YOU ARE GETTING TOO CLOSE!",
	HK_SUSPBEHAVIOR, "SUSPICIOUS BEHAVIOUR!",
	HK_OFFROAD, "TOO FAR FROM ROADS!",
	HK_ALLOWEDAREA, "STAY ON THE ROAD HERE!"
];

CLASS(CLASS_NAME, "")
	
	STATIC_METHOD("drawUI") {
		params [["_thisObject", "", [""]], ["_unit", 0], ["_suspicion", 0], ["_hintKeys", 0]];

			pr _textUI = "";
			pr _bSuspicious = UNDERCOVER_IS_UNIT_SUSPICIOUS(_unit);
			if (_suspicion > 1) then { _suspicion = 1; };
			if (_suspicion < 0) then { _suspicion = 0; };

			// select correct hint to display
			if ((count _hintKeys > 0) && (_suspicion < 1)) then { 
				pr _hint = _hintKeys call BIS_fnc_greatestNum;
				pr _hintID = g_UM_Hints find _hint;
				if (_hintID != -1) then { _textUI = g_UM_Hints select (_hintID + 1); };
			} else {
				if (!(_bSuspicious) && _suspicion < 1) then { _textUI = format ["%1", localize "STR_UM_UNDERCOVER"]; };
				if (_bSuspicious) then { _textUI = format ["%1", localize "STR_UM_SUSPICIOUS"]; };
				if (_suspicion >= 1) then { _textUI = format ["%1", localize "STR_UM_OVERT"]; };
			};

			// clamp color, purely for visual reasons
			pr _colorMult = linearConversion [0, 1, _suspicion, 0.35, 0.88, true];
			pr _color = [1.8* _colorMult, 1.8 * (1 - _colorMult), 0, 1];	
			
			if ( displayNull != (uinamespace getVariable "undercoverUI_display") ) then {
				((uinamespace getVariable "undercoverUI_display") displayCtrl IDC_U_SUSPICION_TEXT) ctrlSetText format ["%1", _textUI];
	  			((uinamespace getVariable "undercoverUI_display") displayCtrl IDC_U_SUSPICION_STATUSBAR) progressSetPosition _suspicion;
	  			((uinamespace getVariable "undercoverUI_display") displayCtrl IDC_U_SUSPICION_STATUSBAR) ctrlsettextcolor _color;

	  			((uinamespace getVariable "undercoverUI_display") displayCtrl IDC_U_SUSPICION_TEXT) ctrlCommit 0;
	  			((uinamespace getVariable "undercoverUI_display") displayCtrl IDC_U_SUSPICION_STATUSBAR) ctrlCommit 0;
	  		}; 
		
	} ENDMETHOD;


ENDCLASS;