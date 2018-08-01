#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "location.hpp"

params [ ["_thisObject", "", [""]] , ["_msg", [], [[]]] ];

private _msgType = _msg select MESSAGE_ID_TYPE;

//diag_log format ["[Location] Info: handle message: %1", _this];

switch (_msgType) do {
	case LOCATION_MESSAGE_PROCESS: {
		//diag_log format ["[Location] Info: process %1", GET_VAR(_thisObject, "debugName")];
		private _locPos = GET_VAR(_thisObject, "pos");
		private _spawnState = GET_VAR(_thisObject, "spawnState");
		private _garMilMain = GET_VAR(_thisObject, "garrisonMilMain");
		private _side = if (_garMilMain != "") then {CALL_METHOD(_garMilMain, "getSide", []);} else {WEST};
		private _units = CALL_METHOD(gLUAP, "getUnitArray", [_side]);
		private _dst = _units apply {_x distance _locPos};
		private _speedMax = 200;
		private _dstMin = if (count _dst > 0) then {selectMin _dst;} else {_speedMax*10};
		private _dstSpawn = 1000; // Temporary, spawn distance
		private _spawnState = GET_VAR(_thisObject, "spawnState");
		private _timer = GET_VAR(_thisObject, "timer");
		switch (_spawnState) do {
			case 0: { // Location is currently not spawned
				if (_dstMin < _dstSpawn) then {
					diag_log format ["[Location] Info: spawning %1", GET_VAR(_thisObject, "debugName")];
					
					// Spawn it now
					if (_garMilMain != "") then {CALL_METHOD(_garMilMain, "spawn", []);};
					// Set timer interval
					CALL_METHOD(_timer, "setInterval", [5]);
					
					SET_VAR(_thisObject, "spawnState", 1);
				} else {
					// Set timer interval
					private _dstToThreshold = _dstMin - _dstSpawn;
					private _interval = (_dstToThreshold / _speedMax) max 1;
					diag_log format ["[Location] Info: interval was set to %1 for %2, distance: %3:", _interval, GET_VAR(_thisObject, "debugName"), _dstMin];
					CALL_METHOD(_timer, "setInterval", [_interval]);
				};
			};
			case 1: { // Location is currently spawned
				if (_dstMin > _dstSpawn) then {
					diag_log format ["[Location] Info: despawning %1", GET_VAR(_thisObject, "debugName")];
					
					// Despawn it
					if (_garMilMain != "") then {CALL_METHOD(_garMilMain, "despawn", []);};
					
					SET_VAR(_thisObject, "spawnState", 0);
				};
			};
		};
	};
};