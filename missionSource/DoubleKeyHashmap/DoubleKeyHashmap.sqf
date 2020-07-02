#define OOP_INFO
#define OOP_DEBUG
#define OOP_WARNING
#define OOP_ERROR

#include "..\common.h"

/*
Class: DoubleKeyHashmap
It's a hashmap (aka namespace) which uses two string keys.
It uses CBA namespace as base.
Implementation is not ideal because it just combines two keys into one with a separator between them,
so in theory there might be conflicts, but it's fine for now.

Author: Sparker 22 August 2019
*/

#define pr private

// Separator
#define __SEP__ "-"

#define OOP_CLASS_NAME DoubleKeyHashmap
CLASS("DoubleKeyHashmap", "")

	// Namespace object
	VARIABLE("ns");

	METHOD(new)
		params [P_THISOBJECT];

		#ifndef _SQF_VM
		pr _ns = [false] call CBA_fnc_createNamespace;
		T_SETV("ns", _ns);
		#endif
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];

		pr _ns = T_GETV("ns");
		_ns call CBA_fnc_deleteNamespace;
	ENDMETHOD;

	/*
	Method: set
	Sets value associated with key0-key1 pair.

	Parameters: _k0, _k1, _value

	_k0 - String, Key 0
	_k1 - String, Key 1
	_value - anything, the value to set

	Returns: nil
	*/

	public virtual METHOD(set)
		params [P_THISOBJECT, P_STRING("_k0"), P_STRING("_k1"), "_value"];
		T_GETV("ns") setVariable [_k0 + __SEP__ + _k1, _value];
	ENDMETHOD;

	/*
	Method: get
	Returns value associated with key0-key1 pair.

	Parameters: _k0, _k1

	_k0 - String, Key 0
	_k1 - String, Key 1

	Returns: value
	*/

	public METHOD(get)
		params [P_THISOBJECT, P_STRING("_k0"), P_STRING("_k1")];
		T_GETV("ns") getVariable _k0 + __SEP__ + _k1
	ENDMETHOD;

	/*
	Method: getAllSecondaryKeys
	Returns all Key-1s associated with Key-0s.

	Parameters: _k0

	Returns: Array of strings
	*/

	public METHOD(getAllSecondaryKeys)
		params [P_THISOBJECT, P_STRING("_k0")];

		pr _ns = T_GETV("ns");

		// Select only those combined keys which have _k0 at start
		pr _allKeysCombined = (allVariables _ns) select { (_x find _k0) == 0 };

		// Return all _k1s by removing key start and separator
		pr _startID = count _k0 + count __SEP__;
		pr _return = _allKeysCombined apply {
			_x select [_startID, (count _x) - _startID] 
		};

		_return
	ENDMETHOD;

ENDCLASS;