#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OFSTREAM_FILE "ClientChecks.rpt"
#include "..\common.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"
#include "..\AI\Stimulus\Stimulus.hpp"
#include "..\AI\stimulusTypes.hpp"
#include "..\AI\Commander\LocationData.hpp"
#include "PlayerMonitor.hpp"
#include "..\CivilianPresence\CivilianPresence.hpp"
#include "..\Intel\Intel.hpp"
FIX_LINE_NUMBERS()

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

#define OOP_CLASS_NAME PlayerMonitor
CLASS("PlayerMonitor", "MessageReceiverEx") ;

	VARIABLE("timer");						// Timer
	VARIABLE("timerUI");					// Timer for UI checks
	VARIABLE("timerLowFreq");				// Timer for low frequency checks

	VARIABLE("prevPos");					// Previous pos when we updated nearby locations
	VARIABLE("unit");						// Unit (object handle) this is attached to
	VARIABLE("nearLocations");				// Nearby locations to return to other objects
	VARIABLE("currentLocation");			// The nearest location we are currently at
	VARIABLE("atFriendlyLocation");			// Bool, set to true if this location is friendly
	VARIABLE("currentLocations");			// Locations we are currently located at
	VARIABLE("currentGarrisonRecord");		// Garrison record at the current location
	VARIABLE("currentGarrison");			// Garrison linked to current garrison record
	VARIABLE("canBuild");

	VARIABLE("intelReminded");				// Intel we have reminded the player is starting soon
	VARIABLE("intelStarted");				// Intel we have reminded the player has started
	VARIABLE("playerGroupUnits");			// Cache for units known to be in the players group so we can determine when we need to update it

	METHOD(new)
		params [P_THISOBJECT, P_OBJECT("_unit")];

		T_SETV("prevPos", [0 ARG 0 ARG 0]);

		T_SETV("unit", _unit);

		T_SETV("nearLocations", []);
		T_SETV("currentLocation", "");
		T_SETV("atFriendlyLocation", false);
		T_SETV("currentLocations", []);
		T_SETV("currentGarrisonRecord", "");
		T_SETV("currentGarrison", "");
		T_SETV("canBuild", false);
		T_SETV("intelReminded", []);
		T_SETV("intelStarted", []);
		T_SETV("playerGroupUnits", []);

		// Create timer
		pr _msg = MESSAGE_NEW();
		MESSAGE_SET_DESTINATION(_msg, _thisObject);
		MESSAGE_SET_TYPE(_msg, "process");
		MESSAGE_SET_DATA(_msg, []);
		pr _updateInterval = 1.2;
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

		// Create another timer, for low frequency checks
		pr _msg = MESSAGE_NEW();
		MESSAGE_SET_DESTINATION(_msg, _thisObject);
		MESSAGE_SET_TYPE(_msg, "processLowFreq");
		MESSAGE_SET_DATA(_msg, []);
		pr _updateInterval = 30;
		pr _args = [_thisObject, _updateInterval, _msg, gTimerServiceMain];
		pr _timer = NEW("Timer", _args);
		T_SETV("timerLowFreq", _timer);

		_unit setVariable [PLAYER_MONITOR_UNIT_VAR, _thisObject];
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];

		// Delete the timer
		pr _timer = T_GETV("timer");
		DELETE(_timer);

		pr _timer = T_GETV("timerUI");
		DELETE(_timer);
		
		pr _timer = T_GETV("timerLowFreq");
		DELETE(_timer);

		T_GETV("unit") setVariable [PLAYER_MONITOR_UNIT_VAR, nil];

	ENDMETHOD;

	public override METHOD(getMessageLoop)
		gMsgLoopPlayerChecks
	ENDMETHOD;

	public METHOD(process)
		params [P_THISOBJECT];

		OOP_INFO_0("PROCESS");

		pr _unit = T_GETV("unit");

		// Are we dead already?
		if (!alive _unit) exitWith {
			// This will get unreferenced soon and will be deleted
		};

		// Update nearby locations if needed
		pr _prevPos = T_GETV("prevPos");
		pr _dist = _unit distance _prevPos;
		//if ((_dist) > POS_TOLERANCE) then { // What if new locations are created??
			OOP_INFO_0("UPDATING NEAR LOCATIONS");
			
			// Update nearby locations
			pr _posASL = getPosASL _unit;
			pr _nearLocs = CALLSM2("Location", "overlappingLocations", _posASL, LOCATION_VIEW_DISTANCE_MAX);
			T_SETV("nearLocations", _nearLocs);

			// Update current locations
			pr _locs = CALLSM1("Location", "getLocationsAtPos", _posASL);
			T_SETV("currentLocations", _locs);

			if (count _locs != 0) then {
				// Get the nearest location
				_locs = _locs apply {[CALLM0(_x, "getPos") distance2D _unit, _x]};
				_locs sort ASCENDING;
				pr _loc = _locs#0#1;
				T_SETV("currentLocation", _loc);

				// Check if the location has any garrisons we know about
				pr _garRecord = "";
				// We want a critical section here because garrison record can be easily deleted at any point
				CRITICAL_SECTION {
					_garRecord = CALLM1(gGarrisonDBClient, "getGarrisonRecordForLocation", _loc);
					T_SETV("currentGarrisonRecord", _garRecord);
					if (_garRecord != "") then {
						pr _gar = CALLM0(_garRecord, "getGarrison");
						T_SETV("currentGarrison", _gar);
					};
				};
				T_SETV("canBuild", _garRecord != "");
				T_SETV("atFriendlyLocation", _garRecord != "");
			} else {
				T_SETV("currentGarrisonRecord", "");
				T_SETV("currentGarrison", "");
				T_SETV("canBuild", false);
				T_SETV("currentLocation", "");
				T_SETV("atFriendlyLocation", false);
			};
			
		//};

		// If our position has changed a lot, send msg to the server to process nearby locations and garrisons
		if (_dist > 200) then {
			pr _newPos = getPos _unit;
			REMOTE_EXEC_CALL_STATIC_METHOD("Location", "processLocationsNearPos", [_newPos], 2, false);
			REMOTE_EXEC_CALL_STATIC_METHOD("Garrison", "updateSpawnStateOfGarrisonsNearPos", [_newPos], 2, false);
		};

		// Check if we are aiming a weapon at any civilian
		/*
		pr _co = cursorTarget;
		if (vehicle _unit isEqualTo _unit) then {										// If we are on foot
			if (_co getVariable [CIVILIAN_PRESENCE_CIVILIAN_VAR_NAME, false]) then {	// If target is a civilian created by civ presence
				if (!(weaponLowered _unit) && {currentWeapon _unit != ""}) then {			// If we have a gun and it's not lowered
					if ((_co distance _unit) < 10) then {									// If civilian is close to us
						[_co, _unit] call vin_fnc_cp_aimAtCivilian;
					};
				};
			};
		};
		*/

		// How to auto arrange AI in player groups:
		// If player is in a group with AI then AI must be moved to player garrison
		// If player garrison has groups in it that don't have players then these groups should be converted to garrisons and transferred back to 
		// the Cmdr AI.

		// Check for changes in players group
		private _currPlayerGroupUnits = units group player;
		private _oldPlayerGroupUnits = T_GETV("playerGroupUnits");
		if (count (_oldPlayerGroupUnits arrayIntersect _currPlayerGroupUnits) != count _oldPlayerGroupUnits) then {
			T_SETV("playerGroupUnits", units group player);
			REMOTE_EXEC_CALL_STATIC_METHOD("Garrison", "updatePlayerGroup", [player], ON_SERVER, NO_JIP);
		};

		OOP_INFO_1("NEAR LOCATIONS: %1", T_GETV("nearLocations"));
		OOP_INFO_1("CURRENT LOCATIONS: %1", T_GETV("currentLocations"));

		// Check if player is trying to fly an aircraft
		private _veh = vehicle player;
		if (_veh isKindOf "Air") then {
			//pr _unit = GET_UNIT_FROM_OBJECT_HANDLE(_veh);
			if ( /*!IS_NULL_OBJECT(_veh) &&*/ (isEngineOn _veh)) then {
				pr _phrasesCantFly = [
					"I don't know how to fly this, I am not a pilot.",
					"What does this switch do? I have no idea. I can't fly this.",
					"I really have no idea how to pilot this.",
					"There is no way I could pilot an aircraft.",
					"I should better switch this off, I have no idea what I am doing."
				];
				_veh vehicleChat (selectRandom _phrasesCantFly);
				_veh engineOn false;

				private _posATL = getPosATL _veh;
				if ((speed _veh > 40) || ((_posATL#2) > 20)) then {
					if (random 10 < 2) then {
						_veh vehicleChat "Damn, I should have stayed on the ground!";
						_veh setHitPointDamage ["hitvrotor", 1, true];
						_hits = (getAllHitPointsDamage _veh) select 0;
						{
							if ("engine" in _x) then {
								_veh setHitPointDamage [_x, 1, true];
							};
						} forEach _hits;
					};
				};
			};
		};

		T_SETV("prevPos", getPosASL _unit);
	ENDMETHOD;

	public METHOD(processUI)
		params [P_THISOBJECT];

		OOP_INFO_0("PROCESS UI");

		pr _unit = T_GETV("unit");
		pr _locs = T_GETV("currentLocations");
		pr _loc = T_GETV("currentLocation");
		pr _garRecord = T_GETV("currentGarrisonRecord");
		if (_loc != "") then {
			// Set current location text
			pr _locDispName = CALLM0(_loc, "getDisplayName");
			pr _locDispColor = CALLM0(_loc, "getDisplayColor");
			CALLM2(gInGameUI, "setLocationText", _locDispName, _locDispColor);

			// Check if the location has any garrisons we know about
			pr _buildRes = -1;
			CRITICAL_SECTION { // We want a critical section here because garrison record can be easily deleted at any point
				if (_garRecord != "") then {
					if (IS_OOP_OBJECT(_garRecord)) then {
						_buildRes = CALLM0(_garRecord, "getBuildResources");
					};
				};
			};
			CALLM1(gInGameUI, "setBuildResourcesAmount", _buildRes);
		} else {
			CALLM1(gInGameUI, "setLocationText", "");
			CALLM1(gInGameUI, "setBuildResourcesAmount", -1);
		};
	ENDMETHOD;

	public METHOD(processLowFreq)
		params [P_THISOBJECT];

		OOP_INFO_0("PROCESS LOW FREQ");

		pr _intelReminded = T_GETV("intelReminded");
		pr _intelStarted = T_GETV("intelStarted");

		pr _remindableActions = [
			"IntelCommanderActionReinforce",
			"IntelCommanderActionAttack",
			"IntelCommanderActionRecon",
			"IntelCommanderActionBuild",
			"IntelCommanderActionPatrol"
		];

		private _intelReminders = CALLM0(gIntelDatabaseClient, "getAllIntel") select {
			(GET_OBJECT_CLASS(_x) in _remindableActions)
			&& {
				(GETV(_x, "state") == INTEL_ACTION_STATE_INACTIVE && !(_x in _intelReminded))
				||
				{GETV(_x, "state") == INTEL_ACTION_STATE_ACTIVE && !(_x in _intelStarted)}
			}
		} apply {
			[CALLM0(_x, "getTMinutes"), _x]
		};
		// diag_log format["INTELR: %1", _intelReminders];
		_intelReminders = _intelReminders select {
			_x#0 >= -10 && _x#0 < 10 // reminder window
		};
		_intelReminders sort ASCENDING;

		{// forEach _intelReminders;
			_x params ["_t", "_intel"];

			// Make a string representation of time difference
			pr _h = floor (abs _t / 60);
			pr _m = floor (abs _t % 60);
			pr _tstr = if (_h > 0) then {
				format ["%1h %2m", _h, _m]
			} else {
				format ["%1m", _m]
			};
			pr _actionName = CALLM0(_intel, "getShortName");

			pr _args = if (_t < 0) then {
				["REMINDER", format ["%1 will start in %2", _actionName, _tstr]]
			} else {
				["STARTED", format ["%1 started %2 ago", _actionName, _tstr]]
			};

			CALLSM("NotificationFactory", "createIntelCommanderActionReminder", _args);

			pr _state = GETV(_intel, "state");
			if(_state == INTEL_ACTION_STATE_INACTIVE) then {
				_intelReminded pushBackUnique _intel;
			} else {
				_intelStarted pushBackUnique _intel;
			};
		} forEach _intelReminders;


		/*
			Hotfix for crappy night time experience, until we can skip night.

			We use setApertureNew based on tested values. We modify only then
			min parameter of the command for the following times, interpolating
			between them as time passes. I've tested the following times:

			18h min: 18
			19h min: 7
			20h min: 4
			21h min: 2.4
			22h min: 2.2
			23h min: 2
			0h min: 1.85
			1h min: 1.7
			2h min: 1.6
			3h min: 1.5
			4h min: 9
			5h min: 9
			6h min: 40
			7h min: 50

			To complete this, we would have to take moonphases into consideration.


		// index is the hour, value is the aperture min value
		pr _apertureTable = [
			1.85, 	// 0000
			1.6, 	// 0100
			1.5,	// 0200
			2.2,	// 0300
			2,		// 0400
			29,		// 0500
			37,		// 0600
			90,		// 0700
			90,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			22,		// 1800
			11,		// 1900
			2.6,	// 2000
			2,		// 2100
			1.6,	// 2200
			1.7,	// 2300
			1.65	// 0000 – because we do index + 1
		];


		pr _dateTime = date;
		pr _hour = (_dateTime#3);
		pr _minute = (_dateTime#4);

		// our night time is between 1800 and 0700 the day after
		if (_hour > 20 || _hour < 6) then {

			pr _hourVal = _apertureTable select _hour; // aperture min for current hour
			pr _nextHourVal = _apertureTable select (_hour+1); // aperture min for next full hour
			pr _hourValDiff = (selectMax [_hourVal, _nextHourVal]) - (selectMin [_hourVal, _nextHourVal]);
			pr _apertureMin = _hourVal + (_hourValDiff * linearConversion[0, 59, _minute, 0, 1, true]);
			pr _moonIntensity = linearConversion[0, 1, moonIntensity, 0.37, 1, true];
			_apertureMin = _apertureMin * _moonIntensity; // final aperture min

			// aperture base values
			// need to scale over time
			pr _apMax = _apertureMin * 1.15; // max slightly higher than min
			_args = [_apertureMin, 3, _apMax, 0.9];

			//systemChat format["Setting aperture values: %1", _args];
			setApertureNew _args; // set new aperture
		} else {
			//systemChat "Resetting aperture values.";
			setApertureNew [-1]; // reset
		};
		*/
	ENDMETHOD;

	public METHOD(getCurrentLocations)
		params [P_THISOBJECT];
		T_GETV("currentLocations")
	ENDMETHOD;

	public METHOD(getNearLocations)
		params [P_THISOBJECT];
		T_GETV("nearLocations")
	ENDMETHOD;

	public METHOD(getCurrentGarrison)
		params [P_THISOBJECT];
		T_GETV("currentGarrison")
	ENDMETHOD;

	public METHOD(isAtFriendlyLocation)
		params [P_THISOBJECT];
		T_GETV("atFriendlyLocation")
	ENDMETHOD;

	public STATIC_METHOD(canUnitBuildAtLocation)
		params [P_THISCLASS, "_unit"];
		pr _thisObject = _unit getVariable PLAYER_MONITOR_UNIT_VAR;
		if (!isNil "_thisObject") then {
			T_GETV("canBuild")
		} else {
			false
		};
	ENDMETHOD;

	public STATIC_METHOD(canUnitBuildFromInventory)
		params [P_THISCLASS, "_unit"];
		
	ENDMETHOD;

	public STATIC_METHOD(isUnitAtFriendlyLocation)
		params [P_THISCLASS, "_unit"];
		pr _thisObject = _unit getVariable PLAYER_MONITOR_UNIT_VAR;
		if (!isNil "_thisObject") then {
			T_GETV("atFriendlyLocation")
		} else {
			false
		};
	ENDMETHOD;

ENDCLASS;