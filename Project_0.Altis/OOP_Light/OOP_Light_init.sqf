OOP_Light_initialized = true;

#include "OOP_Light.h"

/*
 * This file contains some functions for OOP_Light, mainly for asserting classess, objects and members.
 * Author: Sparker
 * 02.06.2018
*/

// Prints an error message with supplied text, file and line number
OOP_error = {
	params["_file", "_line", "_text"];
	private _msg = format ["[OOP] Error: file: %1, line: %2, %3", _file, _line, _text];
	diag_log _msg;
	try
	{
		throw [_file, _line, _msg];
	}
	catch
	{
		terminate _thisScript;
		throw _exception;
	}
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
		DUMP_CALLSTACK;
		false;
	} else {true};
};

//Check object class and print error if it differs from supplied
OOP_assert_objectClass = {
	params["_objNameStr", "_expectedClassNameStr", "_file", "_line"];

	if(!(_objNameStr isEqualType "")) then {
		[_file, _line, _objNameStr] call OOP_error_notObject;
		DUMP_CALLSTACK;
		false;
	};

	//Get object's class
	private _classNameStr = OBJECT_PARENT_CLASS_STR(_objNameStr);
	//Check if it's an object
	if(isNil "_classNameStr") then {
		[_file, _line, _objNameStr] call OOP_error_notObject;
		DUMP_CALLSTACK;
		false;
	} else {
		private _parents = GET_SPECIAL_MEM(_classNameStr, PARENTS_STR);
		if (_expectedClassNameStr in _parents || _classNameStr == _expectedClassNameStr) then {
			true // all's fine
		} else {
			[_file, _line, _objNameStr, _classNameStr, _expectedClassNameStr] call OOP_error_wrongClass;
			DUMP_CALLSTACK;
			false
		};
	};
};

//Check object and print error if it's not an OOP object
OOP_assert_object = {
	params["_objNameStr", "_file", "_line"];

	if(!(_objNameStr isEqualType "")) then {
		[_file, _line, _objNameStr] call OOP_error_notObject;
		DUMP_CALLSTACK;
		false;
	};

	//Get object's class
	private _classNameStr = OBJECT_PARENT_CLASS_STR(_objNameStr);
	//Check if it's an object
	if(isNil "_classNameStr") then {
		[_file, _line, _objNameStr] call OOP_error_notObject;
		DUMP_CALLSTACK;
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
		DUMP_CALLSTACK;
		false;
	};
	//Check static member
	
	private _valid = (_memList findIf { _x#0 == _memNameStr }) != -1;
	if(!_valid) then {
		[_file, _line, _classNameStr, _memNameStr] call OOP_error_memberNotFound;
		DUMP_CALLSTACK;
	};
	//Return value
	_valid
};

//Check member and print error if it's not found or is ref
OOP_assert_member = {
	params["_objNameStr", "_memNameStr", "_file", "_line"];
	//Get object's class
	private _classNameStr = OBJECT_PARENT_CLASS_STR(_objNameStr);
	//Check if it's an object
	if(isNil "_classNameStr") exitWith {
		private _errorText = format ["class name is nil. Attempt to access member: %1.%2", _objNameStr, _memNameStr];
		[_file, _line, _errorText] call OOP_error;
		DUMP_CALLSTACK;
		false;
	};
	//Get member list of this class
	private _memList = GET_SPECIAL_MEM(_classNameStr, MEM_LIST_STR);
	//Check member
	private _memIdx = _memList findIf { _x#0 == _memNameStr };
	private _valid = _memIdx != -1;
	if(!_valid) then {
		[_file, _line, _classNameStr, _memNameStr] call OOP_error_memberNotFound;
		DUMP_CALLSTACK;
	};
	//Return value
	_valid
};

OOP_member_has_attr = {
	params["_objNameStr", "_memNameStr", "_attr"];
	// NO asserting here, it should be done already before calling this
	// Get object's class
	private _classNameStr = OBJECT_PARENT_CLASS_STR(_objNameStr);
	// Get member list of this class
	private _memList = GET_SPECIAL_MEM(_classNameStr, MEM_LIST_STR);
	// Get the member by name
	private _memIdx = _memList findIf { _x#0 == _memNameStr };
	// Return existance of attr
	private _allAttr = (_memList select _memIdx)#1;
	(_attr in _allAttr)
};

// Check member is ref and print error if it's not
OOP_assert_member_is_ref = {
	params["_objNameStr", "_memNameStr", "_file", "_line"];
	private _valid = [_objNameStr, _memNameStr, _file, _line] call OOP_assert_member;
	if(!_valid) exitWith { false };
	if(!([_objNameStr, _memNameStr, ATTR_REFCOUNTED] call OOP_member_has_attr)) exitWith {
		private _errorText = format ["%1.%2 doesn't have ATTR_REFCOUNTED attribute but is being accessed by a REF function.", _objNameStr, _memNameStr];
		[_file, _line, _errorText] call OOP_error;
		DUMP_CALLSTACK;
		false;
	};
	true;
};

// Check member is not a ref and print error if it is
OOP_assert_member_is_not_ref = {
	params["_objNameStr", "_memNameStr", "_file", "_line"];
	private _valid = [_objNameStr, _memNameStr, _file, _line] call OOP_assert_member;
	if(!_valid) exitWith { false };
	if(([_objNameStr, _memNameStr, ATTR_REFCOUNTED] call OOP_member_has_attr)) exitWith {
		private _errorText = format ["%1.%2 has ATTR_REFCOUNTED attribute but is being accessed via a non REF function.", _objNameStr, _memNameStr];
		[_file, _line, _errorText] call OOP_error;
		DUMP_CALLSTACK;
		false;
	};
	true;
};

//Check method and print error if it's not found
OOP_assert_method = {
	params["_classNameStr", "_methodNameStr", "_file", "_line"];

	if (isNil "_classNameStr") exitWith {
		private _errorText = format ["class name is nil. Attempt to call method: %1", _methodNameStr];
		[_file, _line, _errorText] call OOP_error;
		DUMP_CALLSTACK;
		false;
	};

	//Get static member list of this class
	private _methodList = GET_SPECIAL_MEM(_classNameStr, METHOD_LIST_STR);
	//Check if it's a class
	if(isNil "_methodList") exitWith {
		[_file, _line, _classNameStr] call OOP_error_notClass;
		DUMP_CALLSTACK;
		false;
	};
	//Check method
	private _valid = _methodNameStr in _methodList;
	if(!_valid) then {
		[_file, _line, _classNameStr, _methodNameStr] call OOP_error_methodNotFound;
		DUMP_CALLSTACK;
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
		_x params ["_memName", "_memAttr"];
		private _varValue = GETV(_thisObject, _memName);
		if (isNil "_varValue") then {
			diag_log format ["DEBUG: %1.%2: %3", _thisObject, _memName, "<null>"];
		} else {
			diag_log format ["DEBUG: %1.%2: %3", _thisObject, _memName, _varValue];
		};
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

// Create new object from class name and parameters
OOP_new = {
	params ["_classNameStr", "_extraParams"];

	CONSTRUCTOR_ASSERT_CLASS(_classNameStr);

	private _oop_nextID = -1;
	_oop_nul = isNil {
		_oop_nextID = GET_SPECIAL_MEM(_classNameStr, NEXT_ID_STR);
		if (isNil "_oop_nextID") then { 
			SET_SPECIAL_MEM(_classNameStr, NEXT_ID_STR, 0);	_oop_nextID = 0;
		};
		SET_SPECIAL_MEM(_classNameStr, NEXT_ID_STR, _oop_nextID+1);
	};
	
	private _objNameStr = OBJECT_NAME_STR(_classNameStr, _oop_nextID);

	FORCE_SET_MEM(_objNameStr, OOP_PARENT_STR, _classNameStr);
	private _oop_parents = GET_SPECIAL_MEM(_classNameStr, PARENTS_STR);
	private _oop_i = 0;
	private _oop_parentCount = count _oop_parents;

	while { _oop_i < _oop_parentCount } do {
		([_objNameStr] + _extraParams) call GET_METHOD((_oop_parents select _oop_i), "new");
		_oop_i = _oop_i + 1;
	};
	CALL_METHOD(_objNameStr, "new", _extraParams);
	_objNameStr
};

// Create new public object from class name and parameters
OOP_new_public = {
	params ["_classNameStr", "_extraParams"];

	CONSTRUCTOR_ASSERT_CLASS(_classNameStr);

	private _oop_nextID = -1;
	_oop_nul = isNil {
		_oop_nextID = GET_SPECIAL_MEM(_classNameStr, NEXT_ID_STR);
		if (isNil "_oop_nextID") then { 
			SET_SPECIAL_MEM(_classNameStr, NEXT_ID_STR, 0); _oop_nextID = 0;
		};
		SET_SPECIAL_MEM(_classNameStr, NEXT_ID_STR, _oop_nextID+1);
	};
	private _objNameStr = OBJECT_NAME_STR(_classNameStr, _oop_nextID);
	FORCE_SET_MEM(_objNameStr, OOP_PARENT_STR, _classNameStr);
	PUBLIC_VAR(_objNameStr, OOP_PARENT_STR);
	FORCE_SET_MEM(_objNameStr, OOP_PUBLIC_STR, 1);
	PUBLIC_VAR(_objNameStr, OOP_PUBLIC_STR);
	private _oop_parents = GET_SPECIAL_MEM(_classNameStr, PARENTS_STR);
	private _oop_i = 0;
	private _oop_parentCount = count _oop_parents;
	while {_oop_i < _oop_parentCount} do {
		([_objNameStr] + _extraParams) call GET_METHOD((_oop_parents select _oop_i), "new");
		_oop_i = _oop_i + 1;
	};
	CALL_METHOD(_objNameStr, "new", _extraParams);
	_objNameStr
};

OOP_deref_var = {
	params ["_objNameStr", "_memName", "_memAttr"];
	if(ATTR_REFCOUNTED in _memAttr) then {
		private _memObj = FORCE_GET_MEM(_objNameStr, _memName);
		switch(typeName _memObj) do {
			case "STRING": {
				CALLM0(_memObj, "unref");
			};
			// Lets not use this, it is a bit ambiguous as automatic ref counting in arrays can only
			// ever be partial, unless we make a whole suite of functions to replace all normal array 
			// mutation functions with ref safe ones. That isn't unthinkable, but not done as of yet.
			// case "ARRAY": {
			// 	{
			// 		CALLM0(_x, "unref");
			// 	} forEach _memObj;
			// };
		};
	};
};

// Delete object
OOP_delete = {
	params ["_objNameStr"];

	DESTRUCTOR_ASSERT_OBJECT(_objNameStr);

	private _oop_classNameStr = OBJECT_PARENT_CLASS_STR(_objNameStr);
	private _oop_parents = GET_SPECIAL_MEM(_oop_classNameStr, PARENTS_STR);
	private _oop_parentCount = count _oop_parents;
	private _oop_i = _oop_parentCount - 1;

	CALL_METHOD(_objNameStr, "delete", []);
	while {_oop_i > -1} do {
		[_objNameStr] call GET_METHOD((_oop_parents select _oop_i), "delete");
		_oop_i = _oop_i - 1;
	};

	private _isPublic = IS_PUBLIC(_objNameStr);
	private _oop_memList = GET_SPECIAL_MEM(_oop_classNameStr, MEM_LIST_STR);
	
	if (_isPublic) then {
		{
			// If the var is REFCOUNTED then unref it
			_x params ["_memName", "_memAttr"];
			[_objNameStr, _memName, _memAttr] call OOP_deref_var;
			FORCE_SET_MEM(_objNameStr, _memName, nil);
			PUBLIC_VAR(_objNameStr, OOP_PARENT_STR);
		} forEach _oop_memList;
	} else {
		{
			// If the var is REFCOUNTED then unref it
			_x params ["_memName", "_memAttr"];
			[_objNameStr, _memName, _memAttr] call OOP_deref_var;
			FORCE_SET_MEM(_objNameStr, _memName, nil);
		} forEach _oop_memList;
	};
};

// Base class for intrusive ref counting.
// Use the REF and UNREF macros with objects of classes 
// derived from this one.
// Use variable attributes to enable automated ref counting for object refs:
// VARIABLE_ATTR(..., [ATTR_REFCOUNTED]);
// Use the SET_VAR_REF, SETV_REF, T_SETV_REF family of functions to write to 
// these members to get automated de-refing of replaced value, and refing of
// new value. See RefCountedTest.sqf for example.
CLASS("RefCounted", "")
	VARIABLE("refCount");

	METHOD("new") {
		params [P_THISOBJECT];
		// Start at ref count zero. When the object gets assigned to a VARIABLE
		// using T_SETV_REF it will be automatically reffed.
		T_SETV("refCount", 0);
	} ENDMETHOD;

	METHOD("ref") {
		params [P_THISOBJECT];
		CRITICAL_SECTION {
			T_PRVAR(refCount);
			_refCount = _refCount + 1;
			//OOP_DEBUG_2("%1 refed to %2", _thisObject, _refCount);
			T_SETV("refCount", _refCount);
		};
	} ENDMETHOD;

	METHOD("unref") {
		params [P_THISOBJECT];
		CRITICAL_SECTION {
			T_PRVAR(refCount);
			_refCount = _refCount - 1;
			//OOP_DEBUG_2("%1 unrefed to %2", _thisObject, _refCount);
			if(_refCount == 0) then {
				//OOP_DEBUG_1("%1 being deleted", _thisObject);
				DELETE(_thisObject);
			} else {
				T_SETV("refCount", _refCount);
			};
		};
	} ENDMETHOD;
ENDCLASS;
