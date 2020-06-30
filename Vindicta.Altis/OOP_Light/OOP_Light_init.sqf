OOP_Light_initialized = true;

#include "OOP_Light.h"

#define FIX_LINE_NUMBERS2(sharp) sharp##line __LINE__ __FILE__
#define FIX_LINE_NUMBERS() FIX_LINE_NUMBERS2(#)

/*
 * This file contains some functions for OOP_Light, mainly for asserting classess, objects and members.
 * Author: Sparker
 * 02.06.2018
 * 
 * TODO: refactor the many assert functions for better performance.
*/

// Initialize the global session ID value
// Session ID is needed to avoid number overflow errors when generating unique IDs for new objects
// Session ID is incremented on every game save
#ifndef _SQF_VM
if(isNil {OOP_GVAR(sessionID)} ) then {
	OOP_GVAR(sessionID) = 0;
};
#else
if(isNil OOP_GVAR_STR(sessionID)) then {
	OOP_GVAR(sessionID) = 0;
};
#endif
FIX_LINE_NUMBERS()

if(IS_SERVER) then {
	gGameFreezeTime = 0;
	PUBLIC_VARIABLE "gGameFreezeTime";
};

// Prints an error message with supplied text, file and line number
OOP_error = {
	params["_file", "_line", "_text"];
	#ifdef _SQF_VM
	// In testing we just throw the message so we can test against it
	throw _text;
	#else
	private _msg = format ["[OOP] Error: file: %1, line: %2, %3", _file, _line, _text];
	diag_log _msg;
	DUMP_CALLSTACK;
	halt;
	#endif
	FIX_LINE_NUMBERS()
	// Doesn't really work :/
	// try
	// {
	// 	throw [_file, _line, _msg];
	// }
	// catch
	// {
	// 	terminate _thisScript;
	// 	throw _exception;
	// }
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
	private _memList = _GET_SPECIAL_MEM(_classNameStr, STATIC_MEM_LIST_STR);
	//Check if it's a class
	if(isNil "_memList") then {
		[_file, _line, _classNameStr] call OOP_error_notClass;
		false;
	} else {
		true;
	};
};

//Check object class and print error if it differs from supplied
OOP_assert_objectClass = {
	params["_objNameStr", "_expectedClassNameStr", "_file", "_line"];

	if(!(_objNameStr isEqualType "")) exitWith {
		[_file, _line, _objNameStr] call OOP_error_notObject;
		false;
	};

	//Get object's class
	private _classNameStr = OBJECT_PARENT_CLASS_STR(_objNameStr);
	//Check if it's an object
	if(isNil "_classNameStr") then {
		[_file, _line, _objNameStr] call OOP_error_notObject;
		false;
	} else {
		private _parents = _GET_SPECIAL_MEM(_classNameStr, PARENTS_STR);
		if (_expectedClassNameStr in _parents || _classNameStr == _expectedClassNameStr) then {
			true // all's fine
		} else {
			[_file, _line, _objNameStr, _classNameStr, _expectedClassNameStr] call OOP_error_wrongClass;
			false
		};
	};
};

//Check object and print error if it's not an OOP object
OOP_assert_object = {
	params["_objNameStr", "_file", "_line"];

	if(!(_objNameStr isEqualType "")) exitWith {
		[_file, _line, _objNameStr] call OOP_error_notObject;
		false;
	};

	//Get object's class
	private _classNameStr = OBJECT_PARENT_CLASS_STR(_objNameStr);
	//Check if it's an object
	if(isNil "_classNameStr") then {
		[_file, _line, _objNameStr] call OOP_error_notObject;
		false;
	} else {
		true;
	};
};

//Check static member and print error if it's not found
OOP_assert_staticMember = {
	params["_classNameStr", "_memNameStr", "_file", "_line"];
	//Get static member list of this class
	private _memList = _GET_SPECIAL_MEM(_classNameStr, STATIC_MEM_LIST_STR);
	//Check if it's a class
	if(isNil "_memList") exitWith {
		[_file, _line, _classNameStr] call OOP_error_notClass;
		false;
	};
	//Check static member
	private _valid = (_memList findIf { _x#0 == _memNameStr }) != -1;
	if(!_valid) then {
		[_file, _line, _classNameStr, _memNameStr] call OOP_error_memberNotFound;
	};
	//Return value
	_valid
};

//Check member and print error if it's not found or is ref
OOP_assert_member = {
	params["_objNameStr", "_memNameStr", "_file", "_line"];
	//Get object's class
	private _classNameStr = OBJECT_PARENT_CLASS_STR(_objNameStr);
	// Check if member name is not nil
	if (isNil "_memNameStr") exitWith {
		private _errorText = "member name is nil";
		[_file, _line, _errorText] call OOP_error;
		false;
	};
	//Check if it's an object
	if(isNil "_classNameStr") exitWith {
		private _errorText = format ["class name is nil. Attempt to access member: %1 . %2", _objNameStr, _memNameStr];
		[_file, _line, _errorText] call OOP_error;
		false;
	};
	//Get member list of this class
	private _memList = _GET_SPECIAL_MEM(_classNameStr, MEM_LIST_STR);
	//Check member
	private _memIdx = _memList findIf { _x#0 == _memNameStr };
	private _valid = _memIdx != -1;
	if(!_valid) then {
		[_file, _line, _classNameStr, _memNameStr] call OOP_error_memberNotFound;
	};
	//Return value
	_valid
};

OOP_static_member_has_attr = {
	params["_classNameStr", "_memNameStr", "_attr"];
	// NO asserting here, it should be done already before calling this
	// Get static  member list of this class
	private _memList = _GET_SPECIAL_MEM(_classNameStr, STATIC_MEM_LIST_STR);
	// Get the member by name
	private _memIdx = _memList findIf { _x#0 == _memNameStr };
	// Return existance of attr
	private _allAttr = (_memList select _memIdx)#1;
	(_attr in _allAttr)
};

OOP_member_has_attr = {
	params["_objNameStr", "_memNameStr", "_attr"];
	// NO asserting here, it should be done already before calling this
	// Get object's class
	private _classNameStr = OBJECT_PARENT_CLASS_STR(_objNameStr);
	// Get member list of this class
	private _memList = _GET_SPECIAL_MEM(_classNameStr, MEM_LIST_STR);
	// Get the member by name
	private _memIdx = _memList findIf { _x#0 == _memNameStr };
	// Return existance of attr
	private _allAttr = (_memList select _memIdx)#1;
	(_attr in _allAttr)
};

// Get an extended attribute for a static variable (one that contains values)
OOP_static_member_get_attr_ex = {
	params["_classNameStr", "_memNameStr", "_attr"];
	// NO asserting here, it should be done already before calling this
	// Get static  member list of this class
	private _memList = _GET_SPECIAL_MEM(_classNameStr, STATIC_MEM_LIST_STR);
	// Get the member by name
	private _memIdx = _memList findIf { _x#0 == _memNameStr };
	if(_memIdx == -1) then {
		diag_log format["OOP_static_member_get_attr_ex: _this = %1, _memList = %2", _this, _memList];
	};
	// Return existance of attr
	private _allAttr = (_memList select _memIdx)#1;
	private _idx = _allAttr findIf { _x isEqualType [] and {_x#0 == _attr} };
	if(_idx == NOT_FOUND) then {
		false
	} else {
		_allAttr select _idx
	}
};

// Get an extended attribute (one that contains values)
OOP_member_get_attr_ex = {
	params["_objNameStr", "_memNameStr", "_attr"];
	// NO asserting here, it should be done already before calling this
	// Get object's class
	private _classNameStr = OBJECT_PARENT_CLASS_STR(_objNameStr);
	// Get member list of this class
	private _memList = _GET_SPECIAL_MEM(_classNameStr, MEM_LIST_STR);
	// Get the member by name
	private _memIdx = _memList findIf { _x#0 == _memNameStr };
	// Return existance of attr
	private _allAttr = (_memList select _memIdx)#1;

	private _idx = _allAttr findIf { _x isEqualType [] and {_x#0 == _attr} };
	if(_idx == NOT_FOUND) then {
		false
	} else {
		_allAttr#_idx
	}
};

// Check member is ref and print error if it's not
OOP_assert_member_is_ref = {
	params["_objNameStr", "_memNameStr", "_file", "_line"];
	private _valid = [_objNameStr, _memNameStr, _file, _line] call OOP_assert_member;
	if(!_valid) exitWith { false };
	if(!([_objNameStr, _memNameStr, ATTR_REFCOUNTED] call OOP_member_has_attr)) exitWith {
		private _errorText = format ["%1 . %2 doesn't have ATTR_REFCOUNTED attribute but is being accessed by a REF function.", _objNameStr, _memNameStr];
		[_file, _line, _errorText] call OOP_error;
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
		private _errorText = format ["%1 . %2 has ATTR_REFCOUNTED attribute but is being accessed via a non REF function.", _objNameStr, _memNameStr];
		[_file, _line, _errorText] call OOP_error;
		false;
	};
	true;
};

// #define DEBUG_OOP_ASSERT_FUNCS

OOP_are_in_same_class_heirarchy = {
	params ["_classNameStr"];
	// If we aren't in a class member function at all
	if(isNil "_thisClass") exitWith { false	};
	// If we are in the same class
	if(_thisClass isEqualTo _classNameStr) exitWith { true };
	// If we are in a descendant class
	_classNameStr in _GET_SPECIAL_MEM(_thisClass, PARENTS_STR)
};

OOP_assert_class_member_access = {
	params ["_classNameStr", "_memNameStr", "_isGet", "_isPrivate", "_isGetOnly", "_file", "_line"];

	#ifdef DEBUG_OOP_ASSERT_FUNCS
	diag_log format ["_classNameStr = %1, _memNameStr = %2, _isGet = %3, _isPrivate = %4, _isGetOnly = %5, _thisClass = %6", 
		_classNameStr, _memNameStr, _isGet, _isPrivate, _isGetOnly,
		if(!isNil "_thisClass") then { _thisClass } else { nil }
	];
	#endif
	FIX_LINE_NUMBERS()
	// If it isn't private or get only then we are fine
	if(!_isPrivate and !_isGetOnly) exitWith { 
		#ifdef DEBUG_OOP_ASSERT_FUNCS
		diag_log "OK: !_isPrivate";
		#endif
		FIX_LINE_NUMBERS()
		true 
	};
	// If it is both private and get-only then it is a declaration error, these are mutually exclusive
	if(_isPrivate and _isGetOnly) exitWith {
		private _errorText = format ["%1 . %2 is marked private AND get-only, but they are intended to be mutually exclusive (get-only implies private set and public get)", _classNameStr, _memNameStr];
		[_file, _line, _errorText] call OOP_error;
		false
	};

	// Private and get only rules:
	// Private is violated if access is outside of the class heirarchy that owns the variable regardless always
	// Get-only is violated if set access is outside of the class heirarchy always

	private _inSameHeirarchy = [_classNameStr] call OOP_are_in_same_class_heirarchy;
	// If we are in the same class heirarchy then private and get-only are fine
	if(_inSameHeirarchy) exitWith { true };
	// At this point we know we are accessing from outside the class heirarchy
	// Check we aren't attempting to set a get-only variable
	if(!_isGet and _isGetOnly) exitWith {
		private _errorText = format ["%1 . %2 is get-only outside of its own class heirarchy", _classNameStr, _memNameStr];
		[_file, _line, _errorText] call OOP_error;
		false
	};
	// If the variable isn't private then we are fine.
	if(!_isPrivate) exitWith { true };

	// // If it is not private, and is get only and we aren't 

	// // If the class we access from is the same as the one that owns the member then we are fine regardless
	// if(!isNil "_thisClass" and {_thisClass isEqualTo _classNameStr}) exitWith { 
	// 	#ifdef DEBUG_OOP_ASSERT_FUNCS
	// 	diag_log "OK: _thisClass isEqualTo _classNameStr";
	// 	#endif
	// 	true
	// };

	// // If we aren't in a class function at all then private would by violated.
	// if(_isPrivate and {isNil "_thisClass"}) exitWith {
	// 	private _errorText = format ["%1 . %2 is unreachable (private)", _classNameStr, _memNameStr];
	// 	[_file, _line, _errorText] call OOP_error;
	// 	false
	// };

	// // Check if the object we are accessing is a parent of the class we are in (this is fine)
	// // We could also allow access of members in derived classes but this is likely a design flaw anyway.
	// // This code would allow it:
	// // 	or {_thisClass in _GET_SPECIAL_MEM(_classNameStr, PARENTS_STR)}
	// if(_classNameStr in _GET_SPECIAL_MEM(_thisClass, PARENTS_STR)) exitWith {
	// 	#ifdef DEBUG_OOP_ASSERT_FUNCS
	// 	diag_log "OK: _classNameStr in _GET_SPECIAL_MEM(_thisClass, PARENTS_STR)";
	// 	#endif
	// 	true 
	// };
	private _errorText = format ["%1 . %2 is unreachable (private)", _classNameStr, _memNameStr];
	[_file, _line, _errorText] call OOP_error;
	false
};

OOP_assert_is_in_required_thread = {
	params ["_objOrClass", "_classNameStr", "_memNameStr", "_threadAffinityFn", "_file", "_line"];
	private _requiredThread = [_objOrClass] call _threadAffinityFn;
	if(!isNil "_thisScript" and !isNil "_requiredThread" and  {!(_requiredThread isEqualTo _thisScript)}) exitWith {
		private _errorText = format ["%1 . %2 is accessed from the wrong thread, expected '%3' got '%4'", _classNameStr, _memNameStr, _requiredThread, _thisScript];
		[_file, _line, _errorText] call OOP_error;
		false
	};
	true
};

OOP_assert_static_member_access = {
	params ["_classNameStr", "_memNameStr", "_isGet", "_file", "_line"];
	
#ifndef _SQF_VM
	private _threadAffinity = [_classNameStr, _memNameStr, ATTR_THREAD_AFFINITY_ID] call OOP_static_member_get_attr_ex;
	if((_threadAffinity isEqualType []) and {!([_classNameStr, _classNameStr, _memNameStr, _threadAffinity#1, _file, _line] call OOP_assert_is_in_required_thread)}) exitWith {
		false
	};
#endif
FIX_LINE_NUMBERS()
	private _isPrivate = [_classNameStr, _memNameStr, ATTR_PRIVATE] call OOP_static_member_has_attr;
	private _isGetOnly = [_classNameStr, _memNameStr, ATTR_GET_ONLY] call OOP_static_member_has_attr;
	[_classNameStr, _memNameStr, _isGet, _isPrivate, _isGetOnly, _file, _line] call OOP_assert_class_member_access;
};

OOP_assert_get_static_member_access = { 
	params ["_classNameStr", "_memNameStr", "_file", "_line"];
	[_classNameStr, _memNameStr, true, _file, _line] call OOP_assert_static_member_access;
};
OOP_assert_set_static_member_access = { 
	params ["_classNameStr", "_memNameStr", "_file", "_line"];
	
	//private _isGetOnly = [_classNameStr, _memNameStr, ATTR_GET_ONLY] call OOP_static_member_has_attr;
	//if(_isGetOnly) exitWith { false };
	[_classNameStr, _memNameStr, false, _file, _line] call OOP_assert_static_member_access;
};

OOP_assert_member_access = {
	params ["_objNameStr", "_memNameStr", "_isGet", "_file", "_line"];

	#ifdef DEBUG_OOP_ASSERT_FUNCS
	diag_log format ["OOP_assert_member_access: _objNameStr = %1, _memNameStr = %2, _isGet = %3, _thisObject = %4, _thisClass = %5", 
		_objNameStr, _memNameStr, _isGet,
		if(!isNil "_thisObject") then { _thisObject } else { nil },
		if(!isNil "_thisClass") then { _thisClass } else { nil }
	];
	#endif
	FIX_LINE_NUMBERS()

	// EARLY OUT: If we are accessing from within the same object we have no access restrictions
	if (!isNil "_thisObject" and {_thisObject isEqualTo _objNameStr}) exitWith { true };

	private _isPrivate = [_objNameStr, _memNameStr, ATTR_PRIVATE] call OOP_member_has_attr;
	private _isGetOnly = [_objNameStr, _memNameStr, ATTR_GET_ONLY] call OOP_member_has_attr;

	// Get the class of the object that owns the member
	private _classNameStr = OBJECT_PARENT_CLASS_STR(_objNameStr);
	#ifndef _SQF_VM
	private _threadAffinity = [_objNameStr, _memNameStr, ATTR_THREAD_AFFINITY_ID] call OOP_member_get_attr_ex;
	if((_threadAffinity isEqualType []) and {!([_objNameStr, _classNameStr, _memNameStr, _threadAffinity#1, _file, _line] call OOP_assert_is_in_required_thread)}) exitWith {
		false
	};
	#endif
	FIX_LINE_NUMBERS()
	private _thisClass = if(!isNil "_thisClass") then { 
			_thisClass
		} else {
			if (!isNil "_thisObject") then { 
				OBJECT_PARENT_CLASS_STR(_thisObject) 
			} else {
				nil
			}
		};
	[_classNameStr, _memNameStr, _isGet, _isPrivate, _isGetOnly, _file, _line] call OOP_assert_class_member_access;
};

OOP_assert_get_member_access = {
	params ["_objNameStr", "_memNameStr", "_file", "_line"];
	[_objNameStr, _memNameStr, true, _file, _line] call OOP_assert_member_access;
};
OOP_assert_set_member_access = { 
	params ["_objNameStr", "_memNameStr", "_file", "_line"];
	[_objNameStr, _memNameStr, false, _file, _line] call OOP_assert_member_access;
};

#define SPECIAL_METHODS ["new", "delete", "copy", "assign", "ref", "unref"]
OOP_assert_method_call = {
	params ["_class", "_method", "_obj", "_file", "_line"];

	// Find the attributes for the method in the most base class
	// TODO: optimize this by copying declared class and attributes for functions into derived classes
	private _classes = _GET_SPECIAL_MEM(_class, PARENTS_STR) + [_class];
	private _idx = _classes findIf { _method in _GET_SPECIAL_MEM(_x, OWN_METHOD_LIST_STR) };
	private _methodClass = _classes#_idx;
	private _attribs = missionNamespace getVariable [CLASS_METHOD_ATTR_STR(_methodClass, _method), []];
	private _scopeClasses = if(isNil "__classScope") then { [] } else { _GET_SPECIAL_MEM(__classScope, PARENTS_STR) + [__classScope] };

	// Ignore special methods
	if(_method in SPECIAL_METHODS) exitWith {};

	// // Get relative file path. I thought it would fix vscode terminal links with spaces in them, but it doesn't...
	// private _idx = _file find "Vindicta.Altis";
	// _file = _file select [_idx + count "Vindicta.Altis"];
	// _file = "." + _file;

	// assert thread
	if(attr(thread) in _attribs && {isNil ("__ignoreThreadAffinity" + _class)}) then {
		private _properThread = isNil "_thisScript" || {GETV(CALLM0(_obj, "getMessageLoop"), "scriptHandle") isEqualTo _thisScript} || {!canSuspend};
		if(!_properThread) then {
			OOP_ERROR_4("%1 . %2 is called in wrong thread (%3:%4)", _class, _method, _file, _line);
		};
	};

	// assert access
	if(attr(protected) in _attribs && {!(_methodClass in _scopeClasses)} && {isNil ("__ignoreAccess" + _methodClass)}) exitWith {
		OOP_ERROR_4("%1 . %2 is protected, and can only be called from its own class, or inherited classes (%3:%4)", _methodClass, _method, _file, _line);
		//diag_log [_this, _classes, _methodClass, _attribs, __classScope];
	};

	// We ignore access for MessageReceiver, we need to check it in the postMethod functions instead as they know about the calling scope
	if(!(attr(public) in _attribs || attr(protected) in _attribs) && {isNil "__classScope" || {!(_methodClass isEqualTo __classScope) && !(__classScope in ["MessageReceiver", "MessageReceiverEx"])}} && {isNil ("__ignoreAccess" + _methodClass)}) exitWith {
		OOP_ERROR_4("%1 . %2 is private, and can only be called from its own class (%3:%4)", _methodClass, _method, _file, _line);
		//diag_log [_this, _classes, _methodClass, _attribs, __classScope];
	};

	// assert server / client
	if(attr(server) in _attribs && !IS_SERVER) exitWith {
		OOP_ERROR_4("%1 . %2 can only be called on the server (%3:%4)", _methodClass, _method, _file, _line);
	};
	if(attr(client) in _attribs && !HAS_INTERFACE) exitWith {
		OOP_ERROR_4("%1 . %2 can only be called on the client (%3:%4)", _methodClass, _method, _file, _line);
	};
};

//Check method and print error if it's not found
OOP_assert_method = {
	params["_class", "_method", "_obj", "_file", "_line"];

	if (isNil "_method") exitWith {
		private _errorText = "method name is nil";
		[_file, _line, _errorText] call OOP_error;
		false;
	};

	if (isNil "_class") exitWith {
		private _errorText = format ["class name is nil. Attempt to call method: %1", _method];
		[_file, _line, _errorText] call OOP_error;
		false;
	};

	//Get static member list of this class
	private _methodList = _GET_SPECIAL_MEM(_class, METHOD_LIST_STR);
	// Check if it's a class
	if(isNil "_methodList") exitWith {
		[_file, _line, _class] call OOP_error_notClass;
		false;
	};

	//Check method
	private _valid = _method in _methodList;
	if(!_valid) then {
		[_file, _line, _class, _method] call OOP_error_methodNotFound;
	};

	#ifdef OOP_ASSERT_METHOD_CALL
	[_class, _method, _obj, _file, _line] call OOP_assert_method_call;
	#endif

	//Return value
	_valid
};

OOP_set_method_attr = {
	params ["_class", "_method", "_attribs", ["_static", false]];
	missionNamespace setVariable [CLASS_METHOD_ATTR_STR(_class, _method), +_attribs];

	if(_method in SPECIAL_METHODS) exitWith {
		if(count _attribs != 0) then {
			OOP_ERROR_3("%1 . %2 must not use any attributes (using %3)", _class, _method, _attribs);
		};
	};

	// Check for duplicate attributes
	private _attribsUnique = [];
	{ _attribsUnique pushBackUnique _x } forEach _attribs;
	if(count _attribsUnique != count _attribs) exitWith {
		OOP_ERROR_2("%1 . %2 declares some attributes more than once", _class, _method);
	};

	// Method already defined in this class
	if (_method in _oop_newMethodList) exitWith {
		OOP_ERROR_2("%1 . %2 declared more than once", _class, _method);
	};

	// Accessibility
	private _public = attr(public) in _attribs;
	private _protected = attr(protected) in _attribs;
	if (_public && _protected) exitWith {
		OOP_ERROR_2("%1 . %2 declared as 'public' and 'protected': use one only, or neither if you want to declare a method as private", _class, _method);
	};
	if(_public && {_attribs#0 != attr(public)}) exitWith {
		OOP_ERROR_2("%1 . %2 'public' must be first method attribute", _class, _method);
	};
	if(_protected && {_attribs#0 != attr(protected)}) exitWith {
		OOP_ERROR_2("%1 . %2 'protected' must be first method attribute", _class, _method);
	};

	_attribs = _attribs - [attr(public), attr(protected)];

	// virtual / override
	private _virtual = attr(virtual) in _attribs;
	private _override = attr(override) in _attribs;
	if (_static && (_virtual || _override)) then {
		OOP_ERROR_2("%1 . %2 declared as 'virtual' or 'override': static functions cannot be either", _class, _method);
	};
	if (_virtual && _override) then {
		OOP_ERROR_2("%1 . %2 declared as 'virtual' and 'override': use one only, or neither", _class, _method);
	};
	if(_virtual && {_attribs#0 != attr(virtual)}) exitWith {
		OOP_ERROR_2("%1 . %2 'virtual' must be specified after 'public'/'protected' but before 'server'/'client'", _class, _method);
	};
	if(_override && {_attribs#0 != attr(override)}) exitWith {
		OOP_ERROR_2("%1 . %2 'override' must be specified after 'public'/'protected' but before 'server'/'client'", _class, _method);
	};
	if (_virtual && !(_public || _protected)) then {
		OOP_ERROR_2("%1 . %2 declared as 'virtual' but not 'public' or 'protected': this makes no sense, a virtual method must be visible to derived classes for them to override it", _class, _method);
	};

	private _exists = _method in _oop_methodList;
	if(!_exists && _override) exitWith {
		OOP_ERROR_2("%1 . %2 specifies 'override' but no base class contains a method with the same name", _class, _method);
	};

	if(_exists && !_static) then {
		// Parents are ordered from least derived to most, so first one found will be first parent that defined the function.
		// (Hopefully the same function isn't defined in multiple parents...)
		private _oop_parents = _GET_SPECIAL_MEM(_class, PARENTS_STR);
		private _idx = _oop_parents findIf { _method in _GET_SPECIAL_MEM(_x, OWN_METHOD_LIST_STR) };
		private _parent = _oop_parents#_idx;
		// Must use override keyword if the method already exists
		if !(_override) then {
			OOP_ERROR_3("%1 . %2 is hiding definition in %3: use 'virtual' and 'override' attributes to declare virtual methods", _class, _method, _parent);
		} else {
			private _otherAttribs = missionNamespace getVariable [CLASS_METHOD_ATTR_STR(_parent, _method), []];
			if !(attr(virtual) in _otherAttribs) exitWith {
				OOP_ERROR_3("%1 . %2 is overriding non-virtual method in %3: use 'virtual' and 'override' attributes to declare virtual methods", _class, _method, _parent);
			};
			private _otherPublic = attr(public) in _otherAttribs;
			private _otherProtected = attr(protected) in _otherAttribs;
			if(!_otherPublic && !_otherProtected) exitWith {
				OOP_ERROR_3("%1 . %2 is overriding %3.%2 which does not have appropriate access attributes ('public', 'protected')", _parent, _method, _parent);
			};
			if (_public && !_otherPublic || _protected && !_otherProtected) exitWith {
				OOP_ERROR_3("%1 . %2 overriding %3.%2 with different access attributes: overriding methods must have the same access", _class, _method, _parent);
			};
		};
	};
	_attribs = _attribs - [attr(virtual), attr(override)];

	// Environment
	private _server = attr(server) in _attribs;
	private _client = attr(client) in _attribs;
	if (_server && _client) then {
		OOP_ERROR_2("%1 . %2 declared as 'server' and 'client': use neither if you want to declare a method as callable on both server and client", _class, _method);
	};
	if(_server && {_attribs#0 != attr(server)}) then {
		OOP_ERROR_2("%1 . %2 'server' must be specified after 'virtual'/'override' but before 'thread'", _class, _method);
	};
	if(_client && {_attribs#0 != attr(client)}) then {
		OOP_ERROR_2("%1 . %2 'client' must be specified after 'virtual'/'override' but before 'thread'", _class, _method);
	};
	_attribs = _attribs - [attr(server), attr(client)];

	// Thread affinity
	private _thread = attr(thread) in _attribs;
	if(_thread && _static) exitWith {
		OOP_ERROR_2("%1 . %2 is static and declared as 'thread': static methods cannot use 'thread' affinity attribute", _class, _method);
	};
	if(_thread && {_attribs#0 != attr(thread)}) exitWith {
		OOP_ERROR_2("%1 . %2 'thread' must be last method attribute", _class, _method);
	};
};


// Dumps all variables of an object
OOP_dumpAllVariables = {
	params [P_THISOBJECT];
	// Get object's class
	private _class = OBJECT_PARENT_CLASS_STR(_thisObject);
	//Get member list of this class
	private _memList = _GET_SPECIAL_MEM(_class, MEM_LIST_STR);
	diag_log format ["[OOP]: Basic variable dump of %1: %2", _thisObject, _memList];
	{
		_x params ["_memName", "_memAttr"];
		private _varValue = T_GETV(_memName);
		if (isNil "_varValue") then {
			diag_log format ["  %1 . %2: %3", _thisObject, _memName, "<nil> (isNil = true)"];
		} else {
			diag_log format ["  %1 . %2: %3", _thisObject, _memName, _varValue];
		};
	} forEach _memList;
};

// Dumps all variables recursively
// It inspects arrays
// It inspects variables which are refs to objects
OOP_dumpAllVariablesRecursive = {
	params [P_THISOBJECT, ["_maxDepth", 100], P_NUMBER("_indentNum"), ["_objsDumpedAlready", []]];

	//diag_log format ["---- dumpAllVariablesRecursive: %1", _this];

	// First of all, make sure we don't dump ourselves
	_objsDumpedAlready pushBack _thisObject;

	// String with indentations
	private _strIndent = format ["L-%1 ", (str _indentNum)];
	if (_indentNum > 0) then {
		for "_i" from 0 to (_indentNum-1) do {
			_strIndent = _strIndent + "|  ";
		};
	};

	// Bail if we've went too deep
	if (_indentNum > _maxDepth) exitWith {
		//diag_log (_strIndent + (format ["[OOP]: Recursive variable dump of %1 ignored, max depth reached", _thisObject]));
	};

	// Get object's class
	private _classNameStr = OBJECT_PARENT_CLASS_STR(_thisObject);

	//Get member list of this class
	private _memList = _GET_SPECIAL_MEM(_classNameStr, MEM_LIST_STR);

	diag_log (_strIndent + (format ["[OOP]: Recursive variable dump of %1: %2", _thisObject, _memList]));
	{
		_x params ["_memName", "_memAttr"];
		private _varValue = T_GETV(_memName);
		[_thisObject, _memName, _varValue, _indentNum, _objsDumpedAlready, -1, _maxDepth] call OOP_dumpObjectVariable;
	} forEach _memList;
};

// Used for recursive variable dump
OOP_dumpObjectVariable = {
	params [P_THISOBJECT, "_memName", "_varValue", "_indentNum", "_objsDumpedAlready", "_elementID", "_maxDepth"];
	private _strIndent = format ["L-%1 ", (str _indentNum)];
	if (_indentNum > 0) then {
		for "_i" from 0 to (_indentNum-1) do {
			_strIndent = _strIndent + "|  ";
		};
	};
	// Header of the line, printed after indents
	private _header = if (_elementID != -1) then {
		format ["element %1", _elementID];
	} else {
		_memName;
	};

	if (isNil "_varValue") then {
		diag_log (_strIndent + format ["%1: %2", _header, "<nil> (isNil = true)"]);
	} else {
		// Resolve specific type
		private _typeName = typeName _varValue;
		switch (_typeName) do {
			case "STRING": {
				if(IS_OOP_OBJECT(_varValue)) then {
					if (toLower _varValue in _objsDumpedAlready) then {
						diag_log (_strIndent + format ["%1: (OOP Object): %2 (dumped already)", _header, _varValue]);
					} else {
						if (_indentNum + 1 > _maxDepth) then {
						 	// We've gone too far, man.... time to stop
							diag_log (_strIndent + format ["%1: (OOP Object): %2 (ignored, max depth reached)", _header, _varValue]);
						} else {
							diag_log (_strIndent + format ["%1: (OOP Object): %2", _header, _varValue]);
							_objsDumpedAlready pushBack (toLower _varValue);
							[_varValue, _maxDepth, _indentNum + 1, _objsDumpedAlready] call OOP_dumpAllVariablesRecursive;
						};
					};
				} else {
					diag_log (_strIndent + format ["%1: (%2) %3", _header, _typeName, _varValue]);
				};
			};
			case "ARRAY": {
				diag_log (_strIndent + format ["%1: array of %2 elements:", _header, count _varValue]);
				{
					[_thisObject, _header, _x, _indentNum + 1, _objsDumpedAlready, _forEachIndex, _maxDepth] call OOP_dumpObjectVariable;
				} forEach _varValue;
			};
			default {
				diag_log (_strIndent + format ["%1: (%2) %3", _header, _typeName, _varValue]);
			};
		};
	};
};

#ifdef OFSTREAM_ENABLE
// Dump to ofstream

gCommaNewLine = "," + toString [10];
#define COMMA_NL gCommaNewLine

#define CLEAR() (ofstream_clear "dumped.json")
#define DUMP(string) ("dumped.json" ofstream_dump (string))
#define DUMP_STR(string) ("dumped.json" ofstream_dump (("""" + (((((string) splitString "\") joinString "\\") splitString '"') joinString '\"')) + """"))

#else
// Dump to diag_log

gCommaNewLine = ",";
#define COMMA_NL gCommaNewLine

#define CLEAR() 
#define DUMP(string) (diag_log ("_json_line_ " + string))
#define DUMP_STR(string) (diag_log ("_json_line_ " + (("""" + (((((string) splitString "\") joinString "\\") splitString '"') joinString '\"')) + """")))

#endif
FIX_LINE_NUMBERS()

// Serializes a variable to json
OOP_dumpVariableToJson = {
	params [P_DYNAMIC("_value"), P_BOOL("_recursive"), P_NUMBER("_depth"), P_ARRAY("_objectsDumped")];
	
	switch (typeName _value) do {
		case "STRING": {
			if(IS_OOP_OBJECT(_value)) then {
				// Check if we have dumped it already
				if ((tolower _value) in _objectsDumped) then {
					// We have dumped it already
					DUMP_STR(_value);
				} else {
					_objectsDumped pushBack (tolower _value); // Add ref to array so that we don't dump it again
					[_value, _recursive, _depth + 1, _objectsDumped] call OOP_objectToJson;
				};
			} else {
				DUMP_STR(_value);
			};
		};
		case "ARRAY": {
			DUMP("[");
			{ 
				if(_forEachIndex != 0) then { DUMP(COMMA_NL) };
				[_x, _recursive, _depth] call OOP_dumpVariableToJson;
			} forEach _value;
			DUMP("]");
		};
		case "SCALAR";
		case "BOOL": { DUMP(str _value) };
		// Other types we convert to a string (we need to do it twice because we want to wrap it in quotes, not just make it an sqf string)
		default { DUMP_STR(str _value) };
	};
};

// Serializes all variables of an object to json
OOP_objectToJson = {
	params [P_THISOBJECT, P_BOOL("_recursive"), P_NUMBER("_depth"), P_ARRAY("_objectsDumped")];

	// Add ourselves to the array of dumped objects
	_objectsDumped pushBack (tolower _thisObject);

	if(_depth > 3) exitWith { DUMP(str "!recursion limit reached!") };

	// Get object's class
	private _classNameStr = OBJECT_PARENT_CLASS_STR(_thisObject);
	//Get member list of this class
	private _memList = _GET_SPECIAL_MEM(_classNameStr, MEM_LIST_STR);
	
	DUMP("{");

	// Dump self reference
	private _str = format ['"_id": "%1"', _thisObject];
	DUMP(_str);

	// Iterate all object members/variables
	{
		_x params ["_memName", "_memAttr"];
		
		DUMP(COMMA_NL);

		private _varValue = T_GETV(_memName);
		if (isNil "_varValue") then {
			private _str = format['"%1": "<nil>"', _memName];
			DUMP(_str);
		} else {
			private _str = format['"%1":', _memName];
			DUMP(_str);
			[_varValue, _recursive, _depth, _objectsDumped] call OOP_dumpVariableToJson;
			// _json = _json + format ['"%1": %2', _memName, _valJson];
		};
	} forEach _memList;

	DUMP("}");
};

// Dumps a variable to diag_log as json
OOP_dumpAsJson = {
	diag_log "DEBUG: Dumping variable as json";
	CLEAR();
	[_this] call OOP_dumpVariableToJson;
	DUMP(endl + endl + endl);
};

// Dumps to JSON, but always to diag_log

#ifdef _SQF_VM
#define __TEXT
#else
#define __TEXT text
#endif
FIX_LINE_NUMBERS()

gComma = toString [44];
#define CLEAR() 
#define DUMP_DIAGLOG(string) (diag_log __TEXT ("_json_line_ " + string))
#define DUMP_STR_DIAGLOG(string) (diag_log __TEXT ("_json_line_ " + (("""" + (((((string select [0, 1024]) splitString "\") joinString "\\") splitString '"') joinString '\"')) + """")))

// Serializes a variable to json
OOP_dumpVariableToJson_diagLog = {
	params [P_DYNAMIC("_value"), P_NUMBER("_depth"), P_NUMBER("_maxDepth"), P_ARRAY("_objectsDumped")];
	
	switch (typeName _value) do {
		case "STRING": {
			if(IS_OOP_OBJECT(_value)) then {
				// Check if we have dumped it already
				if (((tolower _value) in _objectsDumped) || (_depth > (_maxDepth-1))) then {
					// We have dumped it already
					DUMP_STR_DIAGLOG(_value);
				} else {
					_objectsDumped pushBack (tolower _value); // Add ref to array so that we don't dump it again
					[_value, _depth + 1, _maxDepth, _objectsDumped] call OOP_objectToJson_diagLog;
				};
			} else {
				DUMP_STR_DIAGLOG(_value);
			};
		};
		case "ARRAY": {
			DUMP_DIAGLOG("[");
			{ 
				if(_forEachIndex != 0) then { DUMP_DIAGLOG(gComma) };
				[_x, _depth, _maxDepth, _objectsDumped] call OOP_dumpVariableToJson_diagLog;
			} forEach _value;
			DUMP_DIAGLOG("]");
		};
		case "SCALAR";
		case "BOOL": { DUMP_DIAGLOG(str _value) };
		// Other types we convert to a string (we need to do it twice because we want to wrap it in quotes, not just make it an sqf string)
		default { DUMP_STR_DIAGLOG(str _value) };
	};
};

// Serializes all variables of an object to json
OOP_objectToJson_diagLog = {
	params [P_THISOBJECT, P_NUMBER("_depth"), P_NUMBER("_maxDepth"), P_ARRAY("_objectsDumped")];

	// Add ourselves to the array of dumped objects
	_objectsDumped pushBack (tolower _thisObject);

	// Get object's class
	private _classNameStr = OBJECT_PARENT_CLASS_STR(_thisObject);
	//Get member list of this class
	private _memList = _GET_SPECIAL_MEM(_classNameStr, MEM_LIST_STR);
	
	DUMP_DIAGLOG("{");

	// Dump self reference
	private _str = format ['"_id": "%1"', _thisObject];
	DUMP_DIAGLOG(_str);

	// Iterate all object members/variables
	{
		_x params ["_memName", "_memAttr"];
		
		DUMP_DIAGLOG(gComma);

		private _varValue = T_GETV(_memName);
		if (isNil "_varValue") then {
			private _str = format['"%1": "<nil>"', _memName];
			DUMP_DIAGLOG(_str);
		} else {
			private _str = format['"%1":', _memName];
			DUMP_DIAGLOG(_str);
			[_varValue, _depth, _maxDepth, _objectsDumped] call OOP_dumpVariableToJson_diagLog;
			// _json = _json + format ['"%1": %2', _memName, _valJson];
		};
	} forEach _memList;

	DUMP_DIAGLOG("}");
};

// Does a proper object crash dump, which we can later analyze with our tool
OOP_objectCrashDump = {
	params [P_THISOBJECT, P_NUMBER("_madDepth")];

	// Critical section, we don't want to mix these diag_logs with others from other threads
	_nul = isNil {
		diag_log format ["[OOP] Starting object crash dump of: %1", _thisObject];

		// Check if it's even an object
		if (IS_OOP_OBJECT(_thisObject)) then {
			// Mark JSON start
			diag_log "_json_line_ _json_start_";

			// Wrap into array
			diag_log "_json_line_ [";

			// Perform the actual json object dump
			[_thisObject, 0, _madDepth] call OOP_objectToJson_diagLog; // Note the max depth

			// Wrap into array
			diag_log "_json_line_ ]";

			// Mark JSON end
			diag_log "_json_line_ _json_end_";
		} else {
			diag_log format ["[OOP] Error: %1 is not an object", _thisObject];
		};
	};
};

// ---- Remote execution ----
// A remote code wants to execute something on this machine
// However remote machine doesn't have to know what class the object belongs to
// So we must find out object's class on this machine and then run the method
OOP_callFromRemote = {
	params[P_OOP_OBJECT("_object"), P_STRING("_methodNameStr"), ["_params", [], [[]]]];
	//diag_log format [" --- OOP_callFromRemote: %1", _this];
	if (IS_OOP_OBJECT(_object)) then {
		CALLM(_object, _methodNameStr, _params);
	} else {
		diag_log format ["[OOP] Error: callFromRemote: object ref is invalid: %1, method: %2, parameters: %3", _object, _methodNameStr, _params];
	};
};

// If assertion is enabled, this gets called on remote machine when we call a static method on it
// So it will run the standard assertions before calling static method
OOP_callStaticMethodFromRemote = {
	params [P_STRING("_classNameStr"), P_STRING("_methodNameStr"), ["_args", [], [[]]]];
	CALLSM(_classNameStr, _methodNameStr, _args);
};

OOP_init_class = {
	params [["_oop_classNameStr", "", [""]], ["_baseClassNames", "", ["", []]]];
	_SET_SPECIAL_MEM(_oop_classNameStr, NEXT_ID_STR, OOP_ID_COUNTER_NEW);
	private _oop_memList = [];
	private _oop_staticMemList = [];
	private _oop_methodList = [];
	// Parents can be specified as a string or an array of strings
	private _parentClassNames = switch true do {
		case (_baseClassNames isEqualTo ""): { [] };
		case (_baseClassNames isEqualType ""): { [_baseClassNames] };
		default { _baseClassNames };
	};
	private _oop_parents = [];
	{
		private _baseClassNameStr = _x;
		if (!([_baseClassNameStr, __FILE__, __LINE__] call OOP_assert_class)) then {
			private _msg = format ["Invalid base class for %1: %2", classNameStr, baseClassNameStr];
			FAILURE(_msg);
		};
		{ _oop_parents pushBackUnique _x; } forEach _GET_SPECIAL_MEM(_baseClassNameStr, PARENTS_STR);
		_oop_parents pushBackUnique _baseClassNameStr;
		{ _oop_memList pushBackUnique _x; } forEach _GET_SPECIAL_MEM(_baseClassNameStr, MEM_LIST_STR);
		{ _oop_staticMemList pushBackUnique _x; } forEach _GET_SPECIAL_MEM(_baseClassNameStr, STATIC_MEM_LIST_STR);
		private _oop_addedMethodList = [];
		{ _oop_methodList pushBackUnique _x; _oop_addedMethodList pushBackUnique _x; } forEach _GET_SPECIAL_MEM(_baseClassNameStr, METHOD_LIST_STR);
		private _oop_topParent = _oop_parents select ((count _oop_parents) - 1);
		{
			private _oop_methodCode = _GET_METHOD(_oop_topParent, _x);
			_SET_METHOD(_oop_classNameStr, _x, _oop_methodCode);
			_oop_methodCode = _GET_METHOD(_oop_topParent, INNER_METHOD_NAME_STR(_x));
			if (!isNil "_oop_methodCode") then { _SET_METHOD(_oop_classNameStr, INNER_METHOD_NAME_STR(_x), _oop_methodCode); };
		} forEach (_oop_addedMethodList - ["new", "delete", "copy"]);
	} forEach _parentClassNames;
	_SET_SPECIAL_MEM(_oop_classNameStr, PARENTS_STR, _oop_parents);
	_SET_SPECIAL_MEM(_oop_classNameStr, MEM_LIST_STR, _oop_memList);
	_SET_SPECIAL_MEM(_oop_classNameStr, STATIC_MEM_LIST_STR, _oop_staticMemList);
	_SET_SPECIAL_MEM(_oop_classNameStr, METHOD_LIST_STR, _oop_methodList);
	_SET_SPECIAL_MEM(_oop_classNameStr, NAMESPACE_STR, NAMESPACE);
	// Methods introduced only in this class, not inherited
	private _oop_newMethodList = [];
	_SET_SPECIAL_MEM(_oop_classNameStr, OWN_METHOD_LIST_STR, _oop_newMethodList);
	return [_oop_memList, _oop_staticMemList, _oop_methodList, _oop_newMethodList];
};

// Create new object from class name and parameters
OOP_new = {
	params ["_classNameStr", "_extraParams"];

	CONSTRUCTOR_ASSERT_CLASS(_classNameStr);

	private _oop_nextID = -1;
	_oop_nul = isNil {
		_oop_nextID = _GET_SPECIAL_MEM(_classNameStr, NEXT_ID_STR);
		if (isNil "_oop_nextID") then { 
			_SET_SPECIAL_MEM(_classNameStr, NEXT_ID_STR, OOP_ID_COUNTER_NEW);	_oop_nextID = OOP_ID_COUNTER_NEW;
		};
		_oop_nextID = OOP_ID_COUNTER_PLUS_ONE(_oop_nextID);
		_SET_SPECIAL_MEM(_classNameStr, NEXT_ID_STR, _oop_nextID);
	};
	
	private _objNameStr = OBJECT_NAME_STR(_classNameStr, _oop_nextID);

	_SETV(_objNameStr, OOP_PARENT_STR, _classNameStr);
	private _oop_parents = _GET_SPECIAL_MEM(_classNameStr, PARENTS_STR);
	private _oop_i = 0;
	private _oop_parentCount = count _oop_parents;
	while { _oop_i < _oop_parentCount } do {
		([_objNameStr] + _extraParams) call GET_METHOD(_oop_parents#_oop_i, "new");
		_oop_i = _oop_i + 1;
	};
	CALLM(_objNameStr, "new", _extraParams);

	PROFILER_COUNTER_INC(_classNameStr);

	_objNameStr
};

// Create new public object from class name and parameters
OOP_new_public = { // todo implement namespace
	params ["_classNameStr", "_extraParams"];

	CONSTRUCTOR_ASSERT_CLASS(_classNameStr);

	private _oop_nextID = -1;
	_oop_nul = isNil {
		_oop_nextID = _GET_SPECIAL_MEM(_classNameStr, NEXT_ID_STR);
		if (isNil "_oop_nextID") then { 
			_SET_SPECIAL_MEM(_classNameStr, NEXT_ID_STR, OOP_ID_COUNTER_NEW); _oop_nextID = OOP_ID_COUNTER_NEW;
		};
		_oop_nextID = OOP_ID_COUNTER_PLUS_ONE(_oop_nextID);
		_SET_SPECIAL_MEM(_classNameStr, NEXT_ID_STR, _oop_nextID);
	};
	private _objNameStr = OBJECT_NAME_STR(_classNameStr, _oop_nextID);
	_SETV(_objNameStr, OOP_PARENT_STR, _classNameStr);
	PUBLIC_VAR(_objNameStr, OOP_PARENT_STR);
	_SETV(_objNameStr, OOP_PUBLIC_STR, 1);
	PUBLIC_VAR(_objNameStr, OOP_PUBLIC_STR);
	private _oop_parents = _GET_SPECIAL_MEM(_classNameStr, PARENTS_STR);
	private _oop_i = 0;
	private _oop_parentCount = count _oop_parents;
	while {_oop_i < _oop_parentCount} do {
		([_objNameStr] + _extraParams) call GET_METHOD((_oop_parents select _oop_i), "new");
		_oop_i = _oop_i + 1;
	};
	CALLM(_objNameStr, "new", _extraParams);

	PROFILER_COUNTER_INC(_classNameStr);

	_objNameStr
};

// Create a copy of an object
OOP_clone = { // todo implement namespace
	params ["_objNameStr"];

	private _classNameStr = OBJECT_PARENT_CLASS_STR(_objNameStr);
	CONSTRUCTOR_ASSERT_CLASS(_classNameStr);

	// Get new ID for the new object
	private _oop_nextID = -1;
	_oop_nul = isNil {
		_oop_nextID = _GET_SPECIAL_MEM(_classNameStr, NEXT_ID_STR);
		if (isNil "_oop_nextID") then { 
			_SET_SPECIAL_MEM(_classNameStr, NEXT_ID_STR, OOP_ID_COUNTER_NEW); _oop_nextID = OOP_ID_COUNTER_NEW;
		};
		_oop_nextID = OOP_ID_COUNTER_PLUS_ONE(_oop_nextID);
		_SET_SPECIAL_MEM(_classNameStr, NEXT_ID_STR, _oop_nextID);
	};

	private _newObjNameStr = OBJECT_NAME_STR(_classNameStr, _oop_nextID);

	_SETV(_newObjNameStr, OOP_PARENT_STR, _classNameStr);
	
	CALLM(_newObjNameStr, "copy", [_objNameStr]);

	PROFILER_COUNTER_INC(_classNameStr);

	_newObjNameStr
};

// Default copy, this is what you get if you don't overwrite "copy" method of your class
OOP_clone_default = { // todo implement namespace
	params [P_THISOBJECT, "_srcObject"];
	private _classNameStr = OBJECT_PARENT_CLASS_STR(_objNameStr);
	private _memList = _GET_SPECIAL_MEM(_classNameStr, MEM_LIST_STR);
	{
		_x params ["_varName"]; //, "_attributes"]; don't need attributes for now
		private _value = _GETV(_srcObject, _varName);
		if (!isNil "_value") then {
			// Check if it's an array, array is special, it needs a deeeep copy
			if (_value isEqualType []) then {
				_SETV(_thisObject, _varName, +_value);
			} else {
				_SETV(_thisObject, _varName, _value);
			};
		};
	} forEach _memList;

	PROFILER_COUNTER_INC(_classNameStr);
};

// Default assignment, this is what you get if you don't overwrite "assign" method of your class
// It just iterates through all variables and copies their values
// This method assumes the same classes of the two objects
OOP_assign_default = { // todo implement namespace
	params ["_destObject", "_srcObject", ["_copyNil", true], '_attrRequired'];

	private _destClassNameStr = OBJECT_PARENT_CLASS_STR(_destObject);
	private _srcClassNameStr = OBJECT_PARENT_CLASS_STR(_srcObject);

	// Ensure destination and source are of the same classes
	#ifdef OOP_ASSERT
	if (_destClassNameStr != _srcClassNameStr) exitWith {
		[__FILE__, __LINE__, format ["destination and source classes don't match for objects %1 and %2", _destObject, _srcObject]] call OOP_error;
	};
	#endif
	FIX_LINE_NUMBERS()

	// Get member list and copy everything
	private _memList = _GET_SPECIAL_MEM(_destClassNameStr, MEM_LIST_STR);
	if(!isNil "_attrRequired") then {
		_memList = _memList select {
			_x params ["_varName", "_attributes"];
			_attrRequired in _attributes
		};
	};

	{
		_x params ["_varName"]; //, "_attributes"];
		private _value = _GETV(_srcObject, _varName);
		if (!isNil "_value") then {
			// Check if it's an array, array is special, it needs a deeeep copy
			if (_value isEqualType []) then {
				_SETV(_destObject, _varName, +_value);
			} else {
				_SETV(_destObject, _varName, _value);
			};
		} else {
			if (_copyNil) then {
				_SETV(_destObject, _varName, nil);
			};
		};
	} forEach _memList;
};

// Pack all variables into an array
OOP_serialize = { // todo implement namespace
	params ["_objNameStr"];

	private _classNameStr = OBJECT_PARENT_CLASS_STR(_objNameStr);

	// Select only members that are serializable
	private _memList = _GET_SPECIAL_MEM(_classNameStr, SERIAL_MEM_LIST_STR);

	private _array = [];
	_array pushBack _classNameStr;
	_array pushBack _objNameStr;

	{
		_x params ["_varName"];
		_array append [GETV(_objNameStr, _varName)];
	} forEach _memList;

	_array
};

// Same as OOP_serialize, but lets choose an attribute
OOP_serialize_attr = { // todo implement namespace
	params ["_objNameStr", "_attr", ["_serializeAllVariables", false]];

	private _classNameStr = OBJECT_PARENT_CLASS_STR(_objNameStr);

	private _memList = _GET_SPECIAL_MEM(_classNameStr, MEM_LIST_STR);
	if (!_serializeAllVariables) then {
		_memList = _memList select {
			_x params ["_varName", "_attributes"];
			_attributes findIf {
				(_x isEqualType 0 && {_x == _attr}) ||
				{_x isEqualType [] && {_x#0 == _attr}}
			} != NOT_FOUND
		};
	};

	private _array = [];
	_array pushBack _classNameStr;
	_array pushBack _objNameStr;

	{
		_x params ["_varName"];
		_array append [GETV(_objNameStr, _varName)];
	} forEach _memList;

	_array
};

OOP_serialize_save = {
	params ["_objNameStr"];

	private _classNameStr = OBJECT_PARENT_CLASS_STR(_objNameStr);

	private _memList = _GET_SPECIAL_MEM(_classNameStr, MEM_LIST_STR) select {
		_x params ["_varName", "_attributes"];
		(_attributes findIf {
			(_x isEqualTo ATTR_SAVE) ||
			{_x isEqualType [] && {_x#0 == ATTR_SAVE}}
		}) != NOT_FOUND
	};

	private _array = [];
	_array pushBack _classNameStr;
	_array pushBack _objNameStr;

	{
		_x params ["_varName"];
		_array append [GETV(_objNameStr, _varName)];
	} forEach _memList;

	_array
};

// Unpack all variables from an array into an existing object
OOP_deserialize = { // todo implement namespace
	params ["_objNameStr", "_array"];

	private _classNameStr = OBJECT_PARENT_CLASS_STR(_objNameStr);

	#ifdef OOP_ASSERT
	if (! ([_objNameStr, __FILE__, __LINE__] call OOP_assert_object)) exitWith {};
	#endif
	FIX_LINE_NUMBERS()

	private _memList = _GET_SPECIAL_MEM(_classNameStr, SERIAL_MEM_LIST_STR);

	private _iVarName = 0;

	for "_i" from 2 to ((count _array) - 1) do {
		private _value = _array select _i;
		(_memList select _iVarName) params ["_varName"];
		if (!(isNil "_value")) then {
			_SETV(_objNameStr, _varName, _value);
		} else {
			_SETV(_objNameStr, _varName, nil);
		};
		_iVarName = _iVarName + 1;
	};
};

// Same as OOP_deserialize, but lets deserialie variables with specified attribute
OOP_deserialize_attr = {
	params ["_objNameStr", "_array", "_attr", ["_deserializeAllVariables", false]];

	private _classNameStr = OBJECT_PARENT_CLASS_STR(_objNameStr);

	#ifdef OOP_ASSERT
	if (! ([_objNameStr, __FILE__, __LINE__] call OOP_assert_object)) exitWith {};
	#endif
	FIX_LINE_NUMBERS()

	private _memList = _GET_SPECIAL_MEM(_classNameStr, MEM_LIST_STR);
	if(!_deserializeAllVariables) then {
		_memList = _memList select {
			//_x params ["_varName", "_attributes"];
			_attr in (_x#1)
		};
	};

	private _iVarName = 0;

	for "_i" from 2 to ((count _array) - 1) do {
		private _value = _array select _i;
		(_memList select _iVarName) params ["_varName"];
		if(!(isNil "_value")) then {
			_SETV(_objNameStr, _varName, _value);
		} else {
			_SETV(_objNameStr, _varName, nil);
		};
		_iVarName = _iVarName + 1;
	};
};

// OOP_deserialize specialized for versioned save loading
OOP_deserialize_save = {
	params ["_objNameStr", "_array", ["_version", 666]];

	private _classNameStr = OBJECT_PARENT_CLASS_STR(_objNameStr);

	#ifdef OOP_ASSERT
	if (! ([_objNameStr, __FILE__, __LINE__] call OOP_assert_object)) exitWith { false };
	#endif
	FIX_LINE_NUMBERS()

	// Select member variables we expect to find in this save version
	private _memList = _GET_SPECIAL_MEM(_classNameStr, MEM_LIST_STR) select {
		_x params ["_varName", "_attributes"];
		(_attributes findIf {
			(_x isEqualType 0 && {_x == ATTR_SAVE}) ||
			// Version save loading
			{_x isEqualType [] && {_x#0 == ATTR_SAVE && _x#1 <= _version}}
		}) != NOT_FOUND
	};

	// Default value
	// {
	// 	_x params ["_varName", "_attributes"];
	// 	if ((_attributes findIf {
	// 		(_x isEqualType 0 && {_x == ATTR_SAVE}) ||
	// 		// Version save loading
	// 		{_x isEqualType [] && {_x#0 == ATTR_SAVE && _x#1 <= _saveVersion}}
	// 	}) != NOT_FOUND) then {
	// 		_memList pushBack _x;
	// 	} else {
	// 		private _defaultIdx = _attributes findIf {_x isEqualType [] && {_x#0 == ATTR_DEFAULT_KEY}};
	// 		if(_defaultIdx != NOT_FOUND) then {
	// 			private _defaultVal = _attributes#_defaultIdx#1;
	// 			_SETV(_objNameStr, _varName, _defaultVal);
	// 		};
	// 	};
	// } foreach _GET_SPECIAL_MEM(_classNameStr, MEM_LIST_STR);

	if((count _array - 2) != count _memList) exitWith {
		
		OOP_ERROR_2("Saved object is invalid, saved array %1 doesn't match expected member list %2", _array, _memList);
		diag_log _array;
		diag_log _memList;
		false
	};
	private _iVarName = 0;
	for "_i" from 2 to ((count _array) - 1) do {
		private _value = _array#_i;
		(_memList#(_i - 2)) params ["_varName"];
		if(!(isNil "_value")) then {
			_SETV(_objNameStr, _varName, _value);
		} else {
			_SETV(_objNameStr, _varName, nil);
		};
	};
	true
};

OOP_deref_var = { // todo implement namespace
	params ["_objNameStr", "_memName", "_memAttr"];
	if(ATTR_REFCOUNTED in _memAttr) then {
		private _memObj = _GETV(_objNameStr, _memName);
		switch(typeName _memObj) do {
			case "STRING": {
				UNREF(_memObj);
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
	private _oop_parents = _GET_SPECIAL_MEM(_oop_classNameStr, PARENTS_STR);
	private _oop_parentCount = count _oop_parents;
	private _oop_i = _oop_parentCount - 1;
	private _oop_namespace = _GET_SPECIAL_MEM(_oop_classNameStr, NAMESPACE_STR);

	CALLM0(_objNameStr, "delete");
	while {_oop_i > -1} do {
		[_objNameStr] call GET_METHOD((_oop_parents select _oop_i), "delete");
		_oop_i = _oop_i - 1;
	};

	private _isPublic = IS_PUBLIC(_objNameStr);
	private _oop_memList = _GET_SPECIAL_MEM(_oop_classNameStr, MEM_LIST_STR);
	
	if (_isPublic) then {
		{ // todo implement namespace
			// If the var is REFCOUNTED then unref it
			_x params ["_memName", "_memAttr"];
			[_objNameStr, _memName, _memAttr] call OOP_deref_var;
			_SETV(_objNameStr, _memName, nil);
			PUBLIC_VAR(_objNameStr, OOP_PARENT_STR);
		} forEach (_oop_memList+[OOP_PUBLIC_STR]);
	} else {
		{
			// If the var is REFCOUNTED then unref it
			_x params ["_memName", "_memAttr"];
			[_objNameStr, _memName, _memAttr] call OOP_deref_var;
			_SETV_NS(_oop_namespace, _objNameStr, _memName, nil);
		} forEach (_oop_memList - [OOP_PARENT_STR]);
		_SETV(_objNameStr, OOP_PARENT_STR, nil);
	};

	PROFILER_COUNTER_DEC(_oop_classNameStr);
};

// set/get session counter
OOP_setSessionCounter = {
	params [P_NUMBER("_value")];
	OOP_GVAR(sessionID) = _value;
};

OOP_getSessionCounter = {
	OOP_GVAR(sessionID)
};

// Creates a static string, needed for profiler to make static strings
#ifndef _SQF_VM
OOP_staticStringHashmap = [false] call CBA_fnc_createNamespace;
#endif
FIX_LINE_NUMBERS()

OOP_createStaticString = {
	params ["_str"];
	private _strFound = OOP_staticStringHashmap getVariable [_str, ""];
	if (_strFound == "") then {
		OOP_staticStringHashmap setVariable [_str, _str];
		_str
	} else {
		_strFound
	};
};

// Base class for intrusive ref counting.
// Use the REF and UNREF macros with objects of classes 
// derived from this one.
// Use variable attributes to enable automated ref counting for object refs:
// VARIABLE_ATTR(..., [ATTR_REFCOUNTED]);
// Use the SETV_REF, SETV_REF, T_SETV_REF family of functions to write to 
// these members to get automated de-refing of replaced value, and refing of
// new value. See RefCountedTest.sqf for example.
#define OOP_CLASS_NAME RefCounted
CLASS("RefCounted", "")
	VARIABLE_ATTR("refCount", [ATTR_SAVE]);

	METHOD(new)
		params [P_THISOBJECT];
		// Start at ref count zero. When the object gets assigned to a VARIABLE
		// using T_SETV_REF it will be automatically reffed.
		T_SETV("refCount", 0);
	ENDMETHOD;

	METHOD(ref)
		params [P_THISOBJECT];
		CRITICAL_SECTION {
			private _refCount = T_GETV("refCount");
			_refCount = _refCount + 1;
			//OOP_DEBUG_2("%1 refed to %2", _thisObject, _refCount);
			T_SETV("refCount", _refCount);
		};
	ENDMETHOD;

	METHOD(unref)
		params [P_THISOBJECT];
		CRITICAL_SECTION {
			private _refCount = T_GETV("refCount");
			_refCount = _refCount - 1;
			//OOP_DEBUG_2("%1 unrefed to %2", _thisObject, _refCount);
			if(_refCount <= 0) then {
				//OOP_DEBUG_1("%1 being deleted", _thisObject);
				DELETE(_thisObject);
			} else {
				T_SETV("refCount", _refCount);
			};
		};
	ENDMETHOD;
ENDCLASS;

// - - - - - - SQF VM - - - - - -

#ifdef _SQF_VM

#define OOP_CLASS_NAME AttrTestBase1
CLASS("AttrTestBase1", "")
	VARIABLE("var_default");
	VARIABLE_ATTR("var_private", [ATTR_PRIVATE]);
	VARIABLE_ATTR("var_get_only", [ATTR_GET_ONLY]);

	METHOD(new)
		params [P_THISOBJECT];
		T_SETV("var_default", true);
		T_SETV("var_private", true);
		T_SETV("var_get_only", true);
	ENDMETHOD;

	METHOD(validDefaultAccessTest)
		params [P_THISOBJECT];
		T_SETV("var_default", true);
		T_GETV("var_default")
	ENDMETHOD;
	
	METHOD(validPrivateAccessTest)
		params [P_THISOBJECT];
		T_SETV("var_private", true);
		T_GETV("var_private")
	ENDMETHOD;
		
	METHOD(validGetOnlyAccessTest)
		params [P_THISOBJECT];
		T_SETV("var_get_only", true);
		T_GETV("var_get_only")
	ENDMETHOD;

	STATIC_METHOD(validStaticPrivateAccessTest)
		params [P_THISCLASS, P_STRING("_obj")];
		GETV(_obj, "var_private")
	ENDMETHOD;
	
ENDCLASS;

#define OOP_CLASS_NAME AttrTestDerived1
CLASS("AttrTestDerived1", "AttrTestBase1")
	METHOD(new)
		params [P_THISOBJECT];
		
	ENDMETHOD;
	
	METHOD(validDerviedDefaultAccessTest)
		params [P_THISOBJECT, P_STRING("_base")];
		SETV(_base, "var_default", true);
		GETV(_base, "var_default")
	ENDMETHOD;
	
	METHOD(validDerviedPrivateAccessTest)
		params [P_THISOBJECT, P_STRING("_base")];
		SETV(_base, "var_private", true);
		GETV(_base, "var_private")
	ENDMETHOD;
		
	METHOD(validDerviedGetOnlyAccessTest)
		params [P_THISOBJECT, P_STRING("_base")];
		SETV(_base, "var_get_only", true);
		GETV(_base, "var_get_only")
	ENDMETHOD;
ENDCLASS;

#define OOP_CLASS_NAME AttrTestNotDerived1
CLASS("AttrTestNotDerived1", "")
	METHOD(new)
		params [P_THISOBJECT];
	ENDMETHOD;
	
	METHOD(validNonDerivedDefaultAccessTest)
		params [P_THISOBJECT, P_STRING("_base")];
		SETV(_base, "var_default", true);
		GETV(_base, "var_default")
	ENDMETHOD;
	
	METHOD(invalidNonDerivedPrivateAccessTest)
		params [P_THISOBJECT, P_STRING("_base")];
		SETV(_base, "var_private", true);
		GETV(_base, "var_private")
	ENDMETHOD;
		
	METHOD(validNonDerivedGetOnlyAccessTest)
		params [P_THISOBJECT, P_STRING("_base")];
		GETV(_base, "var_get_only")
	ENDMETHOD;

	METHOD(invalidNonDerivedGetOnlyAccessTest)
		params [P_THISOBJECT, P_STRING("_base")];
		SETV(_base, "var_get_only", true)
	ENDMETHOD;
ENDCLASS;

// Multiple inheritence tests
#define OOP_CLASS_NAME mi_a
CLASS("mi_a", "")
	METHOD(new)
	ENDMETHOD;

	public virtual METHOD(getValue)
		"A"
	ENDMETHOD;
ENDCLASS;

#define OOP_CLASS_NAME mi_b
CLASS("mi_b", "mi_a")
	METHOD(new)
	ENDMETHOD;

	public override METHOD(getValue)
		"B"
	ENDMETHOD; // override
ENDCLASS;

#define OOP_CLASS_NAME mi_c
CLASS("mi_c", "")
	METHOD(new)
	ENDMETHOD;

	public METHOD(getAnotherValue)
		"anotherValue"
	ENDMETHOD;
ENDCLASS;

#define OOP_CLASS_NAME mi_d
CLASS("mi_d", ["mi_b" ARG "mi_c"])
	METHOD(new)
	ENDMETHOD;
ENDCLASS;

["OOP Multiple Inheritence", {
	private _thisObject = NEW("mi_d", []);


	private _parents = _GET_SPECIAL_MEM("mi_d", PARENTS_STR);
	//diag_log format ["Class mi_D parents: %1", _parents];

	["Proper inheritence classes", _parents isEqualTo ["mi_a","mi_b","mi_c"]] call test_Assert;

	//diag_log format ["getValue method: %1", _GET_METHOD(mi_d", "getValue)];

	private _value = T_CALLM0("getValue");
	private _anotherValue = T_CALLM0("getAnotherValue");

	//diag_log format ["Value: %1, Another value: %2", _value, _anotherValue];

	["Test 1", T_CALLM0("getValue") == "B"] call test_Assert;
	["Test 2", T_CALLM0("getAnotherValue") == "anotherValue"] call test_Assert;

	true
}] call test_AddTest;

/*
["OOP variable attributes", {
	private _base = NEW("AttrTestBase1", []);

	["valid default access", { CALLM0(_base, "validDefaultAccessTest") }] call test_Assert;
	["valid private access", { CALLM0(_base, "validPrivateAccessTest") }] call test_Assert;
	["valid get only access", { CALLM0(_base, "validGetOnlyAccessTest") }] call test_Assert;
	["valid static private access", { CALLSM("AttrTestBase1", "validStaticPrivateAccessTest", [_base]) }] call test_Assert;

	["valid external get only access", { GETV(_base, "var_get_only"); true }] call test_Assert;
	["invalid external private access",
		{ GETV(_base, "var_private") },
		"AttrTestBase1.var_private is unreachable (private)"
	] call test_Assert_Throws;
	["invalid external get only access",
		{ SETV(_base, "var_get_only", true) },
		"AttrTestBase1.var_get_only is get-only outside of its own class heirarchy"
	] call test_Assert_Throws;

	private _derived = NEW("AttrTestDerived1", []);
	["valid derived default access", { CALLM(_derived, "validDerviedDefaultAccessTest", [_base]) }] call test_Assert;
	["valid derived private access", { CALLM(_derived, "validDerviedPrivateAccessTest", [_base]) }] call test_Assert;
	["valid derived get only access", { CALLM(_derived, "validDerviedGetOnlyAccessTest", [_base]) }] call test_Assert;

	private _nonDerived = NEW("AttrTestNotDerived1", []);
	["valid non-derived default access", { CALLM(_nonDerived, "validNonDerivedDefaultAccessTest", [_base]) }] call test_Assert;
	["invalid non-derived private access",
		{ CALLM(_nonDerived, "invalidNonDerivedPrivateAccessTest", [_base]) },
		"AttrTestBase1.var_private is unreachable (private)"
	] call test_Assert_Throws;
	["valid non-derived get only access", { CALLM(_nonDerived, "validNonDerivedGetOnlyAccessTest", [_base]) }] call test_Assert;
	["invalid non-derived get only access",
		{ CALLM(_nonDerived, "invalidNonDerivedGetOnlyAccessTest", [_base]) },
		"AttrTestBase1.var_get_only is get-only outside of its own class heirarchy"
	] call test_Assert_Throws;

}] call test_AddTest;
*/

#define OOP_CLASS_NAME JsonTestVarObj
CLASS("JsonTestVarObj", "")
	VARIABLE("var1");
	VARIABLE("var2");

	METHOD(new)
		params [P_THISOBJECT];
		T_SETV("var1", 666);
		T_SETV("var2", "String!");
	ENDMETHOD;
ENDCLASS;

#define OOP_CLASS_NAME JsonTest1
CLASS("JsonTest1", "")
	VARIABLE("varBool");
	VARIABLE("varString");
	VARIABLE("varNumber");
	VARIABLE("varArray");
	VARIABLE("varObject");
	VARIABLE("varOOPObject");
	VARIABLE("varUnset");

	METHOD(new)
		params [P_THISOBJECT];
		T_SETV("varBool", true);
		T_SETV("varString", "a string");
		T_SETV("varNumber", 667);
		T_SETV("varArray", [0 ARG 1 ARG 2]);
		private _grp = createGroup civilian;
		T_SETV("varObject", _grp);
		private _oopObj = NEW("JsonTestVarObj", []);
		T_SETV("varOOPObject", _oopObj);
	ENDMETHOD;
ENDCLASS;

// ["OOP to json", {
// 	["number", { [666] call OOP_variableToJson isEqualTo "666" }] call test_Assert;
// 	["number array", { [[0, 1, 2]] call OOP_variableToJson isEqualTo "[0,1,2]" }] call test_Assert;
// 	["number array array", { [[0, 1, [2, 3]]] call OOP_variableToJson isEqualTo "[0,1,[2,3]]" }] call test_Assert;
// 	["string", { ["a string"] call OOP_variableToJson isEqualTo """a string""" }] call test_Assert;
// 	["string array", { [["0", "1", "2"]] call OOP_variableToJson isEqualTo "[""0"",""1"",""2""]" }] call test_Assert;
// 	["bool", { [true] call OOP_variableToJson isEqualTo "true" }] call test_Assert;
// 	["bool array", { [[true, false]] call OOP_variableToJson isEqualTo "[true,false]" }] call test_Assert;
// 	private _obj = NEW("JsonTestVarObj", []);
// 	["simple object", { [_obj] call OOP_variableToJson isEqualTo format['{ "_id": "%1" , "oop_parent": "JsonTestVarObj" , "oop_public": "<nil>" , "var1": 666 , "var2": "String!" }', _obj] }] call test_Assert;
// 	private _obj2 = NEW("JsonTest1", []);
// 	private _innerObj = GETV(_obj2, "varOOPObject");
// 	["non simple object", { [_obj2] call OOP_variableToJson isEqualTo format['{ "_id": "%1" , "oop_parent": "JsonTest1" , "oop_public": "<nil>" , "varBool": true , "varString": "a string" , "varNumber": 667 , "varArray": [0,1,2] , "varObject": "CIV ALPHA 0" , "varOOPObject": { "_id": "%2" , "oop_parent": "JsonTestVarObj" , "oop_public": "<nil>" , "var1": 666 , "var2": "String!" } , "varUnset": "<nil>" }', _obj2, _innerObj] }] call test_Assert;
// }] call test_AddTest;



#define OOP_CLASS_NAME serAttrTest
CLASS("serAttrTest", "")
	VARIABLE_ATTR("var_0", [ATTR_SERIALIZABLE ARG ATTR_SAVE]);
	VARIABLE_ATTR("var_1", [ATTR_SERIALIZABLE]);
	VARIABLE_ATTR("var_2", [ATTR_SAVE_VER(1)]);
ENDCLASS;

["OOP Serialize by attribute", {
	private _obj = NEW("serAttrTest", []);
	
	SETV(_obj, "var_0", 0);
	SETV(_obj, "var_1", 1);
	SETV(_obj, "var_2", 2);
	
	private _objSerial = SERIALIZE_SAVE(_obj);

	//diag_log format ["Serialized obj: %1", _objSerial];

	SETV(_obj, "var_0", 4);
	SETV(_obj, "var_1", 5);
	SETV(_obj, "var_2", 6);

	DESERIALIZE_SAVE_VER(_obj, _objSerial, 1);

	["test var 0", GETV(_obj, "var_0") == 0] call test_Assert;
	["test var 1", GETV(_obj, "var_1") == 5] call test_Assert;
	["test var 2", GETV(_obj, "var_2") == 2] call test_Assert;

}] call test_AddTest;

#endif