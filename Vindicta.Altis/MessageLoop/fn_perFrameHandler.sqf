#define OOP_DEBUG
#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OFSTREAM_FILE "Threads.rpt"
#include "..\OOP_Light\OOP_Light.h"
#include "..\Mutex\Mutex.hpp"
#include "..\Message\Message.hpp"
#include "..\CriticalSection\CriticalSection.hpp"
#include "ProcessCategories.hpp"

#define pr private

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
{
	pr _cat = _x;
	pr _tag = _cat#__PC_ID_TAG;

	#ifdef ASP_ENABLE
	private __scopeCat = createProfileScope ([format ["MessageLoop_processCategory_%1", _tag]] call misc_fnc_createStaticString);
	#endif

	pr _objects = _cat#__PC_ID_OBJECTS;
	pr _nObjects = count _objects;
	if (_nObjects > 0) then {
		pr _objID = (_cat#__PC_ID_NEXT_OBJECT_ID) % _nObjects; // Make sure ID is within array size
		pr _intervalMax = _cat#__PD_ID_UPDATE_INTERVAL_MAX;
		pr _nObjectsPerFrame = _nObjects/(_intervalMax*diag_fps);
		pr _counterRem = _cat#__PC_ID_OBJECT_COUNTER_REM; // Remainder of the coutner of processed objects (number 0..1)
		_counterRem = _counterRem + _nObjectsPerFrame;

		// Process (floor _coutnerRem) objects, the remainder of this number will get added at next frame
		pr _nObjectsThisFrame = (floor _counterRem) min _nObjects;	// Don't process same object twice this frame
		while {_nObjectsThisFrame != 0} do {
			pr _obj = _objects#_objID;

			#ifdef ASP_ENABLE
			private __scopeObj = createProfileScope ([format ["MessageLoop_processObject_%1", _obj]] call misc_fnc_createStaticString);
			#endif

			CALLM0(_object, "process");

			_nObjectsThisFrame = _nObjectsThisFrame - 1;
			_objID = (_objID + 1) % _nObjects;
		};

	};
} forEach T_GETV("processCategories");