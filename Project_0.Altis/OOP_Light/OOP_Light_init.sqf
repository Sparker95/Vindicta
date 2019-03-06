#include "OOP_Light.h"

/*
 * This file contains some functions for OOP_Light, mainly for asserting classess, objects and members.
 * Author: Sparker
 * 02.06.2018
*/

// Prints an error message with supplied text, file and line number
OOP_error = {
	params["_file", "_line", "_text"];
	diag_log format ["[OOP] Error: file: %1, line: %2, %3", _file, _line, _text];
};

// Print error when a member is not found
OOP_error_memberNotFound = {
	params ["_file", "_line", "_classNameStr", "_memNameStr"];
	private _errorText = format ["class '%1' has no member named '%2'", _classNameStr, _memNameStr];
	[_file, _line, _errorText] call OOP_error;
};

// Print error when a method is not found
OOP_error_methodNotFound = {
	params ["_file", "_line", "_classNameStr", "_methodNameStr"];
	private _errorText = format ["class '%1' has no method named '%2'", _classNameStr, _methodNameStr];
	[_file, _line, _errorText] call OOP_error;
};

//Print error when specified object is not an object
OOP_error_notObject = {
	params ["_file", "_line", "_objNameStr"];
	private _errorText = format ["'%1' is not an object (parent class not found)", _objNameStr];
	[_file, _line, _errorText] call OOP_error;
};

//Print error when specified class is not a class
OOP_error_notClass = {
	params ["_file", "_line", "_classNameStr"];
	private _errorText = "";
	if (isNil "_classNameStr") then {
		private _errorText = format ["class name is nil"];
		[_file, _line, _errorText] call OOP_error;
	} else {
		private _errorText = format ["class '%1' is not defined", _classNameStr];
		[_file, _line, _errorText] call OOP_error;
	};
};

//Print error when object's class is different from supplied class
OOP_error_wrongClass = {
	params ["_file", "_line", "_objNameStr", "_classNameStr", "_expectedClassNameStr"];
	private _errorText = format ["class of object %1 is %2, expected: %3", _objNameStr, _classNameStr, _expectedClassNameStr];
	[_file, _line, _errorText] call OOP_error;
};

//Check class and print error if it's not found
OOP_assert_class = {
	params["_classNameStr", "_file", "_line"];
	//Every class should have a member list. If it doesn't, then it's not a class
	private _memList = GET_SPECIAL_MEM(_classNameStr, STATIC_MEM_LIST_STR);
	//Check if it's a class
	if(isNil "_memList") then {
		[_file, _line, _classNameStr] call OOP_error_notClass;
		ade_dumpCallstack;
		false;
	} else {true};
};

//Check object class and print error if it differs from supplied
OOP_assert_objectClass = {
	params["_objNameStr", "_expectedClassNameStr", "_file", "_line"];

	//Get object's class
	private _classNameStr = OBJECT_PARENT_CLASS_STR(_objNameStr);
	//Check if it's an object
	if(isNil "_classNameStr") then {
		[_file, _line, _objNameStr] call OOP_error_notObject;
		ade_dumpCallstack;
		false;
	} else {
		private _parents = GET_SPECIAL_MEM(_classNameStr, PARENTS_STR);
		if (_expectedClassNameStr in _parents || _classNameStr == _expectedClassNameStr) then {
			true // all's fine
		} else {
			[_file, _line, _objNameStr, _classNameStr, _expectedClassNameStr] call OOP_error_wrongClass;
			ade_dumpCallstack;
			false
		};
	};
};

//Check object and print error if it's not an OOP object
OOP_assert_object = {
	params["_objNameStr", "_file", "_line"];
	//Get object's class
	private _classNameStr = OBJECT_PARENT_CLASS_STR(_objNameStr);
	//Check if it's an object
	if(isNil "_classNameStr") then {
		[_file, _line, _objNameStr] call OOP_error_notObject;
		ade_dumpCallstack;
		false;
	} else {
		true;
	};
};

//Check static member and print error if it's not found
OOP_assert_staticMember = {
	params["_classNameStr", "_memNameStr", "_file", "_line"];
	//Get static member list of this class
	private _memList = GET_SPECIAL_MEM(_classNameStr, STATIC_MEM_LIST_STR);
	//Check if it's a class
	if(isNil "_memList") exitWith {
		[_file, _line, _classNameStr] call OOP_error_notClass;
		ade_dumpCallstack;
		false;
	};
	//Check static member
	private _valid = _memNameStr in _memList;
	if(!_valid) then {
		[_file, _line, _classNameStr, _memNameStr] call OOP_error_memberNotFound;
		ade_dumpCallstack;
	};
	//Return value
	_valid
};

//Check member and print error if it's not found
OOP_assert_member = {
	params["_objNameStr", "_memNameStr", "_file", "_line"];
	//Get object's class
	private _classNameStr = OBJECT_PARENT_CLASS_STR(_objNameStr);
	//Check if it's an object
	if(isNil "_classNameStr") exitWith {
		private _errorText = format ["class name is nil. Attempt to access member: %1", _memNameStr];
		[_file, _line, _errorText] call OOP_error;
		ade_dumpCallstack;
		false;
	};
	//Get member list of this class
	private _memList = GET_SPECIAL_MEM(_classNameStr, MEM_LIST_STR);
	//Check member
	private _valid = _memNameStr in _memList;
	if(!_valid) then {
		[_file, _line, _classNameStr, _memNameStr] call OOP_error_memberNotFound;
		ade_dumpCallstack;
	};
	//Return value
	_valid
};

//Check method and print error if it's not found
OOP_assert_method = {
	params["_classNameStr", "_methodNameStr", "_file", "_line"];

	if (isNil "_classNameStr") exitWith {
		private _errorText = format ["class name is nil. Attempt to call method: %1", _methodNameStr];
		[_file, _line, _errorText] call OOP_error;
		ade_dumpCallstack;
		false;
	};

	//Get static member list of this class
	private _methodList = GET_SPECIAL_MEM(_classNameStr, METHOD_LIST_STR);
	//Check if it's a class
	if(isNil "_methodList") exitWith {
		[_file, _line, _classNameStr] call OOP_error_notClass;
		ade_dumpCallstack;
		false;
	};
	//Check method
	private _valid = _methodNameStr in _methodList;
	if(!_valid) then {
		[_file, _line, _classNameStr, _methodNameStr] call OOP_error_methodNotFound;
		ade_dumpCallstack;
	};
	//Return value
	_valid
};

// Dumps all variables of an object
OOP_dumpAllVariables = {
	params [["_thisObject", "", [""]]];
	// Get object's class
	private _classNameStr = OBJECT_PARENT_CLASS_STR(_thisObject);
	//Get member list of this class
	private _memList = GET_SPECIAL_MEM(_classNameStr, MEM_LIST_STR);
	diag_log format ["DEBUG: Dumping all variables of %1: %2", _thisObject, _memList];
	{
		private _varValue = GETV(_thisObject, _x);
		if (isNil "_varValue") then {
			diag_log format ["DEBUG: %1.%2: %3", _thisObject, _x, "<null>"];
		} else {
			diag_log format ["DEBUG: %1.%2: %3", _thisObject, _x, _varValue];
		}
	} forEach _memList;
};


// ---- Remote execution ----
// A remote code wants to execute something on this machine
// However remote machine doesn't have to know what class the object belongs to
// So we must find out object's class on this machine and then run the method
OOP_callFromRemote = {
	params[["_object", "", [""]], ["_methodNameStr", "", [""]], ["_params", [], [[]]]];
	//diag_log format [" --- OOP_callFromRemote: %1", _this];
	CALLM(_object, _methodNameStr, _params);
};

// If assertion is enabled, this gets called on remote machine when we call a static method on it
// So it will run the standard assertions before calling static method
OOP_callStaticMethodFromRemote = {
	params [["_classNameStr", "", [""]], ["_methodNameStr", "", [""]], ["_args", [], [[]]]];
	CALL_STATIC_METHOD(_classNameStr, _methodNameStr, _args);
};
