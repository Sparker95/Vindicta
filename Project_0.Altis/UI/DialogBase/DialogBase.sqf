#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\Resources\defineCommonGrids.hpp"
#include "..\..\OOP_Light\OOP_Light.h"
#include "..\Resources\UIProfileColors.h"
#include "..\Resources\DialogBase\DialogBase_Macros.h"

/*
Class : DialogBase

SQF class made to help streamline use of dialogs with standard appearence.
It has a headline, close button, hint bar, and an optinal multi-tab capability. 
*/

#define pr private

#define __DISPLAY_SUFFIX "_display"

CLASS("DialogBase", "")

	// Handle to the created display
	VARIABLE("IDD");
	// We set it to true in destructor to ensure proper work of event handlers
	VARIABLE("deleted");

	VARIABLE("multiTab");

	METHOD("new") {
		params [P_THISOBJECT, ["_displayParent", displayNull, [displayNull]]];

		// Create the dialog
		pr _display = _displayParent createDisplay "MUI_DIALOG_BASE";
		_display setVariable ["__DialogBase_obj_ref", _thisObject];
		_display displayAddEventHandler ["Unload", {
			params ["_display", "_exitCode"];
			pr _thisObject = "DialogBase";
			OOP_INFO_0("UNLOAD EVENT HANDLER");
			if (IS_OOP_OBJECT(_thisObject)) then {
				if (!T_GETV("deleted")) then {
					DELETE(_thisObject);
				};
			};
		}];

		uiNamespace setVariable [_thisObject+__DISPLAY_SUFFIX, _display];
		T_SETV("deleted", false);
		T_SETV("multiTab", true);

	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];

		pr _display = findDisplay T_GETV("IDD");
		if (!isNull _display) then {
			T_SETV("deleted", true);
			_display closeDisplay 0;
		};

		uiNamespace setVariable [_thisObject+__DISPLAY_SUFFIX, nil];
	} ENDMETHOD;

	METHOD("getDisplay") {
		params [P_THISOBJECT];
		uiNamespace getVariable [_thisObject+__DISPLAY_SUFFIX, displayNull]
	} ENDMETHOD;

	// takes width and height of user area
	METHOD("resize") {
		params [P_THISOBJECT, P_NUMBER("_userw"), P_NUMBER("_userh")];

		pr _multitab = T_GETV("multiTab");
		pr _display = uiNamespace getVariable [_thisObject+__DISPLAY_SUFFIX, displayNull];

		// Full width and height
		pr _fullw = _userw;
		if (_multiTab) then {_fullw = _fullw + DIALOG_BASE_GROUP_TAB_BUTTONS_W; };
		pr _fullh = _userh + DIALOG_BASE_STATIC_HEADLINE_H + DIALOG_BASE_STATIC_HINTS_H;
		pr _ctrl = _display displayCtrl IDC_DIALOG_BASE_STATIC_BACKGROUND;
		_ctrl ctrlSetPosition [0, 0, _fullw, _fullh];
		_ctrl ctrlCommit 0;

		// Headline
		pr _ctrl = _display displayCtrl IDC_DIALOG_BASE_STATIC_HEADLINE;
		_ctrl ctrlSetPosition [0, 0, _fullw, DIALOG_BASE_STATIC_HEADLINE_H];
		_ctrl ctrlCommit 0;

		// Top-right buttons
		pr _bclosex = _fullw - DIALOG_BASE_BUTTON_CLOSE_W;
		pr _bquestx = _fullw - 2*DIALOG_BASE_BUTTON_CLOSE_W;
		// Close btn
		pr _ctrl = _display displayCtrl IDC_DIALOG_BASE_BUTTON_CLOSE;
		_ctrl ctrlSetPosition [_bclosex, 0, DIALOG_BASE_BUTTON_CLOSE_W, DIALOG_BASE_STATIC_HEADLINE_H];
		_ctrl ctrlCommit 0;
		// Question btn
		pr _ctrl = _display displayCtrl IDC_DIALOG_BASE_BUTTON_QUESTION;
		_ctrl ctrlSetPosition [_bquestx, 0, DIALOG_BASE_BUTTON_CLOSE_W, DIALOG_BASE_STATIC_HEADLINE_H];
		_ctrl ctrlCommit 0;

		// Hint bar
		pr _hintx = 0;
		pr _hintw = _fullw;
		if (_multiTab) then {
			_hintx = DIALOG_BASE_GROUP_TAB_BUTTONS_W;
			_hintw = _hintw - DIALOG_BASE_GROUP_TAB_BUTTONS_W;
		};
		pr _hinty = _fullh - DIALOG_BASE_STATIC_HINTS_H;
		pr _ctrl = _display displayCtrl IDC_DIALOG_BASE_STATIC_HINTS;
		_ctrl ctrlSetPosition [_hintx, _hinty, _hintw, DIALOG_BASE_STATIC_HINTS_H];
		_ctrl ctrlCommit 0;

		// Group of tab buttons
		pr _tbgrouph = _fullh - DIALOG_BASE_STATIC_HEADLINE_H;
		pr _ctrl = _display displayCtrl IDC_DIALOG_BASE_GROUP_TAB_BUTTONS;
		_ctrl ctrlSetPosition [0, DIALOG_BASE_STATIC_HEADLINE_H, DIALOG_BASE_GROUP_TAB_BUTTONS_W, _tbgrouph];
		_ctrl ctrlCommit 0;

	} ENDMETHOD;

ENDCLASS;