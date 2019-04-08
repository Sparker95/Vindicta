#include "common.hpp"
/*
Handle message incoming into a garrison object.
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
//#include "..\Garrison\Garrison.hpp"

#define pr private

params [ ["_thisObject", "", [""]] , ["_msg", [], [[]]] ];
//diag_log format ["[Garrison] Info: HandleMessage: %1", _msg];

pr _msgType = _msg select MESSAGE_ID_TYPE;

if (_msgType == GARRISON_MESSAGE_PROCESS) then {
	
	//OOP_INFO_0("...1");
	
	pr _side = T_GETV("side");
	//OOP_INFO_0("...2");
	//OOP_INFO_0("...3");
	//OOP_INFO_1("Location: %1", _loc);
	pr _thisPos = CALLM0(_thisObject, "getPos");
	//OOP_INFO_0("...4");
	pr _units = CALL_METHOD(gLUAP, "getUnitArray", [_side]);
	//OOP_INFO_0("...5");
	pr _dst = _units apply {_x distance _thisPos};
	pr _speedMax = 200;
	pr _dstMin = if (count _dst > 0) then {selectMin _dst;} else {_speedMax*10};
	pr _dstSpawn = 1000; // Temporary, spawn distance
	pr _timer = T_GETV("timer");
	//OOP_INFO_0("...6");
	switch (T_GETV("spawned")) do {
		case false: { // Garrison is currently not spawned
			if (_dstMin < _dstSpawn) then {
				OOP_INFO_0("Spawning...");

				CALLM0(_thisObject, "spawn");				

				// Set timer interval
				CALLM1(_timer, "setInterval", 5);
				
				T_SETV("spawned", true);
			} else {
				// Set timer interval
				pr _dstToThreshold = _dstMin - _dstSpawn;
				pr _interval = (_dstToThreshold / _speedMax) max 1;
				pr _interval = 2; // todo override this some day later
				//diag_log format ["[Location] Info: interval was set to %1 for %2, distance: %3:", _interval, GET_VAR(_thisObject, "debugName"), _dstMin];
				CALLM1(_timer, "setInterval", _interval);
			};
		};
		case true: { // Garrison is currently spawned
			if (_dstMin > _dstSpawn) then {
				OOP_INFO_0("Despawning...");
				
				CALLM0(_thisObject, "despawn");
				
				T_SETV("spawned", false);
			};
		}; // case 1
	}; // switch spawn state
};

nil