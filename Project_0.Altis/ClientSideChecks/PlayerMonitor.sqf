#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#include "..\OOP_light\OOP_light.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"
#include "..\AI\Stimulus\Stimulus.hpp"
#include "..\AI\stimulusTypes.hpp"
#include "..\AI\Commander\LocationData.hpp"

/*
Class: PlayerMonitor
Performs various periodic checks on client side.
Mainly we offload periodic heavy functions here, such as finding nearby objects.

!!!
Remember to ref-unref this object

Author: Sparker 19 September 2019
*/

// How far we need to travel from our previous pos to update the list of nearby locations
#define POS_TOLERANCE 15

// Maximum view distance to observe locations
#define LOCATION_VIEW_DISTANCE_MAX 2300

#define pr private

CLASS("PlayerMonitor", "MessageReceiverEx") ;

	VARIABLE("timer");			// Timer
	VARIABLE("timerUI");		// Timer for UI checks
	VARIABLE("prevPos");		// Previous pos when we updated nearby locations
	VARIABLE("unit");			// Unit (object handle) this is attached to
	VARIABLE("nearLocations");	// Nearby locations to return to other objects
	VARIABLE("currentLocations"); // Locations we are currently located at

	METHOD("new") {
		params [P_THISOBJECT, P_OBJECT("_unit")];

		T_SETV("prevPos", [0 ARG 0 ARG 0]);

		T_SETV("unit", _unit);

		T_SETV("nearLocations", []);
		T_SETV("currentLocations", []);

		// Create timer
		pr _msg = MESSAGE_NEW();
		MESSAGE_SET_DESTINATION(_msg, _thisObject);
		MESSAGE_SET_TYPE(_msg, "process");
		MESSAGE_SET_DATA(_msg, []);
		pr _updateInterval = 4;
		pr _args = [_thisObject, _updateInterval, _msg, gTimerServiceMain];
		pr _timer = NEW("Timer", _args);
		T_SETV("timer", _timer);

		// Create another timer, for Ui checks
		pr _msg = MESSAGE_NEW();
		MESSAGE_SET_DESTINATION(_msg, _thisObject);
		MESSAGE_SET_TYPE(_msg, "processUI");
		MESSAGE_SET_DATA(_msg, []);
		pr _updateInterval = 1;
		pr _args = [_thisObject, _updateInterval, _msg, gTimerServiceMain];
		pr _timer = NEW("Timer", _args);
		T_SETV("timerUI", _timer);

	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];

		// Delete the timer
		pr _timer = T_GETV("timer");
		if (_timer != "") then {
			DELETE(_timer);
		};

		pr _timer = T_GETV("timerUI");
		if (_timer != "") then {
			DELETE(_timer);
		};

	} ENDMETHOD;

	METHOD("getMessageLoop") {
		gMsgLoopPlayerChecks
	} ENDMETHOD;

	METHOD("process") {
		params [P_THISOBJECT];

		OOP_INFO_0("PROCESS");

		pr _unit = T_GETV("unit");

		// Are we dead already?
		if (!alive _unit) exitWith {
			// This will get unreferenced soon and will be deleted
		};

		// Update nearby locations if needed
		pr _prevPos = T_GETV("prevPos");
		if ((_unit distance _prevPos) > POS_TOLERANCE) then {
			OOP_INFO_0("UPDATING NEAR LOCATIONS");
			
			// Update nearby locations
			pr _posASL = getPosASL _unit;
			pr _nearLocs = CALLSM2("Location", "nearLocations", _posASL, LOCATION_VIEW_DISTANCE_MAX);
			T_SETV("nearLocations", _nearLocs);

			// Update current locations
			pr _currentLocs = CALLSM1("Location", "getLocationsAtPos", _posASL);
			T_SETV("currentLocations", _currentLocs);

			T_SETV("prevPos", getPosASL _unit);
		};

		OOP_INFO_1("NEAR LOCATIONS: %1", T_GETV("nearLocations"));
		OOP_INFO_1("CURRENT LOCATIONS: %1", T_GETV("currentLocations"));

	} ENDMETHOD;

	METHOD("processUI") {
		params [P_THISOBJECT];

		OOP_INFO_0("PROCESS UI");

		pr _unit = T_GETV("unit");
		pr _locs = T_GETV("currentLocations");
		if (count _locs != 0) then {
			// Get the nearest location
			_locs apply {[CALLM0(_x, "getPos") distance2D _unit, _x]};
			_locs sort true; // Ascending
			pr _loc = _locs#0;

			// Check if we know about this location
			/*
			pr _result0 = CALLM2(gIntelDatabaseClient, "getFromIndex", "location", _x);
			pr _result1 = CALLM2(gIntelDatabaseClient, "getFromIndex", OOP_PARENT_STR, "IntelLocation");
			pr _intelResult = (_result0 arrayIntersect _result1) select 0;
			if (! isNil "_intelResult") then {				
			};
			*/
			pr _text = format ["%1 %2", CALLM0(_loc, "getType"), CALLM0(_loc, "getName")];
			CALLM1(gInGameUI, "setLocationText", _text);
		} else {
			CALLM1(gInGameUI, "setLocationText", "no location");
		};
	} ENDMETHOD;

	METHOD("getCurrentLocations") {
		params [P_THISOBJECT];
		T_GETV("currentLocations")
	} ENDMETHOD;

	METHOD("getNearLocations") {
		params [P_THISOBJECT];
		T_GETV("nearLocations")
	} ENDMETHOD;

ENDCLASS;