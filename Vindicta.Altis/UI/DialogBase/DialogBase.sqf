#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\Resources\defineCommonGrids.hpp"
#include "..\..\common.h"
#include "..\Resources\UIProfileColors.h"
#include "DialogBase_Macros.h"

/*
Class : TacticalTablet

SQF class made to help streamline use of dialogs with standard appearence.
It has a headline, close button, hint bar, and an optinal multi-tab capability.

It has methods for singleton class template: newInstance, deleteInstance, getInstance.
To use them, you must add a static variable "instance" to your class.
*/

#define pr private

// Tab struct macros
#define __TAB_ID_CLASS_NAME	0
#define __TAB_ID_TEXT		1

#define __TAB_NEW()	[0, 0]

// We store the display in ui namespace and use _thisObject+this macro for var name
#define __DISPLAY_SUFFIX "_display"
#define __CTRL_THISOBJECT_VAR "_thisobject"

#define OOP_CLASS_NAME DialogBase
CLASS("DialogBase", "")

	// We set it to true in destructor to ensure proper work of event handlers
	VARIABLE("deleted");

	// ID of current tab
	VARIABLE("currentTabID");
	// OOP object handle of the current tab object
	VARIABLE("currentTabObj");

	// Array of tab structures
	VARIABLE("tabs");

	// Bool
	VARIABLE("multiTab");

	// W and H of the content area of the dialog
	VARIABLE("contentW");
	VARIABLE("contentH");

	// Event handler which will run in the destructor of this dialog
	VARIABLE("onDeleteCode");

	METHOD(new)
		params [P_THISOBJECT];

		OOP_INFO_0("NEW");

		// Create the dialog
		//pr _display = _displayParent createDisplay "MUI_DIALOG_BASE";
		pr _displayCreated = createDialog "MUI_DIALOG_BASE";
		pr _display = uiNamespace getVariable "gDialogBaseNewDisplay";
		_display setVariable ["__DialogBase_obj_ref", _thisObject];
		_display displayAddEventHandler ["Unload", {
			params ["_display", "_exitCode"];
			pr _thisObject = _display getVariable "__DialogBase_obj_ref";
			OOP_INFO_0("UNLOAD EVENT HANDLER");
			if (IS_OOP_OBJECT(_thisObject)) then {
				if (!T_GETV("deleted")) then {
					DELETE(_thisObject);
				};
			};
		}];

		// Add event handlers to buttons
		{
			_x params ["_idc", "_methodName"];
			pr _ctrl = _display displayCtrl _idc;
			_ctrl setVariable [__CTRL_THISOBJECT_VAR, _thisObject];
			_ctrl setVariable ["__methodName", _methodName];
			_ctrl ctrlAddEventHandler ["ButtonClick", {
				params ["_displayorcontrol", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
				pr _thisObject = _displayorcontrol getVariable __CTRL_THISOBJECT_VAR;
				pr _methodName = _displayorcontrol getVariable "__methodName";
				T_CALLM(_methodName, _this);
			}];
		} forEach	[
						[IDC_DIALOG_BASE_BUTTON_CLOSE, "onButtonClose"]
					];

		uiNamespace setVariable [_thisObject+__DISPLAY_SUFFIX, _display];
		T_SETV("deleted", false);
		T_SETV("multiTab", false);
		T_SETV("currentTabID", -1);
		T_SETV("currentTabObj", "");
		T_SETV("tabs", []);
		T_SETV("onDeleteCode", {});

		T_SETV("contentW", 0.7);
		T_SETV("contentH", 0.7);

		T_CALLM0("redraw");
		T_CALLM2("resize", T_GETV("contentW"), T_GETV("contentH"));

	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];

		OOP_INFO_0("DELETE");

		call T_GETV("onDeleteCode");

		pr _display = T_CALLM0("getDisplay");
		if (!isNull _display) then {
			T_SETV("deleted", true);
			_display closeDisplay 0;
		};

		pr _tabobj = T_GETV("currentTabObj");
		if (_tabobj != "") then {
			CALLM0(_tabObj, "beforeDelete");
			DELETE(_tabobj);
		};

		uiNamespace setVariable [_thisObject+__DISPLAY_SUFFIX, nil];
	ENDMETHOD;

	// Deletes this dialog on next frame
	// Sometimes deleting the dialog from an event handler can crash arma
	METHOD(deleteOnNextFrame)
		params [P_THISOBJECT];
		_thisObject spawn {DELETE(_this)}; // todo replace with CBA
	ENDMETHOD;

	// = = = = = = = = = = = = = = = = = = = = =
	// Singleton class template
	STATIC_METHOD(newInstance)
		params [P_THISCLASS, P_ARRAY("_constructorArguments")];

		pr _inst = GETSV(_thisClass, "instance");
		// Bail if it already exists
		if (!IS_NULL_OBJECT(_inst)) exitWith {
			_inst
		};

		// Create the object
		_inst = NEW(_thisClass, _constructorArguments);
		SETSV(_thisClass, "instance", _inst);

		_inst
	ENDMETHOD;

	STATIC_METHOD(deleteInstance)
		params [P_THISCLASS];

		pr _inst = GETSV(_thisClass, "instance");
		if (!IS_NULL_OBJECT(_inst)) then {
			DELETE(_inst);
			SETSV(_thisClass, "instance", NULL_OBJECT);
		};
	ENDMETHOD;

	STATIC_METHOD(getInstance)
		params [P_THISCLASS];
		pr _inst = GETSV(_thisClass, "instance");
		if (isNil "_inst") exitWith {NULL_OBJECT};
		_inst
	ENDMETHOD;

	// = = = = = = = = = = = = = = = = = = = = =

	// Adds an event handler which will run in the destructor of this dialog
	METHOD(onDelete)
		params [P_THISOBJECT, P_CODE("_code")];
		T_SETV("onDeleteCode", _code);
	ENDMETHOD;

	METHOD(enableMultiTab)
		params [P_THISOBJECT, P_BOOL("_enable")];
		T_SETV("multiTab", _enable);
		T_CALLM2("resize", T_GETV("contentW"), T_GETV("contentH"));
		T_CALLM0("redraw");
	ENDMETHOD;

	METHOD(setContentSize)
		params [P_THISOBJECT, P_NUMBER("_contentw"), P_NUMBER("_contenth")];
		T_SETV("contentW", _contentw);
		T_SETV("contentH", _contenth);
		T_CALLM2("resize", _contentw, _contenth);
	ENDMETHOD;

	METHOD(setHeadlineText)
		params [P_THISOBJECT, P_STRING("_text")];
		pr _ctrl = T_CALLM0("getDisplay") displayCtrl IDC_DIALOG_BASE_STATIC_HEADLINE;
		_ctrl ctrlSetText toUpper(_text);
	ENDMETHOD;

	METHOD(setHintText)
		params [P_THISOBJECT, P_STRING("_text")];
		pr _ctrl = T_CALLM0("getDisplay") displayCtrl IDC_DIALOG_BASE_STATIC_HINTS;
		_ctrl ctrlSetText _text;
	ENDMETHOD;

	METHOD(getDisplay)
		params [P_THISOBJECT];
		uiNamespace getVariable [_thisObject+__DISPLAY_SUFFIX, displayNull]
	ENDMETHOD;

	METHOD(getContentSize)
		params [P_THISOBJECT];
		[T_GETV("contentW"), T_GETV("contentH")]
	ENDMETHOD;

	// Performs one-time resize of controls according to dialog content size
	METHOD(resize)
		params [P_THISOBJECT, P_NUMBER("_contentw"), P_NUMBER("_contenth")];

		pr _multitab = T_GETV("multiTab");
		pr _display = uiNamespace getVariable [_thisObject+__DISPLAY_SUFFIX, displayNull];

		// Full width and height
		pr _fullw = _contentw;
		if (_multiTab) then {_fullw = _fullw + DIALOG_BASE_GROUP_TAB_BUTTONS_W; };
		pr _fullh = _contenth + DIALOG_BASE_STATIC_HEADLINE_H + DIALOG_BASE_STATIC_HINTS_H;

		// Offset position of the controls to center everything
		// todo should have put everything into a control instead...
		pr _ox = 0.5 - 0.5*_fullw;
		pr _oy = 0.5 - 0.5*_fullh;

		// Background
		pr _ctrl = _display displayCtrl IDC_DIALOG_BASE_STATIC_BACKGROUND;
		_ctrl ctrlSetPosition [0 + _ox, 0 + _oy, _fullw, _fullh];
		_ctrl ctrlCommit 0;

		// Headline
		pr _ctrl = _display displayCtrl IDC_DIALOG_BASE_STATIC_HEADLINE;
		_ctrl ctrlSetPosition [0 + _ox, 0 + _oy, _fullw, DIALOG_BASE_STATIC_HEADLINE_H];
		_ctrl ctrlCommit 0;
		
		// Top-right buttons
		pr _bclosex = _fullw - DIALOG_BASE_BUTTON_CLOSE_W;
		pr _bquestx = _fullw - 2*DIALOG_BASE_BUTTON_CLOSE_W;
		// Close X button
		pr _ctrl = _display displayCtrl IDC_DIALOG_BASE_BUTTON_CLOSE;
		_ctrl ctrlSetPosition [_ox + _bclosex, _oy + 0, DIALOG_BASE_BUTTON_CLOSE_W, DIALOG_BASE_STATIC_HEADLINE_H];
		_ctrl ctrlCommit 0;
		// Question '?' button
		pr _ctrl = _display displayCtrl IDC_DIALOG_BASE_BUTTON_QUESTION;
		_ctrl ctrlSetPosition [_ox + _bquestx, _oy + 0, DIALOG_BASE_BUTTON_CLOSE_W, DIALOG_BASE_STATIC_HEADLINE_H];
		_ctrl ctrlCommit 0;

		// Hint bar
		pr _hintx = 0;
		pr _hintw = _fullw;
		if (_multiTab) then {
			_hintx = DIALOG_BASE_GROUP_TAB_BUTTONS_W - 0.005;
			_hintw = _hintw - DIALOG_BASE_GROUP_TAB_BUTTONS_W  + 0.005;
		};
		pr _hinty = _fullh - DIALOG_BASE_STATIC_HINTS_H;
		pr _ctrl = _display displayCtrl IDC_DIALOG_BASE_STATIC_HINTS;
		_ctrl ctrlSetPosition [_ox + _hintx, _oy + _hinty, _hintw, DIALOG_BASE_STATIC_HINTS_H];
		_ctrl ctrlCommit 0;

		// Group of tab buttons and its BG
		pr _tbgrouph = _fullh - DIALOG_BASE_STATIC_HEADLINE_H; //- DIALOG_BASE_STATIC_HINTS_H;
		pr _ctrl = _display displayCtrl IDC_DIALOG_BASE_GROUP_TAB_BUTTONS;
		_ctrl ctrlSetPosition [_ox + 0, _oy + DIALOG_BASE_STATIC_HEADLINE_H, DIALOG_BASE_GROUP_TAB_BUTTONS_W, _tbgrouph];
		_ctrl ctrlCommit 0;
		
		pr _ctrl = _display displayCtrl IDC_DIALOG_BASE_STATIC_TAB_BUTTONS_BACKGROUND;
		_ctrl ctrlSetPosition [_ox + 0, _oy + DIALOG_BASE_STATIC_HEADLINE_H, DIALOG_BASE_GROUP_TAB_BUTTONS_W, _tbgrouph];
		_ctrl ctrlCommit 0;

		// Current tab control
		pr _tabobj = T_GETV("currentTabObj");
		if (_tabObj != "") then {
			pr _ctrl = CALLM0(_tabObj, "getControl");
			pr _contentx = 0;
			if (_multitab) then {
				_contentx = _contentx + DIALOG_BASE_GROUP_TAB_BUTTONS_W;
			};
			_ctrl ctrlSetPosition [_ox + _contentx, _oy + DIALOG_BASE_STATIC_HEADLINE_H, T_GETV("contentW"), T_GETV("contentH")];
			_ctrl ctrlCommit 0;

			// Call user-defined resize of the tab
			CALLM2(_tabobj, "resize", T_GETV("contentW"), T_GETV("contentH"));
		};

	ENDMETHOD;

	// Hides/shows appropriate controls according to settings
	// Doesn't resize anything
	METHOD(redraw)
		params [P_THISOBJECT];

		pr _display = T_CALLM0("getDisplay");

		// Hide/show the multi tab view
		{
			pr _ctrl = _display displayCtrl _x;
			_ctrl ctrlShow T_GETV("multiTab");
		} forEach [IDC_DIALOG_BASE_GROUP_TAB_BUTTONS, IDC_DIALOG_BASE_STATIC_TAB_BUTTONS_BACKGROUND];

		// todo hint bar, esc button, etc
	ENDMETHOD;

	// Returns new tab ID
	METHOD(addTab)
		params [P_THISOBJECT, P_STRING("_tabClass"), P_STRING("_tabText")];

		pr _display = T_CALLM0("getDisplay");

		pr _struct = __TAB_NEW();
		_struct set [__TAB_ID_CLASS_NAME, _tabClass];
		_struct set [__TAB_ID_TEXT, _tabText];

		// Add a button
		pr _tabs = T_GETV("tabs");
		pr _buttonID = count _tabs;
		pr _buttonIDC = IDC_DIALOG_BASE_TAB_BUTTONS_START + _buttonID;

		// Push the struct into array
		_tabs pushBack _struct;

		pr _ctrlGroup = _display displayCtrl IDC_DIALOG_BASE_GROUP_TAB_BUTTONS;
		OOP_INFO_1("CTRL GROUP: %1", _ctrlGroup);
		pr _ctrl = _display ctrlCreate ["MUI_BUTTON_TXT", _buttonIDC, _ctrlGroup];
		pr _gap = DIALOG_BASE_TAB_BUTTON_GAP;
		pr _buttonx = _gap;
		pr _buttony = (DIALOG_BASE_TAB_BUTTON_H + 2*_gap) * _buttonID + _gap;
		pr _buttonw = DIALOG_BASE_GROUP_TAB_BUTTONS_W - 2*_gap; // - 0.025; // Also account for the scroll bar
		pr _buttonh = DIALOG_BASE_TAB_BUTTON_H;
		_ctrl ctrlSetPosition [_buttonx, _buttony, _buttonw, _buttonh];
		_ctrl ctrlCommit 0;
		_ctrl ctrlSetText _tabText;
		_ctrl setVariable [__CTRL_THISOBJECT_VAR, _thisObject];
		_ctrl setVariable ["__tabID", _buttonID];

		// Add button event handlers
		_ctrl ctrlAddEventHandler ["ButtonClick", {
			params ["_displayorcontrol", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
			pr _thisObject = _displayorcontrol getVariable __CTRL_THISOBJECT_VAR;
			pr _tabid = _displayorcontrol getVariable "__tabID";
			OOP_INFO_1("EH: TAB BUTTON CLICK: %1", _tabid);
			T_CALLM1("onButtonTab", _tabid);
		}];

		// Return tab ID
		_buttonID
	ENDMETHOD;

	METHOD(onButtonTab)
		params [P_THISOBJECT, P_NUMBER("_tabID")];

		OOP_INFO_1("ON BUTTON TAB: %1", _tabID);
		T_CALLM1("setCurrentTab", _tabID);
	ENDMETHOD;

	// Sets the current tab
	METHOD(setCurrentTab)
		params [P_THISOBJECT, P_NUMBER("_tabID")];

		pr _tabs = T_GETV("tabs");

		// Bail if wrong tab ID is specified
		if (_tabID < 0 || (_tabID >= (count _tabs)) || (T_GETV("currentTabID") == _tabID)) exitWith {};

		// Delete old tab
		pr _tabObj = T_GETV("currentTabObj");
		if (_tabObj != "") then {
			CALLM0(_tabObj, "beforeDelete");
			DELETE(_tabObj);
		};

		// Create new tab
		pr _tabObjClassName = _tabs#_tabID#__TAB_ID_CLASS_NAME;
		_tabObj = NEW(_tabObjClassName, [_thisObject]);
		ASSERT_OBJECT_CLASS(_tabObj, "DialogTabBase");
		T_SETV("currentTabObj", _tabObj);

		// Resize the UI
		T_CALLM2("resize", T_GETV("contentW"), T_GETV("contentH"));

		T_SETV("currentTabID", _tabID);
	ENDMETHOD;

	/*
	Method: getCurrentTab

	Returns current tab object
	*/
	METHOD(getCurrentTab)
		params [P_THISOBJECT];

		T_GETV("currentTabObj");
	ENDMETHOD;

	METHOD(close)
		params [P_THISOBJECT];
		OOP_INFO_0("CLOSING");
		T_CALLM0("deleteOnNextFrame");
		// DELETE(_thisObject);
	ENDMETHOD;

	// Overridable methods
	// Derived classes can override these
	METHOD(onButtonClose)
		params [P_THISOBJECT];
		OOP_INFO_0("ON BUTTON CLOSE");
		T_CALLM0("close");
	ENDMETHOD;

	METHOD(onButtonQuestion)
		params [P_THISOBJECT];
		OOP_INFO_0("ON BUTTON QUESTION");
	ENDMETHOD;

ENDCLASS;