#define OOP_DEBUG
#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OFSTREAM_FILE "Threads.rpt"
#include "..\common.h"
#include "..\Mutex\Mutex.hpp"
#include "..\Message\Message.hpp"
#include "..\CriticalSection\CriticalSection.hpp"
#include "ProcessCategories.hpp"

#define pr private

// Will log performance of process categories
#define LOG_PFH_PROCESS_CATEGORY

// Called every frame

params [P_THISOBJECT];

private _msgQueue = T_GETV("msgQueue");
private _mutex = T_GETV("mutex");

// Skip this update if mutex is locked
if (MUTEX_IS_LOCKED(_mutex)) exitWith {};

//Do we have anything in the queue?

#ifdef ASP_ENABLE
private _scopePFH = createProfileScope ([format ["MessageLoop_PFH_%1", T_GETV("name")]] call misc_fnc_createStaticString);
private _scopeMsgQueue = createProfileScope "MessageLoop_msgQueue";
#endif


if ( (count _msgQueue) > 0 ) then {
	private _countMessages = 0;
	private _countMessagesMax = T_GETV("nMessagesInSeries");

	while { (count _msgQueue) > 0 && (_countMessages < _countMessagesMax) } do {

		//Get a message from the front of the queue
		pr _msg = 0;
		// Take the message from the front of the queue
		_msg = _msgQueue select 0;
		// Delete the message
		_msgQueue deleteAt 0;

		private _msgID = _msg#MESSAGE_ID_SOURCE_ID;

		//Get destination object
		private _dest = _msg#MESSAGE_ID_DESTINATION;

		//Call handleMessage
		if(IS_OOP_OBJECT(_dest)) then {
			#ifdef PROFILE_MESSAGE_JSON
			private _objectClass = GET_OBJECT_CLASS(_dest);
			private _profileTimeStart = diag_tickTime;
			#endif

			private _result = CALLM(_dest, "handleMessage", [_msg]);

			#ifdef PROFILE_MESSAGE_JSON
			private _profileTime = diag_tickTime - _profileTimeStart;
			private _type = _msg#MESSAGE_ID_TYPE;
			private _str = format ["{ ""name"": ""%1"", ""msg"": { ""type"": ""%2"", ""destClass"": ""%3"", ""time"": %4, ""data"": %5} }", _name, _type, _objectClass, _profileTime, str (_msg#MESSAGE_ID_DATA)];
			OOP_DEBUG_MSG(_str, []);
			#endif

			if (isNil "_result") then {_result = 0;};
			// Were we asked to mark the message as processed?
			if (_msgID != MESSAGE_ID_NOT_REQUESTED) then {
				// Did the message originate from this machine?
				private _msgSourceOwner = _msg#MESSAGE_ID_SOURCE_OWNER;
				if (_msgSourceOwner == clientOwner) then {
					// Mark this message processed on this machine
					[_msgID, _result, _dest] call MsgRcvr_fnc_setMsgDone;
				} else {
					// Mark this message processed on the remote machine
					[_msgID, _result, _dest] remoteExecCall ["MsgRcvr_fnc_setMsgDone", _msgSourceOwner, false];
				};
			};
		} else {
			OOP_ERROR_1("Destination object does not exist: %1", _dest);
		};

		_countMessages = _countMessages + 1;
	};
};

#ifdef ASP_ENABLE
_scopeMsgQueue = nil;
#endif

// Process categories
// We only need to process these if the game is not paused
if (!isGamePaused) then {
	{
		pr _cat = _x;
		pr _tag = _cat#__PC_ID_TAG;

		#ifdef ASP_ENABLE
		private __scopeCat = createProfileScope ([format ["MessageLoop_processCategory_%1", _tag]] call misc_fnc_createStaticString);
		#endif
		FIX_LINE_NUMBERS()
		
		//pr _objects = +(_cat#__PC_ID_OBJECTS); // Make a deep copy for the case object is removed in the process call
		pr _objects = (_cat#__PC_ID_OBJECTS);
		pr _objectsHigh = (_cat#__PC_ID_OBJECTS_URGENT);
		pr _nObjects = count _objects;
		if (_nObjects > 0) then {
			pr _objID = (_cat#__PC_ID_NEXT_OBJECT_ID) % _nObjects; 		// Make sure ID is within array size
			pr _intervalMax = _cat#__PD_ID_UPDATE_INTERVAL_MAX;
			pr _nObjectsPerFrame = _nObjects/(_intervalMax*diag_fps);	// How many objects will be processed this frame, in ideal case
			pr _nObjectsPerFrameMax = _cat#__PC_ID_N_OBJECTS_PER_FRAME_MAX;
			pr _nObjectsPerFrameMin = _cat#__PC_ID_N_OBJECTS_PER_FRAME_MIN;
			//diag_log ([format ["DeltaTime: %1", diag_deltaTime]] call misc_fnc_createStaticString);
			
			// Remainder of the counter of processed objects (number 0..1)
			pr _counterRem = _cat#__PC_ID_OBJECT_COUNTER_REM;
			_counterRem = _counterRem + _nObjectsPerFrame;
			_cat set [__PC_ID_OBJECT_COUNTER_REM, (_counterRem - (floor _counterRem)) min 1.0]; // We don't want this to be more than 1

			// Process (floor _coutnerRem) objects, the remainder of this number will get added at next frame
			pr _nObjectsThisFrame = (floor _counterRem);

			// .. but limit the about of processed objects to min and max values
			_nObjectsThisFrame = (_nObjectsThisFrame max _nObjectsPerFrameMin) min _nObjectsPerFrameMax;

			// don't process more objects this time than there are objects, it will cause same object to be updated twice
			_nObjectsThisFrame = _nObjectsThisFrame min _nObjects;
			
			// Process high priority objects
			if ((count _objectsHigh > 0) && (_nObjectsThisFrame != 0)) then {

				#ifdef ASP_ENABLE
				private __scopeCatUrgent = createProfileScope ([format ["MessageLoop_processCategory_%1_urgent", _tag]] call misc_fnc_createStaticString);
				#endif

				while {(count _objectsHigh > 0) && (_nObjectsThisFrame != 0)} do {
					pr _objStruct = (_objectsHigh deleteAt 0);
					pr _obj = _objStruct#0;

					#ifdef ASP_ENABLE
					private __scopeObj = createProfileScope ([format ["MessageLoop_processObject_%1", _obj]] call misc_fnc_createStaticString);
					#endif

					// Ensure that object is valid
					// It's cheaper to check it here, than to check if it's in all object array when we set this object high priority
					// Because there might be very many objects in this process category
					if (IS_OOP_OBJECT(_obj)) then {
						CALLM0(_obj, "process");
					};

					_nObjectsThisFrame = _nObjectsThisFrame - 1;
				};
			};

			// Process normal objects
			while {_nObjectsThisFrame != 0} do {
				pr _objStruct = _objects#_objID;
				pr _obj = _objStruct#0;

				// Log performance of process category
				#ifdef LOG_PFH_PROCESS_CATEGORY
				FIX_LINE_NUMBERS()
				if (_objID == 0) then {	// Log every time we process object 0
					pr _timeCurrent = PROCESS_CATEGORY_TIME;
					pr _timeLastLog = _cat#__PC_ID_LAST_LOG_TIME;
					pr _timeSinceLastLog = _timeCurrent - _timeLastLog;
					if (_timeSinceLastLog > 5) then { // Don't spam it more than once per second!
						if (_objStruct#2) then {	// If it was processed already
							pr _str = format ["{ ""name"": ""%1"", ""processCategory"" : { ""name"" : ""%2"", ""nObjects"": %3, ""updateInterval"": %4, ""nObjectsPerFrame"": %5} }", //,  ""callTimeAvg"": %7} }", 
									T_GETV("name"), _cat#__PC_ID_TAG, _nObjects, _timeCurrent-(_objStruct#1), _nObjectsPerFrame];
							OOP_DEBUG_MSG(_str, []);
						};
						_cat set [__PC_ID_LAST_LOG_TIME, _timeCurrent];
					};
				};
				#endif

				#ifdef ASP_ENABLE
				private __scopeObj = createProfileScope ([format ["MessageLoop_processObject_%1", _obj]] call misc_fnc_createStaticString);
				#endif

				_objStruct set [1, PROCESS_CATEGORY_TIME]; // Set time mark when we processed this object last time
				//OOP_INFO_1("Processing %1", _objStruct);
				CALLM0(_obj, "process");
				_objStruct set [2, true]; // Set flag that this has been processed already

				_nObjectsThisFrame = _nObjectsThisFrame - 1;
				_objID = (_objID + 1) % _nObjects;
			};

			_cat set [__PC_ID_NEXT_OBJECT_ID, _objID];

		};
	} forEach T_GETV("processCategories");
};