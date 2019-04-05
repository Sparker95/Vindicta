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

CLASS(CLASS_NAME, "")
	
	STATIC_METHOD("drawUI") {
		params [["_thisObject", "", [""]], ["_unit", 0], ["_suspicion", 0]];

			pr _bSuspicious = UNDERCOVER_IS_UNIT_SUSPICIOUS(_unit);
			
			// clamp color, purely for visual reasons
			pr _colorMult = linearConversion [0, 1, _suspicion, 0.35, 0.88, true];
			pr _color = [1.8* _colorMult, 1.8 * (1 - _colorMult), 0, 1];

			if (_suspicion > 1) then { _suspicion = 1; };
			if (_suspicion < 0) then { _suspicion = 0; };
			((uinamespace getVariable "undercoverUI_display") displayCtrl IDC_U_TOOLTIP) ctrlSetBackgroundColor [0,0,0,0];
			 
			// text display localize "STR_UM_OVERT"];
			pr _textUI = "";
			if (!(_bSuspicious) && _suspicion < 1) then { _textUI = format ["%1", localize "STR_UM_UNDERCOVER"]; };
			if (_bSuspicious) then { _textUI = format ["%1", localize "STR_UM_SUSPICIOUS"]; };
			if (_suspicion >= 1) then { _textUI = format ["%1", localize "STR_UM_OVERT"]; };

			if ( displayNull != (uinamespace getVariable "undercoverUI_display") ) then {
				((uinamespace getVariable "undercoverUI_display") displayCtrl IDC_U_SUSPICION_TEXT) ctrlSetText format ["%1", _textUI];
	  			((uinamespace getVariable "undercoverUI_display") displayCtrl IDC_U_SUSPICION_STATUSBAR) progressSetPosition _suspicion;
	  			((uinamespace getVariable "undercoverUI_display") displayCtrl IDC_U_SUSPICION_STATUSBAR) ctrlsettextcolor _color;

	  			((uinamespace getVariable "undercoverUI_display") displayCtrl IDC_U_SUSPICION_TEXT) ctrlCommit 0;
	  			((uinamespace getVariable "undercoverUI_display") displayCtrl IDC_U_SUSPICION_STATUSBAR) ctrlCommit 0;
	  			((uinamespace getVariable "undercoverUI_display") displayCtrl IDC_U_TOOLTIP) ctrlCommit 0;
	  		}; 
		
	} ENDMETHOD;


ENDCLASS;