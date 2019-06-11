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
Class: LocationVisibilityMonitor
Periodycally checks which locations player can see

Author: Sparker 9 June 2019
*/

// Update interval in seconds
#define UPDATE_INTERVAL 6

// How far we need to travel from our previous pos to update the list of nearby locations
#define POS_TOLERANCE 250

// Maximum view distance toobserve locations
#define LOCATION_VIEW_DISTANCE_MAX 2300

#define pr private

CLASS("LocationVisibilityMonitor", "MessageReceiver") ;

	VARIABLE("timer");			// Timer
	VARIABLE("prevPos");		// Previous pos when we updated nearby locations
	VARIABLE("unit");			// Unit (object handle) this is attached to
	VARIABLE("nearLocations");	// Nearby locations which we will be checking periodycally
	VARIABLE("AICommander");	// AI Commander where we will send reports about locations
	VARIABLE("intelQuery");		// Temporary intel query object

	METHOD("new") {
		params [P_THISOBJECT, P_OBJECT("_unit")];

		T_SETV("prevPos", [0 ARG 0 ARG 0]);

		T_SETV("unit", _unit);

		T_SETV("nearLocations", []);

		T_SETV("intelQuery", NEW("IntelLocation", []));

		// Create timer
		pr _msg = MESSAGE_NEW();
		MESSAGE_SET_DESTINATION(_msg, _thisObject);
		MESSAGE_SET_TYPE(_msg, LVMON_MESSAGE_PROCESS);
		pr _updateInterval = UPDATE_INTERVAL;
		pr _args = [_thisObject, _updateInterval, _msg, gTimerServiceMain];
		pr _timer = NEW("Timer", _args);
		T_SETV("timer", _timer);

		pr _AICommander = CALLSM1("AICommander", "getCommanderAIOfSide", side group _unit);
		T_SETV("AICommander", _AICommander);
	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];

		// Delete the timer
		pr _timer = T_GETV("timer");
		if (_timer != "") then {
			DELETE(_timer);
		};

		DELETE(T_GETV("intelQuery"));
	} ENDMETHOD;

	METHOD("getMessageLoop") {
		gMsgLoopPlayerChecks
	} ENDMETHOD;

	METHOD("handleMessage") {
		params [P_THISOBJECT];

		OOP_INFO_0("PROCESS");

		pr _unit = T_GETV("unit");
		pr _AICommander = T_GETV("AICommander");
		pr _intelQuery = T_GETV("intelQuery");

		// Are we dead already?
		if (!alive _unit) exitWith {
			DELETE(_thisObject);
		};

		// Update nearby locations if needed
		pr _prevPos = T_GETV("prevPos");
		if ((_unit distance _prevPos) > POS_TOLERANCE) then {
			OOP_INFO_0("UPDATING NEAR LOCATIONS");
			pr _nearLocs = CALLSM2("Location", "nearLocations", getPosASL _unit, LOCATION_VIEW_DISTANCE_MAX);
			T_SETV("nearLocations", _nearLocs);
			T_SETV("prevPos", getPosASL _unit);
		};

		// Check stuff
		pr _nearLocs = T_GETV("nearLocations");
		OOP_INFO_1("Near locations: %1", _nearLocs);

		// Screen area, used for inArea command
		pr _screenArea = [[0.5, 0.5], 0.5*safeZoneW, 0.5*safeZoneH, 0, true];

		// Horizontal angle of our camera, taking into account zoom
		pr _p0 = AGLtoASL screenToWorld [safeZoneX+safeZoneW, safeZoneY+safeZoneH];
		pr _p1 = AGLtoASL screenToWorld [safeZoneX, safeZoneY+safeZoneH];
		pr _ep = eyePos _unit; // ASL
		pr _v0 = _p0 vectorDiff _ep;
		pr _v1 = _p1 vectorDiff _ep;
		pr _screenAngleX = acos (_v0 vectorCos _v1);

		// Eye position
		pr _eyePosASL = eyePos _unit;

		{ // forEach _nearLocs;
			pr _locPosAGL = +CALLM0(_x, "getPos");
			_locPosAGL set [2, 15];
			pr _locPosASL = AGLToASL _locPosAGL;

			// Check if we can see the location through objects and terrain
			if (([_unit, "view"] checkVisibility [_eyePosASL, _locPosASL]) > 0.8) then {

				// Check if the location is within screen area
				pr _locPosScreen = worldToScreen _locPosAGL;
				if (count _locPosScreen > 0) then { // If screen pos is [], it's not in the screen
					if (_locPosScreen inArea _screenArea) then {
						// Get visual angular size of the location
						pr _size = GETV(_x, "boundingRadius");
						pr _dist = _unit distance2D _locPosASL;
						pr _angularSize = 2*(_size atan2 _dist);
						pr _relativeAngularSize = _angularSize / _screenAngleX;
						//if () then {

						//};
						pr _type = GETV(_x, "type");
						pr _name = GETV(_x, "name");
						if (isNil "_name") then {_name = "_name_";};
						pr _dir = _unit getDir _locPosAGL;
						OOP_INFO_6("In area: %1 %2 %3, angular size: %4, relative angular size: %5 bearing: %6 deg", _x, _type, _name, _angularSize, _relativeAngularSize, _dir);

						// Ignore non-built locations and those which are too small visually
						if (GETV(_x, "isBuilt") && _relativeAngularSize > 0.02) then {
							// Check if we don't have any local intel about this place yet
							SETV(_intelQuery, "location", _x);
							pr _queryResult = CALLM1(gIntelDatabaseClient, "findFirstIntel", _intelQuery);
							if (_queryResult == "") then {
								if (random 100 < (10 + _relativeAngularSize/0.06*30)) then {
									// Send data to AI Commander
									OOP_INFO_1("Sending data to commander: %1", _x);
									CALLM2(_AICommander, "postMethodAsync", "updateLocationData", [_x ARG CLD_UPDATE_LEVEL_TYPE]);
								};
							};
						};
					};
				};
			};
		} forEach _nearLocs;



		

	} ENDMETHOD;

ENDCLASS;

/*
// Measure angle of view area
scriptCheck = 0 spawn {
while {true} do {
_p0 = AGLtoASL screenToWorld [safeZoneX+safeZoneW, safeZoneY+safeZoneH];
_p1 = AGLtoASL screenToWorld [safeZoneX, safeZoneY+safeZoneH];
_ep = eyePos player; // ASL
_v0 = _p0 vectorDiff _ep;
_v1 = _p1 vectorDiff _ep;
_angle = acos (_v0 vectorCos _v1);

systemChat format ["Angle: %1 deg", _angle];

sleep 1;
};
};
*/

/*
// Check if the position is within screen
_posWorld = pos0; // AGL
_posScreen = worldToScreen _posWorld;
_inScreen = true;
if (count _posScreen == 0) then {_inScreen = false; } else {
_inScreen = _posScreen inArea [[0.5, 0.5], 0.5*safeZoneW, 0.5*safeZoneH, 0, true];
};
diag_log format ["Pos screen: %1", _posScreen];
diag_log format ["Screen X: %1 ... %2, Y: %3 ... %4", safeZoneX, safeZoneX + safeZoneW, safeZoneY, safeZoneY + safeZoneH];
diag_log format ["In Screen: %1", _inScreen];
*/

/*
_size = 100;
_dist = 1000;
2*(0.5*_size atan2 _dist)
*/