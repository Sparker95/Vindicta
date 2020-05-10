#define OOP_INFO
#define OOP_ERROR
#define OOP_WARNING
#define OFSTREAM_FILE "AI.rpt"
#define PROFILER_COUNTERS_ENABLE
#include "..\..\common.h"
#include "..\..\Message\Message.hpp"
#include "..\..\CriticalSection\CriticalSection.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\Action\Action.hpp"
#include "..\..\defineCommon.inc"
#include "..\goalRelevance.hpp"
#include "..\Stimulus\Stimulus.hpp"
#include "AI.hpp"

/*
Class: AI
Base class for AI_GOAP.
It can manage world facts and sensors. Process method is empty.
Author: Sparker 03.03.2019
*/

#define pr private


#define AI_TIMER_SERVICE gTimerServiceMain

#define OOP_CLASS_NAME AI
CLASS("AI", "MessageReceiverEx")

	/* Variable: agent
	Holds a reference to the unit/group/whatever that owns this AI object*/
	/* save */	VARIABLE_ATTR("agent", [ATTR_SAVE]);		// Pointer to the unit which holds this AI object
	/* Variable: currentAction */
	/* save */	VARIABLE_ATTR("worldFacts", [ATTR_SAVE]);	// Array with world facts
				VARIABLE("timer");							// The timer of this object
				VARIABLE("processInterval");				// The update interval for the timer, in seconds
				VARIABLE("sensorStimulusTypes");			// Array with stimulus types of the sensors of this AI object
				VARIABLE("sensors");						// Array with sensors

	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_agent")];

		OOP_INFO_1("NEW %1", _this);

		PROFILER_COUNTER_INC("AI");

		// Make sure the required global objects exist
		ASSERT_GLOBAL_OBJECT(AI_TIMER_SERVICE);

		T_SETV("agent", _agent);
		T_SETV("sensors", []);
		T_SETV("sensorStimulusTypes", []);
		T_SETV("timer", "");
		T_SETV("processInterval", 1);
		T_SETV("worldFacts", []);
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------

	METHOD(delete)
		params [P_THISOBJECT];

		OOP_INFO_0("DELETE");

		PROFILER_COUNTER_DEC("AI");

		// Stop the AI if it is currently running
		T_CALLM("stop", []);

		// Delete all sensors
		pr _sensors = T_GETV("sensors");
		{
			DELETE(_x);
		} forEach _sensors;
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                              P R O C E S S
	// | Must be called every update interval
	// ----------------------------------------------------------------------

	METHOD(process)
		params [P_THISOBJECT];
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                    H A N D L E   M E S S A G E
	// |
	// ----------------------------------------------------------------------

	METHOD(handleMessageEx) //Derived classes must implement this method
		params [P_THISOBJECT, P_ARRAY("_msg") ];
		pr _msgType = _msg select MESSAGE_ID_TYPE;
		switch (_msgType) do {
			case AI_MESSAGE_PROCESS: {
				T_CALLM("process", []);
				true
			};

			case AI_MESSAGE_DELETE: {
				DELETE(_thisObject);
				true
			};

			default {false}; // Message not handled
		};
	ENDMETHOD;







	// ------------------------------------------------------------------------------------------------------
	// -------------------------------------------- S E N S O R S -------------------------------------------
	// ------------------------------------------------------------------------------------------------------




	// ----------------------------------------------------------------------
	// |                A D D   S E N S O R
	// | Adds a given sensor to the AI object
	// ----------------------------------------------------------------------
	/*
	Method: addSensor
	Adds a sensor to this AI object.

	Parameters: _sensor

	_sensor - <Sensor> or <SensorStimulatable>

	Returns: nil
	*/
	METHOD(addSensor)
		params [P_THISOBJECT, ["_sensor", "ERROR_NO_SENSOR", [""]]];

		ASSERT_OBJECT_CLASS(_sensor, "Sensor");

		// Add the sensor to the sensor list
		pr _sensors = T_GETV("sensors");
		_sensors pushBackUnique _sensor;

		// Check the stimulus types this sensor responds to
		pr _stimTypesSensor = CALLM0(_sensor, "getStimulusTypes");
		pr _stimTypesThis = T_GETV("sensorStimulusTypes");
		// Add the stimulus types to the stimulus type array
		{
			_stimTypesThis pushBackUnique _x;
		} forEach _stimTypesSensor;
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                    U P D A T E   S E N S O R S
	// | Update values of all sensors, according to their settings
	// ----------------------------------------------------------------------

	METHOD(updateSensors)
		params [P_THISOBJECT, ["_forceUpdate", false]];

		#ifdef ASP_ENABLE
		private _className = GET_OBJECT_CLASS(_thisObject);
		private __scopeUpdateSensors = createProfileScope ([format ["%1_updateSensors", _className]] call misc_fnc_createStaticString);
		#endif
		FIX_LINE_NUMBERS()

		pr _sensors = T_GETV("sensors");
		//OOP_INFO_1("Updating sensors: %1", _sensors);
		{
			pr _sensor = _x;

			// Update the sensor if it's time to update it
			pr _interval = CALLM0(_sensor, "getUpdateInterval"); // If it returns 0, we never update it
			if (_interval > 0) then {
				pr _timeNextUpdate = GETV(_sensor, "timeNextUpdate");
				//OOP_INFO_2("  Updating sensor: %1, time next update: %2", _sensor, _timeNextUpdate);
				if ((GAME_TIME > _timeNextUpdate) || _forceUpdate) then {
					//OOP_INFO_0("  Calling UPDATE!");
					//OOP_INFO_1("Updating sensor: %1", _sensor);

					#ifdef ASP_ENABLE
					private _className = GET_OBJECT_CLASS(_sensor);
					private __scopeSensor = createProfileScope ([format ["%1_update", _className]] call misc_fnc_createStaticString);
					#endif

					CALLM0(_sensor, "update");
					SETV(_sensor, "timeNextUpdate", GAME_TIME + _interval);
				};
			};
		} forEach _sensors;
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                    H A N D L E   S T I M U L U S
	// | Handles external stimulus.
	// ----------------------------------------------------------------------

	METHOD(handleStimulus)
		params [P_THISOBJECT, P_ARRAY("_stimulus") ];
		pr _type = _stimulus select STIMULUS_ID_TYPE;
		if (_type in T_GETV("sensorStimulusTypes")) then {
			pr _sensors = T_GETV("sensors");
			{
				pr _stimTypes = CALLM0(_x, "getStimulusTypes");
				if (_type in _stimTypes) then {
					CALLM(_x, "stimulate", [_stimulus]);
				};
			} foreach _sensors;
		};
	ENDMETHOD;
	
	
	// ------------------------------------------------------------------------------------------------------
	// -------------------------------------------- W O R L D   F A C T S -----------------------------------
	// ------------------------------------------------------------------------------------------------------

	// Adds a world fact
	METHOD(addWorldFact)
		params [P_THISOBJECT, P_ARRAY("_fact")];
		pr _facts = T_GETV("worldFacts");
		_facts pushBack _fact;
	ENDMETHOD;

	// Finds a world fact that matches a query
	// Returns the found world fact or nil if nothing was found
	METHOD(findWorldFact)
		params [P_THISOBJECT, P_ARRAY("_query")];
		pr _facts = T_GETV("worldFacts");
		pr _i = 0;
		pr _c = count _facts;
		pr _return = nil;
		while {_i < _c} do {
			pr _fact = _facts select _i;
			if ([_fact, _query] call wf_fnc_matchesQuery) exitWith {_return = _fact;};
			_i = _i + 1;
		};
		if (!isNil "_return") then {_return} else {nil};
	ENDMETHOD;

	// Finds all world facts that match a query
	// Returns array with facts that satisfy criteria or []
	METHOD(findWorldFacts)
		params [P_THISOBJECT, P_ARRAY("_query")];
		pr _facts = T_GETV("worldFacts");
		pr _i = 0;
		pr _c = count _facts;
		pr _return = [];
		while {_i < _c} do {
			pr _fact = _facts select _i;
			if ([_fact, _query] call wf_fnc_matchesQuery) then {_return pushBack _fact;};
			_i = _i + 1;
		};
		_return
	ENDMETHOD;

	// Deletes all facts that match query
	METHOD(deleteWorldFacts)
		params [P_THISOBJECT, P_ARRAY("_query")];
		pr _facts = T_GETV("worldFacts");
		pr _i = 0;
		while {_i < count _facts} do {
			pr _fact = _facts select _i;
			if ([_fact, _query] call wf_fnc_matchesQuery) then {_facts deleteAt _i} else {_i = _i + 1;};
		};
	ENDMETHOD;

	// Maintains the array of world facts
	// Deletes world facts that have exceeded their lifetime
	METHOD(updateWorldFacts)
		params [P_THISOBJECT];
		pr _facts = T_GETV("worldFacts");
		pr _i = 0;
		while {_i < count _facts} do {
			pr _fact = _facts select _i;
			if ([_fact] call wf_fnc_hasExpired) then {
				diag_log format ["[AI:updateWorldFacts] AI: %1, deleted world fact: %2", _thisObject, _fact];
				_facts deleteAt _i;
			} else {
				_i = _i + 1;
			};
		};
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                S T A R T
	// | Starts the AI brain in timer mode
	// ----------------------------------------------------------------------
	/*
	Method: start
	Starts the AI brain with timer. If this AI doesn't use timer, but a process category, override this.
	From now process method will be called periodically.
	*/
	METHOD(start)
		params [P_THISOBJECT];

		if (T_GETV("timer") == "") then {
			// Starts the timer
			private _msg = MESSAGE_NEW();
			_msg set [MESSAGE_ID_DESTINATION, _thisObject];
			_msg set [MESSAGE_ID_SOURCE, ""];
			_msg set [MESSAGE_ID_DATA, 0];
			_msg set [MESSAGE_ID_TYPE, AI_MESSAGE_PROCESS];
			pr _processInterval = T_GETV("processInterval");
			private _args = [_thisObject, _processInterval, _msg, AI_TIMER_SERVICE]; // message receiver, interval, message, timer service
			private _timer = NEW("Timer", _args);
			T_SETV("timer", _timer);

			// Post a message to process immediately to accelerate start up
			T_CALLM1("postMessage", +_msg);
		};

		nil
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                S T O P
	// | Stops the AI brain
	// ----------------------------------------------------------------------
	/*
	Method: stop
	Stops the periodic call of process function.
	*/
	METHOD(stop)
		params [P_THISOBJECT];
		
		// Delete this object from process category 
		T_CALLM0("removeFromProcessCategory");

		pr _timer = T_GETV("timer");
		if (_timer != "") then {
			T_SETV("timer", "");
			DELETE(_timer);
		};
		nil
	ENDMETHOD;



	// ----------------------------------------------------------------------
	// |               S E T   P R O C E S S   I N T E R V A L
	// | Sets the process interval of this AI object
	// ----------------------------------------------------------------------
	/*
	Method: setProcessInterval
	Sets the process interval of this AI object. Creates a timer.

	Parameters: _interval

	_interval - Number, interval in seconds.

	Returns: nil
	*/
	METHOD(setProcessInterval)
		params [P_THISOBJECT, ["_interval", 5, [5]]];
		T_SETV("processInterval", _interval);

		// If the AI object is already running, also change the interval of the timer which is already started
		pr _timer = T_GETV("timer");
		if (_timer != "") then {
			CALLM(_timer, "setInterval", [_interval]);
		};
	ENDMETHOD;

	/*
	Method: addToProcessCategory
	Adds this object to process category of its message loop.
	*/
	METHOD(addToProcessCategory)
		params [P_THISOBJECT, P_STRING("_tag")];
		pr _msgLoop = T_CALLM0("getMessageLoop");
		CALLM2(_msgLoop, "addProcessCategoryObject", _tag, _thisObject);
	ENDMETHOD;

	/*
	Method: setUrgentPriority
	Sets this object as high priority in its message loop
	*/
	METHOD(setUrgentPriority)
		params [P_THISOBJECT];
		OOP_INFO_0("setUrgentPriority");
		pr _msgLoop = T_CALLM0("getMessageLoop");
		CALLM1(_msgLoop, "setObjectUrgentPriority", _thisObject);
	ENDMETHOD;

	/*
	Method: removeFromProcessCategory

	Removes this object from all process categories
	*/
	METHOD(removeFromProcessCategory)
		params [P_THISOBJECT];
		pr _msgLoop = T_CALLM0("getMessageLoop");
		CALLM1(_msgLoop, "deleteProcessCategoryObject", _thisObject);
	ENDMETHOD;

	// - - - - STORAGE - - - - -

	/* override */ METHOD(postDeserialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];

		//diag_log "AI postDeserialize";

		// Call method of all base classes
		CALL_CLASS_METHOD("MessageReceiverEx", _thisObject, "postDeserialize", [_storage]);

		// Set reasonable default values
		T_SETV("timer", "");
		T_SETV("processInterval", 1);
		T_SETV("sensorStimulusTypes", []);
		T_SETV("sensors", []);

		// It's up to the inherited class's postDeserialize to restore these variables ^
		// By reinitializing sensors and doing other things

		true
	ENDMETHOD;
	
ENDCLASS;