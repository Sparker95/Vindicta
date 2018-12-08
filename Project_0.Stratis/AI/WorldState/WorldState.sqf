#include "WorldStateProperty.hpp"

#define pr private
#define WS_ID_WSP	0
#define WS_ID_WSPT	1

/*
WorldState class
WorldState is an array with WorldStateProperties
World State is a representation of the world relative to the agent

Author: Sparker 07.11.2018
*/

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
	pr _array_propTypes = []; // Array of WorldPropertyExists flags
	_i = 0;
	while {_i < _size} do {
		_array_propTypes set [_i, WSP_TYPE_DOES_NOT_EXIST]; // By default all world properties don't exist
		_i = _i + 1;
	};
	
	// Return
	[_array_WSP, _array_propTypes]
};

ws_getPropertyValue = {
	params [["_WS", [], [[]]], ["_key", 0, [0]]];
	_WS select WS_ID_WSP select _key
};

// Returns true if the property exists and is equal to supplied value
ws_propertyExistsAndEquals = {
	params [["_WS", [], [[]]], ["_key", 0, [0]], ["_value", 0, WSP_TYPES]];
	pr _prop = _WS select WS_ID_WSP select _key;
	pr _propTypes = _WS select WS_ID_WSPT; // property exists
	// Check both property existance and value
	if (((_propTypes select _key) != WSP_TYPE_DOES_NOT_EXIST) && (_prop isEqualTo _value)) then {
		true
	} else {
		false
	};
};

ws_setPropertyValue = {
	params [["_WS", [], [[]]], ["_key", 0, [0]], ["_value", 0, WSP_TYPES]];
	pr _properties = _WS select WS_ID_WSP;
	_properties set [_key, _value];
	
	pr _propTypes = _WS select WS_ID_WSPT;
	pr _type = WSP_TYPE_DOES_NOT_EXIST;
	call {
		if (_value isEqualType 0) exitWith {_type = WSP_TYPE_NUMBER; };
		if (_value isEqualType "") exitWith {_type = WSP_TYPE_STRING; };
		if (_value isEqualType objNull) exitWith {_type = WSP_TYPE_OBJECT_HANDLE; };
		if (_value isEqualType false) exitWith {_type = WSP_TYPE_BOOL; };
		if (_value isEqualType []) exitWith {_type = WSP_TYPE_ARRAY; };
	};
	_propTypes set [_key, _type];
};

// Must be used for goals or actions to specify that the property of world state depends on input parameter with _id
ws_setPropertyParameterID = {
	params [["_WS", [], [[]]], ["_key", 0, [0]], ["_id", 0, [0]]];
	pr _properties = _WS select WS_ID_WSP;
	_properties set [_key, _id];
	
	pr _propTypes = _WS select WS_ID_WSPT;
	_propTypes set [_key, WSP_TYPE_PARAMETER];
};

ws_clearProperty = {
	params [["_WS", [], [[]]], ["_key", 0, [0]]];
	pr _propTypes = _WS select WS_ID_WSPT;
	_propTypes set [_key, WSP_TYPE_DOES_NOT_EXIST]; // Property doesn't exist any more
};

// Returns a string in human readable form for debug purposes
ws_toString = {
	params [["_WS", [], [[]]]];
	pr _properties = _WS select WS_ID_WSP;
	pr _propTypes = _WS select WS_ID_WSPT;
	pr _strOut = "[";
	for "_i" from 0 to (count _properties) do {
		if ((_propTypes select _i) != WSP_TYPE_DOES_NOT_EXIST) then { // If this property exists, add it to the string array
			_strOut = _strOut + format ["%1:%2 ", _i, _properties select _i]; // Key, Value
		};
	};
	_strOut = _strOut + "]";
	
	// Return
	_strOut
};

/* Returns how two world states are connected

World states A and B are connected if any properties in A are equal to properties in B,
or if a property in A is an action/goal parameter which affects an existing property in B.

Return value: [_connected, _parameterID, _parameterValue]
_connected - bool
_parameterID - parameter ID that must be specific for goal/action, or -1 if nothing has to be specified
_parameterValue - value that must be specified, or 0
*/
ws_connectionParameters = {
	params [["_wsA", [], [[]]], ["_wsB", [], [[]]] ];
	
	pr _len = count _wsA;
	
	// Unpack the arrays
	pr _AProps = _wsA select WS_ID_WSP;
	pr _APropTypes = _wsA select WS_ID_WSPT;
	pr _BProps = _wsB select WS_ID_WSP;
	pr _BPropTypes = _wsB select WS_ID_WSPT;
	
	pr _connected = false;
	pr _parameterID = -1;
	pr _parameterValue = 0;
	
	// Check all properties
	for "_i" from 0 to _len do {
		scopeName "s";
		if ((_BPropTypes select _i) != WSP_TYPE_DOES_NOT_EXIST) then {			// If property exists in B AND
			if ((_APropTypes select _i) != WSP_TYPE_DOES_NOT_EXIST) then {		// If property exists in A
			
				// If property in A is a parameter which can affect a property in B
				if ((_APropTypes select _i) == WSP_TYPE_PARAMETER) then {
					_connected = true;
					_parameterID = _i;
					_parameterValue = _BProps select _i;
					breakOut "s";
				};
				
				// OR If both properties are equal
				if ( (_BProps select _i) isEqualTo (_AProps select _i) ) then {
				 	breakOut "s";
				};
			};
		};
	};
	
	// Return
	[_connected, _parameterID, _parameterValue]
};

/*
Returns number of unsatisfied properties between world state A and B
*/

ws_getNumUnsatisfiedProps = {
	params [["_wsA", [], [[]]], ["_wsB", [], [[]]] ];
	
	pr _len = count _wsA;
	pr _num = 0;
	
	// Unpack the arrays
	pr _AProps = _wsA select WS_ID_WSP;
	pr _APropTypes = _wsA select WS_ID_WSPT;
	pr _BProps = _wsB select WS_ID_WSP;
	pr _BPropTypes = _wsB select WS_ID_WSPT;
	
	for "_i" from 0 to _len do {
		if ((_APropTypes select _i) != WSP_TYPE_DOES_NOT_EXIST) then { // If this property exists in A
		
			// If this property doesn't exist in B
			if ((_BPropTypes select _i) == WSP_TYPE_DOES_NOT_EXIST) then {
				_num = _num + 1;
			};
			
			// If property values are different
			if ( ! ((_BProps select _i) isEqualTo (_AProps select _i)) ) then {
			 	_num = _num + 1;
			};
		};
	};
};