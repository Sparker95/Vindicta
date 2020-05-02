#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\..\common.h"

/*
Class: AttachToGarrisonDialog
Opens when a user wants to attach one unit he is looking at to the current garrison/location.
*/

#define pr private

#define OOP_CLASS_NAME AttachToGarrisonDialog
CLASS("AttachToGarrisonDialog", "DialogOneTabButtons")

	VARIABLE("unit");		// Unit
	VARIABLE("hO");			// Object handle
	VARIABLE("location");	// Location to which we will be trying to attach the unit
	VARIABLE("garrison");	// Garrison to which we will be trying to attach the unit
	VARIABLE("state");		// State of our communication with the server

	METHOD(new)
		params [P_THISOBJECT, P_OBJECT("_hO")];

		if (!isNil "gAttachToGarrisonDialog") then {
			OOP_WARNING_0("Attempt to create multiple dialogs AttachToGarrisonDialog!");
			DELETE(gAttachToGarrisonDialog);
		};

		// Set variables
		T_SETV("hO", _hO);
		pr _unit = CALLSM1("Unit", "getUnitFromObjectHandle", _hO);
		T_SETV("unit", _unit);
		pr _loc = CALLSM1("Location", "getLocationAtPos", getPos player);
		T_SETV("location", _loc);
		pr _gar = if (!isNil "gPlayerMonitor") then {
			CALLM0(gPlayerMonitor, "getCurrentGarrison");
		} else {
			OOP_ERROR_0("gPlayerMonitor does not exist!");
			NULL_OBJECT
		};
		T_SETV("garrison", _gar);
		T_SETV("state", -1);

		// Set appearence, add buttons, ...
		T_CALLM2("setContentSize", 0.7, 0.3); // Height will be determined by text height anyway
		T_CALLM1("setHeadlineText", "Attach unit to garrison");
		T_CALLM1("setHintText", "");
		T_CALLM1("createButtons", ["Attach"]);

		gAttachToGarrisonDialog = _thisObject;

		// Disable button until the answer arrives
		pr _ctrl = T_CALLM1("getButtonControl", 0);
		_ctrl ctrlEnable false;

		// Bail if wrong object...
		if (IS_NULL_OBJECT(_unit)) exitWith {
			T_CALLM1("setText", "Error: Wrong unit!\nPlease try again!");
		};

		// Bail if we aren't at location...
		if (IS_NULL_OBJECT(_loc)) exitWith {
			T_CALLM1("setText", "Error: There is no location to attach the unit!\nPlease try again!");
		};

		// All is fine! (for now)
		T_CALLM1("setText", "Data is loading...\n");
		pr _args = [clientOwner, _unit];

		// Request data from server ... let's hope it replies ...
		CALLM2(gGarrisonServer, "postMethodAsync", "getUnitData", _args);

	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];

		gAttachToGarrisonDialog = nil;
	ENDMETHOD;

	METHOD(onButtonClick)
		params [P_THISOBJECT, P_NUMBER("_ID")];

		OOP_INFO_0("ON BUTTON CLICK");

		// Bail if state is incorrect
		// Really event handler shouldn't even get triggered because the button is disabled but who knows...?!
		if(T_GETV("state") != 2) exitWith { // 2 is an OK code in this case
			OOP_ERROR_0("Wrong state");
		};

		// So far most of the parameters must have been verified by server

		// Send request to server
		pr _args = [clientOwner, T_GETV("unit"), T_GETV("garrison")];
		CALLM2(gGarrisonServer, "postMethodAsync", "attachUnit", _args);

	ENDMETHOD;

	STATIC_METHOD(staticShowServerResponse_0)
		params [P_THISOBJECT, P_OOP_OBJECT("_unit"), P_NUMBER("_code"), P_NUMBER("_unitCatID"), P_OOP_OBJECT("_gar"), P_SIDE("_garSide")];

		OOP_INFO_1("STATIC SHOW SERVER RESPONSE 0: %1", _this);

		pr _thisObject = gAttachToGarrisonDialog;
		if (isNil "_thisObject") exitWith {}; // Ignore this as we have already closed the dialog

		// Ignore this if it's not related to the unit we requested
		if (T_GETV("unit") != _unit) exitWith {};

		// Set state variable
		T_SETV("state", _code); // 2 is OK, everything else is some error code

		// Start formatting text...
		pr _str = "";

		// Unit's display name
		pr _hO = T_GETV("hO");
		pr _displayName = getText ( configFile >> "cfgVehicles" >> (typeOf _hO) >> "displayName" );
		_str = _str + (format ["Unit: %1\n", _displayName]);

		// Bail if unit is invalid
		if (_code == 0) exitWith {
			_str = _str + "Error: unit is not found on the server!\nPlease try again!";
			T_CALLM1("setText", _str);
		};

		// Bail if garrison is invalid
		if (_code == 1) exitWith {
			_str = _str + "Error: unit's garrison is wrong!\nPlease try again!";
			T_CALLM1("setText", _str);
		};

		// Bail if garrison is invalid
		if (_code == 3) exitWith {
			_str = _str + "Error: destination garrison is wrong!\nPlease try again!";
			T_CALLM1("setText", _str);
		};

		// Bail if the unit is already at this garrison
		// It's also a success condition after we have transfered the unit
		if (T_GETV("garrison") == _gar) exitWith {
			_str = _str + "This unit is already at this garrison!";
			T_CALLM1("setText", _str);
			// Disable button
			pr _ctrl = T_CALLM1("getButtonControl", 0);
			_ctrl ctrlEnable false;
		};

		// Can we attach this unit here?
		pr _canAttach = (_unitCatID == T_CARGO)			// Cargo boxes have no power to resist so their side is irrelevant
						|| (_garSide == playerSide);	// We must already own this vehicle by getting into it

		pr _locName = CALLM0(T_GETV("location"), "getDisplayName");
		if (_canAttach) then {
			_str = _str + (format ["Unit can be attached to %1\n", _locName]);
			pr _ctrl = T_CALLM1("getButtonControl", 0);
			_ctrl ctrlEnable true;
		} else {
			_str = _str + ( format ["We don't own this unit!\nWe can't attach the unit to %1.\n", _locName]);
		};

		// Set text
		T_CALLM1("setText", _str);

	ENDMETHOD;

ENDCLASS;