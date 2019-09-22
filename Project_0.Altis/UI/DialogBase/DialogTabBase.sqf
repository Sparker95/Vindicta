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
Class : DialogTabBase

SQF class that represents individual tabs of a <DialogBase>
*/

#define pr private

// We store the display in ui namespace and use _thisObject+this macro for var name
#define __CONTROL_SUFFIX "_control"

CLASS("DialogTabBase", "")

	// Private, don't call this on your own
	METHOD("new") {
		params [P_THISOBJECT, ["_displayParent", displayNull, [displayNull]]];

		OOP_INFO_0("NEW");

		pr _ctrl = T_CALLM1("createControl", _displayParent);
		uiNamespace setVariable [_thisObject+__CONTROL_SUFFIX, _ctrl];
	} ENDMETHOD;

	// Private, don't call this on your own
	METHOD("delete") {
		params [P_THISOBJECT];

		OOP_INFO_0("DELETE");

		// Delete the control
		ctrlDelete T_CALLM0("getControl");

		// Clear up the control variable
		uiNamespace setVariable [_thisObject+__CONTROL_SUFFIX, nil];
	} ENDMETHOD;

	// Derived classes must override this!
	// Create your tab control here (most likely group control)
	// Must return the handle of the created control
	METHOD("createControl") {
		params [P_THISOBJECT, ["_displayParent", displayNull, [displayNull]]];

		pr _ctrl = _displayParent ctrlCreate ["MUI_BASE", -1];
		_ctrl ctrlSetPosition [0, 0, 0.5, 0.5];
		_ctrl ctrlSetBackgroundColor [0.6, 0.1, 0.1, 0.8];
		_ctrl ctrlSetText _thisObject;
		_ctrl ctrlCommit 2.0;

		_ctrl
	} ENDMETHOD;

	// After creating the control, derived classes should call this in the constructor
	/*
	METHOD("setControl") {
		params [P_THISOBJECT, ["_ctrl", controlNull]];
		uiNamespace setVariable [_thisObject+__CONTROL_SUFFIX, _ctrl];
	} ENDMETHOD; */

	// Returns the control of this tab.
	METHOD("getControl") {
		params [P_THISOBJECT];
		uiNamespace getVariable [_thisObject+__CONTROL_SUFFIX, controlNull];
	} ENDMETHOD;
	
ENDCLASS;