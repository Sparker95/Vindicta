#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
//#define NAMESPACE uiNamespace
#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Undercover\undercoverMonitor.hpp"
#include "..\Resources\UndercoverUI\UndercoverUI_Macros.h"

/*
Class: UndercoverUI
Handles the Undercover UI 
*/

#define CLASS_NAME "UndercoverUI"
#define pr private

CLASS(CLASS_NAME, "")
	
	STATIC_METHOD("drawUI") {
		params [["_thisObject", "", [""]], ["_unit", 0]];

			pr _suspicion = UNDERCOVER_GET_SUSPICION(_unit);
			systemChat format ["suspicion: %1", _suspicion];

			/* pr _textUI = "";



			if ( displayNull != (uinamespace getVariable "undercoverUI_display") ) then {
				((uinamespace getVariable "undercoverUI_display") displayCtrl IDC_U_SUSPICION_TEXT) ctrlSetText format ["%1", _textUI];
	  			((uinamespace getVariable "undercoverUI_display") displayCtrl IDC_U_SUSPICION_STATUSBAR) progressSetPosition _suspicion;
	  			((uinamespace getVariable "undercoverUI_display") displayCtrl IDC_U_SUSPICION_TEXT) ctrlCommit 0;
	  			((uinamespace getVariable "undercoverUI_display") displayCtrl IDC_U_SUSPICION_STATUSBAR) ctrlCommit 0;
	  		}; */
		
	} ENDMETHOD;

ENDCLASS;