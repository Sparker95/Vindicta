#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\Resources\defineCommonGrids.hpp"
#include "..\..\common.h"
#include "..\Resources\UIProfileColors.h"

/*
Class : DialogTabBase

SQF class that represents individual tabs of a <DialogBase>
*/

#define pr private

// We store the display in ui namespace and use _thisObject+this macro for var name
#define __CONTROL_SUFFIX "_control"

#define OOP_CLASS_NAME DialogTabBase
CLASS("DialogTabBase", "")

	VARIABLE("dialogObj");

	STATIC_VARIABLE("instance");	// Derived classes must manage this variable
									// If they need "getInstance" to work

	// Private, don't call this on your own
	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_dialogObj")];

		T_SETV("dialogObj", _dialogObj);

		OOP_INFO_0("NEW");

		// Example of how to create the controls for derived tab classes
		/*	
		pr _displayParent = T_CALLM0("getDisplay");
		pr _ctrl = _displayParent ctrlCreate ["MUI_BASE", -1];
		_ctrl ctrlSetPosition [0, 0, 0.5, 0.5];
		_ctrl ctrlSetBackgroundColor [0.6, 0.1, 0.1, 0.8];
		_ctrl ctrlSetText _thisObject;
		_ctrl ctrlCommit 0.0;
		*/

		T_CALLM1("setControl", controlNull);
	ENDMETHOD;

	// Private, don't call this on your own
	METHOD(delete)
		params [P_THISOBJECT];

		OOP_INFO_0("DELETE");

		// Delete the control
		ctrlDelete T_CALLM0("getControl");

		// Clear up the control variable
		uiNamespace setVariable [_thisObject+__CONTROL_SUFFIX, nil];
	ENDMETHOD;

	/*
	Method: getControl
	Returns the control of this tab, previously set by setControl
	*/
	public METHOD(getControl)
		params [P_THISOBJECT];
		uiNamespace getVariable [_thisObject+__CONTROL_SUFFIX, controlNull];
	ENDMETHOD;

	/*
	Method: setControl
	Sets the control (typically group control with child controls) associated with this tab.
	You must call this method from within the constructor of the derived class after creating the control group for this tab.

	Parameters: 
	*/
	public METHOD(setControl)
		params [P_THISOBJECT, ["_control", controlNull, [controlNull]]];

		pr _ctrl = uiNamespace getVariable [_thisObject+__CONTROL_SUFFIX, controlNull];
		ctrlDelete _ctrl; // Just to be sure, delete the previous control

		uiNamespace setVariable [_thisObject+__CONTROL_SUFFIX, _control];
	ENDMETHOD;

	public METHOD(getDisplay)
		params [P_THISOBJECT];
		CALLM0(T_GETV("dialogObj"), "getDisplay")
	ENDMETHOD;

	public METHOD(getDialogObject)
		params [P_THISOBJECT];
		T_GETV("dialogObj")
	ENDMETHOD;

	// Finds a control by its class name or tag assigned by createControl
	public METHOD(findControl)
		params [P_THISOBJECT, P_STRING("_className")];
		pr _display = T_CALLM0("getDisplay");
		OOP_INFO_1("FIND CONTROL: %1", _className);
		OOP_INFO_1(" DISPLAY: %1", _display);
		pr _allControls = allControls _display;
		//OOP_INFO_1(" ALL CONTROLS: %1", _allControls);
		pr _index = _allControls findIf {_className in [ctrlClassName _x, _x getVariable ["__tag", ""]]};
		if (_index != -1) then {
			OOP_INFO_1("  found control: %1", _allControls select _index);
			_allControls select _index
		} else {
			OOP_WARNING_1("  control not found: %1", _className);
			controlNull
		};
	ENDMETHOD;

	protected METHOD(createControl)
		params [P_THISOBJECT, P_STRING("_className"), ["_idc", -1, [0]], ["_controlsGroup", controlNull, [controlNull]], P_STRING("_tag")];

		OOP_INFO_1("CREATE CONTROL: %1", _this);

		if (_tag == "") then {_tag = "666"};

		pr _display = T_CALLM0("getDisplay");
		pr _ctrl = controlNull;
		if (isNull _controlsGroup) then {
			_ctrl = _display ctrlCreate [_className, _idc];
		} else {
			_ctrl = _display ctrlCreate [_className, _idc, _controlsGroup];
		};

		// Set tag to be used by findControl
		_ctrl setVariable ["__tag", _tag];

		OOP_INFO_1("  created control: %1", _ctrl);

		// Return control
		_ctrl
	ENDMETHOD;
	
	// Adds an event handler which will call some method of this object
	protected METHOD(controlAddEventHandler)
		params [P_THISOBJECT, P_STRING("_className"), P_STRING("_type"), P_STRING("_methodName")];

		pr _ctrl = T_CALLM1("findControl", _className);
		_ctrl setVariable ["__tabobject", _thisObject];
		_ctrl setVariable ["__methodName", _methodName];
		_ctrl ctrlAddEventHandler [_type, {
			pr _ctrl = _this#0;
			pr _thisObject = _ctrl getVariable "__tabobject";
			pr _methodName = _ctrl getVariable "__methodName";
			T_CALLM(_methodName, _this);
		}];
	ENDMETHOD;

	// Called before this tab is deleted but when controls still exist
	// Override for custom functionality
	public virtual METHOD(beforeDelete)
		params [P_THISOBJECT];
	ENDMETHOD;

	// Called when Dialog.resize is called
	// Derived classes can implement this if they need to resize themselves
	// The main control of the tab (group) is resized separately, no need to resize it
	public virtual METHOD(resize)
		params [P_THISOBJECT, P_NUMBER("_width"), P_NUMBER("_height")];
	ENDMETHOD;

	// Method for showing various responses from the server
	// By default it outputs the text to the hint bar at the bottom
	public STATIC_METHOD(showServerResponse)
		params [P_THISCLASS, P_STRING("_text")];
		pr _instance = CALLSM0(_thisClass, "getInstance");
		if (!isNil "_instance") then {
			if (!IS_NULL_OBJECT(_instance)) then {
				pr _thisObject = _instance;
				pr _dialogObj = T_CALLM0("getDialogObject");
				CALLM1(_dialogObj, "setHintText", _text);
			};
		};
	ENDMETHOD;

	// Typically there is only one instance of each tab on the screen
	// So there is a method to get the OOP object handle
	// By default it reads the "instance" static variable of the current class
	public STATIC_METHOD(getInstance)
		params [P_THISCLASS];
		pr _instance = GETSV(_thisClass, "instance");
		if (isNil "_instance") exitWith {NULL_OBJECT};
		_instance
	ENDMETHOD;

ENDCLASS;