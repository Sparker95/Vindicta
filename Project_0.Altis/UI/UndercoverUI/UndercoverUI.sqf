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
		params [["_thisObject", "", [""]], ["_unit", 0]];

			pr _uM = _unit getVariable "undercoverMonitor";
			pr _suspicion = CALLM0(_uM, "getSuspicion");
			pr _bSuspicious = CALLM0(_uM, "getIsSuspicious");
			if (_suspicion > 1) then { _suspicion = 1; };
			if (_suspicion < 0) then { _suspicion = 0; };
			((uinamespace getVariable "undercoverUI_display") displayCtrl IDC_U_TOOLTIP) ctrlSetBackgroundColor [0,0,0,0];
			 
			// text display
			pr _textUI = "";
			if (_bSuspicious) then { _textUI = "SUSPICIOUS"; };
			if (_suspicion >= 1) then { _textUI = "HOSTILE"; };
			if (!(_bSuspicious) && _suspicion < 1) then { _textUI = "UNDERCOVER"; };

			if ( displayNull != (uinamespace getVariable "undercoverUI_display") ) then {
				((uinamespace getVariable "undercoverUI_display") displayCtrl IDC_U_SUSPICION_TEXT) ctrlSetText format ["%1", _textUI];
	  			((uinamespace getVariable "undercoverUI_display") displayCtrl IDC_U_SUSPICION_STATUSBAR) progressSetPosition _suspicion;

	  			((uinamespace getVariable "undercoverUI_display") displayCtrl IDC_U_SUSPICION_TEXT) ctrlCommit 0;
	  			((uinamespace getVariable "undercoverUI_display") displayCtrl IDC_U_SUSPICION_STATUSBAR) ctrlCommit 0;
	  			((uinamespace getVariable "undercoverUI_display") displayCtrl IDC_U_TOOLTIP) ctrlCommit 0;
	  		}; 
		
	} ENDMETHOD;

ENDCLASS;