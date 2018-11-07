/*
WorldState class
WorldState is an array with WorldStateProperties
World State is a representation of the world relative to the agent

Author: Sparker 07.11.2018
*/

#include "WorldStateProperty.hpp"

#define pr private
#define WS_ID_WSP	0
#define WS_ID_WSPE	1

ws_new = {
	params [["_size", 0, [0]]];
	pr _array_WSP = [];
	
	// Array with WorldStateProperties
	pr _i = 0;
	while {_i < _size} do {
		_array_WSP set [_i, WSP_NEW(_size, 0)]; // Fill it with an array of WorldStateProperties
		_i = _i + 1;
	};
	
	// Array with flags indicating if specified WSP exists or not
	pr _array_WSPE = []; // Array of WorldPropertyExists flags
	_i = 0;
	while {_i < _size} do {
		_array_WSPE set [_i, 0]; // By default all world properties don't exist
		_i = _i + 1;
	};
	
	// Return
	[_array_WSP, _array_WSPE]
};

ws_getPropertyValue = {
	params [["_WS", [], [[]]], ["_key", 0, [0]]];
	_WS select WS_ID_WSP select _key select WSP_ID_VALUE
};

ws_setPropertyValue = {
	params [["_WS", [], [[]]], ["_key", 0, [0]], ["_value", 0, [0, "", objNull]]];
	pr _prop = _WS select WS_ID_WSP select _key;
	_prop set [WSP_ID_KEY, _key];
	_prop set [WSP_ID_VALUE, _value];
	pr _WSPE = _WS select WS_ID_WSPE;
	_WSPE set [_key, 1];
};

ws_clearProperty = {
	params [["_WS", [], [[]]], ["_key", 0, [0]]];
	pr _WSPE = _WS select WS_ID_WSPE;
	_WSPE set [_key, 0]; // Property doesn't exist any more
};
