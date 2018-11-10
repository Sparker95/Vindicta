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

// Returns a new WorldState object (kind of)
// Argument: [_count] - amount of entries

ws_new = {
	params [["_size", 0, [0]]];
	pr _array_WSP = [];
	
	// Array with WorldStateProperties
	pr _i = 0;
	while {_i < _size} do {
		_array_WSP set [_i, WSP_NEW(_i, 0)]; // Fill it with an array of WorldStateProperties
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

// Returns true if the property exists and is equal to supplied value
ws_propertyExistsAndEquals = {
	params [["_WS", [], [[]]], ["_key", 0, [0]], ["_value", 0, WSP_TYPES]];
	pr _prop = _WS select WS_ID_WSP select _key;
	pr _WSPE = _WS select WS_ID_WSPE; // property exists
	// Check both property existance and value
	if (_WSPE select _key && (_prop select WSP_ID_VALUE isEqualTo _value)) then {
		true
	} else {
		false
	};
};

ws_setPropertyValue = {
	params [["_WS", [], [[]]], ["_key", 0, [0]], ["_value", 0, WSP_TYPES]];
	pr _prop = _WS select WS_ID_WSP select _key;
	_prop set [WSP_ID_KEY, _key];
	_prop set [WSP_ID_VALUE, _value];
	pr _WSPE = _WS select WS_ID_WSPE;
	_WSPE set [_key, true];
};

ws_clearProperty = {
	params [["_WS", [], [[]]], ["_key", 0, [0]]];
	pr _WSPE = _WS select WS_ID_WSPE;
	_WSPE set [_key, 0]; // Property doesn't exist any more
};
