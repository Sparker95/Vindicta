#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#include "..\..\common.h"
#include "..\..\Undercover\undercoverMonitor.hpp"
#include "..\InGameUI\InGameUI_Macros.h"

/*
Class: UndercoverUI
Passes values from undercoverMonitor to display them on the Undercover UI

Author: Marvis
*/

#define CLASS_NAME "UndercoverUI"
#define pr private

#ifndef _SQF_VM // Not needed for tests, and SQF-VM doesn't support localize anyway
// string for each hint key
g_UM_Hints = [
	HK_COMPROMISED_VIC, localize "STR_UM_HINT_COMPROMISEDVIC",
	HK_INCAPACITATED, localize "STR_UM_HINT_DOWNED",
	HK_ARRESTED, localize "STR_UM_HINT_ARRESTED",
	HK_ILLEGAL, localize "STR_UM_HINT_ILLEGAL",
	HK_MORPHINE, localize "STR_UM_HINT_MORPHINE",
	HK_SURRENDER, localize "STR_UM_HINT_SURRENDER",
	HK_HOSTILITY, localize "STR_UM_HINT_HOSTILITY",
	HK_WEAPON, localize "STR_UM_HINT_WEAPON",
	HK_SUSPGEAR, localize "STR_UM_HINT_SUSPGEAR",
	HK_MILVEH, localize "STR_UM_HINT_MILVEH",
	HK_SUSPGEARVEH, localize "STR_UM_HINT_SUSPGEARVEH",
	HK_CLOSINGIN, localize "STR_UM_HINT_CLOSINGIN",
	HK_SUSPBEHAVIOR, localize "STR_UM_HINT_SUSPBEHAVIOR",
	HK_OFFROAD, localize "STR_UM_HINT_OFFROAD",
	HK_ALLOWEDAREA, localize "STR_UM_HINT_ALLOWEDAREA",
	HK_MILAREA, localize "STR_UM_HINT_MILAREA",
	HK_COMPROMISED, localize "STR_UM_COMPROMISED",
	HK_INVENTORY, localize "STR_UM_HINT_INVENTORY"
];
#endif

#define OOP_CLASS_NAME UndercoverUI
CLASS("UndercoverUI", "")
	
	STATIC_METHOD(drawUI)
		params [P_THISOBJECT, ["_unit", 0], ["_suspicion", 0], ["_hintKeys", 0]];

			pr _textUI = "";
			pr _bSuspicious = UNDERCOVER_IS_UNIT_SUSPICIOUS(_unit);
			if (_suspicion > 1) then { _suspicion = 1; };
			if (_suspicion < 0) then { _suspicion = 0; };

			// select correct hint to display
			if ((count _hintKeys > 0)) then { 
				pr _hint = _hintKeys call BIS_fnc_greatestNum;
				pr _hintID = g_UM_Hints find _hint;
				if (_hintID != -1) then { _textUI = g_UM_Hints select (_hintID + 1); };
			} else {
				if (!(_bSuspicious) && _suspicion < 1) then { _textUI = format ["%1", localize "STR_UM_UNDERCOVER"]; };
				if (_bSuspicious) then { _textUI = format ["%1", localize "STR_UM_SUSPICIOUS"]; };
				if (_suspicion >= 1) then { _textUI = format ["%1", localize "STR_UM_OVERT"]; };
			};

			// clamp color, for visual reasons
			pr _colorMult = linearConversion [0, 1, _suspicion, 0.35, 0.88, true];
			pr _color = [1.8* _colorMult, 1.8 * (1 - _colorMult), 0, 1];
			
			if ( displayNull != (uinamespace getVariable "p0_InGameUI_display") ) then {
				((uinamespace getVariable "p0_InGameUI_display") displayCtrl IDC_U_SUSPICION_TEXT) ctrlSetText format ["%1", _textUI];
	  			((uinamespace getVariable "p0_InGameUI_display") displayCtrl IDC_U_SUSPICION_STATUSBAR) progressSetPosition _suspicion;
	  			((uinamespace getVariable "p0_InGameUI_display") displayCtrl IDC_U_SUSPICION_STATUSBAR) ctrlSetTextcolor _color;

	  			((uinamespace getVariable "p0_InGameUI_display") displayCtrl IDC_U_SUSPICION_TEXT) ctrlCommit 0;
	  			((uinamespace getVariable "p0_InGameUI_display") displayCtrl IDC_U_SUSPICION_STATUSBAR) ctrlCommit 1;
	  		};
		
	ENDMETHOD;


ENDCLASS;