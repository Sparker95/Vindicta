#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\Resources\defineCommonGrids.hpp"
#include "..\..\common.h"
#include "..\Resources\UIProfileColors.h"

/*
Class : TacticalTablet

Opens the tactical tablet display
*/

#define pr private

// We store the display in ui namespace and use _thisObject+this macro for var name
#define __DISPLAY_SUFFIX "_display"

// We use the 'events' to do timed actions with the dialog
#define __EVENT_ID_TYPE 0
#define __EVENT_ID_DATA 1
#define __EVENT_ID_DELAY 2
#define __EVENT_NEW(type, data, delay) [type, data, delay]

#define OOP_CLASS_NAME TacticalTablet
CLASS("TacticalTablet", "")

	STATIC_VARIABLE("instance");

	// We set it to true in destructor to ensure proper work of event handlers
	VARIABLE("deleted");

	// Current text the tablet is showing
	VARIABLE("text");

	VARIABLE("onEachFrameHandlerID");
	
	// Array with __EVENTs
	VARIABLE("eventQueue");
	// Time when we will pop the next event from the queue
	VARIABLE("timePopNextEvent");

	/* private */ METHOD(new)
		params [P_THISOBJECT];

		OOP_INFO_0("NEW");

		// Show an error if this was called without proper context
		if (isNil "__callContext") then {
			OOP_ERROR_0("TacticalTablet constructor is private! You must call newInstance static method instead!");
		};

		// Create the dialog
		//pr _display = _displayParent createDisplay "MUI_DIALOG_BASE";
		pr _displayCreated = createDialog "TACTICAL_TABLET";
		pr _display = uiNamespace getVariable "gTacticalTabletNewDisplay";
		_display setVariable ["__TacticalTablet_obj_ref", _thisObject];
		_display displayAddEventHandler ["Unload", {
			params ["_display", "_exitCode"];
			pr _thisObject = _display getVariable "__TacticalTablet_obj_ref";
			OOP_INFO_0("UNLOAD EVENT HANDLER");
			if (IS_OOP_OBJECT(_thisObject)) then {
				if (!T_GETV("deleted")) then {
					DELETE(_thisObject);
				};
			};
		}];

		uiNamespace setVariable [_thisObject+__DISPLAY_SUFFIX, _display];
		T_SETV("deleted", false);
		T_SETV("text", "");
		T_SETV("eventQueue", []);
		T_SETV("timePopNextEvent", -1); // -1 means we are not going to pop anything else right now

		// Add onEachFrame event handler
		pr _ehid = addMissionEventHandler ["EachFrame", {
			pr _inst = GETSV("TacticalTablet", "instance");
			if (!IS_NULL_OBJECT(_inst)) then {
				CALLM0(_inst, "onEachFrame");
			};
		}];
		T_SETV("onEachFrameHandlerID", _ehid);

		T_CALLM1("setText", "");
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];

		OOP_INFO_0("DELETE");

		pr _display = T_CALLM0("getDisplay");
		if (!isNull _display) then {
			T_SETV("deleted", true);
			_display closeDisplay 0;
		};

		// Delete onEachFrame handler
		removeMissionEventHandler ["EachFrame", T_GETV("onEachFrameHandlerID")];

		uiNamespace setVariable [_thisObject+__DISPLAY_SUFFIX, nil];

		SETSV("TacticalTablet", "instance", NULL_OBJECT);
	ENDMETHOD;


	// Static methods

	// Creates a dialog safely and returns its OOP object ref
	// Use that instead of the constructor please
	STATIC_METHOD(newInstance)
		params [P_THISCLASS];

		pr _inst = GETSV(_thisClass, "instance");
		// Bail if it already exists
		if (!IS_NULL_OBJECT(_inst)) exitWith {
			_inst
		};

		// Create the object
		pr __callContext = "createInstance";
		_inst = NEW("TacticalTablet", []);
		SETSV(_thisClass, "instance", _inst);

		_inst
	ENDMETHOD;

	/*
	STATIC_METHOD(deleteInstance)
		params [P_THISCLASS];

		pr _inst = GETSV(_thisClass, "instance");
		if (!IS_NULL_OBJECT(_inst)) then {
			DELETE(_inst);
			SETSV(_thisClass, "instance", NULL_OBJECT);
		};
	ENDMETHOD;
	*/

	STATIC_METHOD(getInstance)
		params [P_THISCLASS];
		GETSV("TacticalTablet", "instance");
	ENDMETHOD;
	//////////////////


	METHOD(getDisplay)
		params [P_THISOBJECT];
		uiNamespace getVariable [_thisObject+__DISPLAY_SUFFIX, displayNull]
	ENDMETHOD;

	METHOD(setText)
		params [P_THISOBJECT, P_STRING("_text")];
		pr _display = T_CALLM0("getDisplay");
		pr _ctrl = [_display, "TABLET_DISPLAY_TEXT"] call ui_fnc_findControl;
		_ctrl ctrlSetText _text;
		T_SETV("text", _text);
	ENDMETHOD;

	METHOD(appendText)
		params [P_THISOBJECT, P_STRING("_text")];
		pr _textNew = T_GETV("text") + _text;
		T_CALLM1("setText", _textNew);
	ENDMETHOD;

	// Appends text but with delay
	METHOD(appendTextDelay)
		params [P_THISOBJECT, P_STRING("_text"), P_NUMBER("_delay")];
		T_GETV("eventQueue") pushBack (__EVENT_NEW("append", _text, _delay));
	ENDMETHOD;

	STATIC_METHOD(staticAppendTextDelay)
		params [P_THISCLASS, P_STRING("_text"), P_NUMBER("_delay")];
		pr _inst = CALLSM0("TacticalTablet", "getInstance");
		if (!IS_NULL_OBJECT(_inst)) then {
			CALLM2(_inst, "appendTextDelay", _text, _delay);
		};
	ENDMETHOD;

	// Sets text but with delay
	METHOD(setTextDelay)
		params [P_THISOBJECT, P_STRING("_text"), P_NUMBER("_delay")];
		T_GETV("eventQueue") pushBack (__EVENT_NEW("set", _text, _delay));
	ENDMETHOD;

	METHOD(onEachFrame)
		params [P_THISOBJECT];

		// Process events in the queue
		pr _queue = T_GETV("eventQueue");
		if (count _queue > 0) then {
			pr _timeNext = T_GETV("timePopNextEvent");
			pr _event = _queue#0;
			_event params ["_eType", "_eData", "_eDelay"];
			if (_timeNext == -1) then {
				// We will pop this event when time is out
				_timeNext = time + _eDelay;
				T_SETV("timePopNextEvent", _timeNext);
			} else {
				if (time > _timeNext) then {
					switch (_eType) do {
						case "append": {
							T_CALLM1("appendText", _eData);
						};
						case "set": {
							T_CALLM1("setText", _eData);
						};
						default {
							OOP_ERROR_1("Wrong event type: %1", _event);
						};
					};
					
					_queue deleteAt 0;
					T_SETV("timePopNextEvent", -1);
				};
			};
		} else {
			T_SETV("timePopNextEvent", -1);
		};
	ENDMETHOD;

ENDCLASS;

if (isNil {GETSV("TacticalTablet", "instance")}) then {
	SETSV("TacticalTablet", "instance", NULL_OBJECT);
};