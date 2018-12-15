/*
 * OOP-Light
 * A preprocessor-based limited OOP implementation for SQF
 * Author: Sparker
 * 02.06.2018
*/

/*
 * Technical info:
 *
 * Name formatting:
 * Special static class members:	o_MyClass_sm_mySpecialMember
 * Static class members: 			o_MyClass_st_myStaticMember
 * General members:					o_MyClass_N_123_myMember
 *
 * Special class members:
 * special members are static members of the class meant to be accessed only by the internals of the OOP-Light
 * nextID			- NUMBER counter to provide a new ID each time an object of this class is created
 * memList			- ARRAY with all members of this class
 * staticMemList	- ARRAY with all static members of this class
 * methodList		- ARRAY with all methods and static methods of this class
 *
 */

// ----------------------------------------------------------------------
// |            E X T E R N A L   F L A G S / D E F I N E S             |
// ----------------------------------------------------------------------

//Enables checks for member accesses at runtime
#define OOP_ASSERT

/*
#ifdef OOP_ASSERT
	diag_log "[OOP] Warning: member assertion is enabled. Disable it for better performance.";
#endif
*/

#ifndef NAMESPACE
	#define NAMESPACE missionNameSpace
#endif

// ----------------------------------------------------------------------
// |                 I N T E R N A L   S T R I N G S                    |
// ----------------------------------------------------------------------

#define OOP_PREFIX "o_"
#define OBJECT_SEPARATOR "_N_"
#define SPECIAL_SEPARATOR "_spm_"
#define STATIC_SEPARATOR "_stm_"
#define METHOD_SEPARATOR "_fnc_"

// ----------------------------------------------------------------------
// |          I N T E R N A L   N A M E   F O R M A T T I N G           |
// ----------------------------------------------------------------------

//Name of a specific instance of object
#define OBJECT_NAME_STR(classNameStr, objIDInt) (OOP_PREFIX + (classNameStr) + OBJECT_SEPARATOR + (format ["%1", objIDInt]))

//String name of a static member
#define CLASS_STATIC_MEM_NAME_STR(classNameStr, memNameStr) ((OOP_PREFIX) + (classNameStr) + STATIC_SEPARATOR + (memNameStr))

//String name of a method
#define CLASS_METHOD_NAME_STR(classNameStr, methodNameStr) ((classNameStr) + METHOD_SEPARATOR + (methodNameStr))

//String name of a special member
#define CLASS_SPECIAL_MEM_NAME_STR(classNameStr, memNameStr) (OOP_PREFIX + (classNameStr) + SPECIAL_SEPARATOR + (memNameStr))

//String name of a non-static member
#define OBJECT_MEM_NAME_STR(objNameStr, memNameStr) ((objNameStr) + "_" + memNameStr)

//Gets parent class of an object
#define OBJECT_PARENT_CLASS_STR(objNameStr) (FORCE_GET_MEM(objNameStr, OOP_PARENT_STR))

// ==== Private special members
#define NEXT_ID_STR "nextID"
#define MEM_LIST_STR "memList"
#define STATIC_MEM_LIST_STR "staticMemList"
#define METHOD_LIST_STR "methodList"
#define PARENTS_STR "parents"
#define OOP_PARENT_STR "oop_parent"

// ----------------------------------------------------------------------
// |          I N T E R N A L   A C C E S S   M E M B E R S             |
// ----------------------------------------------------------------------

#define FORCE_SET_MEM(objNameStr, memNameStr, value) NAMESPACE setVariable [OBJECT_MEM_NAME_STR(objNameStr, memNameStr), value]
#define FORCE_SET_STATIC_MEM(classNameStr, memNameStr, value) NAMESPACE setVariable [CLASS_STATIC_MEM_NAME_STR(classNameStr, memNameStr), value]
#define FORCE_SET_METHOD(classNameStr, methodNameStr, code) NAMESPACE setVariable [CLASS_METHOD_NAME_STR(classNameStr, methodNameStr), code]
#define FORCE_GET_MEM(objNameStr, memNameStr) ( NAMESPACE getVariable OBJECT_MEM_NAME_STR(objNameStr, memNameStr) )
#define FORCE_GET_STATIC_MEM(classNameStr, memNameStr) ( NAMESPACE getVariable CLASS_STATIC_MEM_NAME_STR(classNameStr, memNameStr) )
#define FORCE_GET_METHOD(classNameStr, methodNameStr) ( NAMESPACE getVariable CLASS_METHOD_NAME_STR(classNameStr, methodNameStr) )

//Special members don't use run time checks
#define SET_SPECIAL_MEM(classNameStr, memNameStr, value) NAMESPACE setVariable [CLASS_SPECIAL_MEM_NAME_STR(classNameStr, memNameStr), value]
#define GET_SPECIAL_MEM(classNameStr, memNameStr) ( NAMESPACE getVariable CLASS_SPECIAL_MEM_NAME_STR(classNameStr, memNameStr) )

// -----------------------------------------------------
// |           A C C E S S   M E M B E R S             |
// -----------------------------------------------------

#ifdef OOP_ASSERT
	#define SET_MEM(objNameStr, memNameStr, value) if([objNameStr, memNameStr, __FILE__, __LINE__] call OOP_assert_member) then {FORCE_SET_MEM(objNameStr, memNameStr, value)}
	#define SET_STATIC_MEM(classNameStr, memNameStr, value) if([classNameStr, memNameStr, __FILE__, __LINE__] call OOP_assert_staticMember) then {FORCE_SET_STATIC_MEM(classNameStr, memNameStr, value)}
	#define GET_MEM(objNameStr, memNameStr) ( if([objNameStr, memNameStr, __FILE__, __LINE__] call OOP_assert_member) then {FORCE_GET_MEM(objNameStr, memNameStr)}else{nil} )
	#define GET_STATIC_MEM(classNameStr, memNameStr) ( if([classNameStr, memNameStr, __FILE__, __LINE__] call OOP_assert_staticMember) then {FORCE_GET_STATIC_MEM(classNameStr, memNameStr)}else{nil} )
	#define GET_METHOD(classNameStr, methodNameStr) ( if([classNameStr, methodNameStr, __FILE__, __LINE__] call OOP_assert_method) then {FORCE_GET_METHOD(classNameStr, methodNameStr)}else{nil} )
#else
	#define SET_MEM(objNameStr, memNameStr, value) FORCE_SET_MEM(objNameStr, memNameStr, value)
	#define SET_STATIC_MEM(classNameStr, memNameStr, value) FORCE_SET_STATIC_MEM(classNameStr, memNameStr, value)
	#define GET_MEM(objNameStr, memNameStr) FORCE_GET_MEM(objNameStr, memNameStr)
	#define GET_STATIC_MEM(classNameStr, memNameStr) FORCE_GET_STATIC_MEM(classNameStr, memNameStr)
	#define GET_METHOD(classNameStr, methodNameStr) FORCE_GET_METHOD(classNameStr, methodNameStr)
#endif

#define SET_VAR(a, b, c) SET_MEM(a, b, c)
#define SET_STATIC_VAR(a, b, c) SET_STATIC_MEM(a, b, c)
#define GET_VAR(a, b) GET_MEM(a, b)
#define GET_STATIC_VAR(a, b) GET_STATIC_MEM(a, b)

// Shortened variants of macros
#define SETV(a, b, c) SET_VAR(a, b, c)
#define SETSV(a, b, c) SET_STATIC_VAR(a, b, c)
#define GETV(a, b) GET_VAR(a, b)
#define GETSV(a, b) GET_STATIC_V(a, b)

// todo add macros to check object validity
/*
#define IS_VALID(objNameStr)
private _classNameStr = OBJECT_PARENT_CLASS_STR(_objNameStr);
	//Check if it's an object
	if(isNil "_classNameStr") exitWith {
		[_file, _line, _objNameStr] call OOP_error_notObject;
		false;
	};
*/

// -----------------------------------------------------
// |             M E T H O D   C A L L S               |
// -----------------------------------------------------

#define GETM(objNameStr, methodNameStr) GET_METHOD(OBJECT_PARENT_CLASS_STR(objNameStr), methodNameStr)

//Same performance for small functions
//#define CALL_METHOD(objNameStr, methodNameStr, extraParams) ([objNameStr] + extraParams) call (call compile (CLASS_STATIC_MEM_NAME_STR(OBJECT_PARENT_CLASS_STR(objNameStr), methodNameStr)))
#define CALL_METHOD(objNameStr, methodNameStr, extraParams) ([objNameStr] + extraParams) call GET_METHOD(OBJECT_PARENT_CLASS_STR(objNameStr), methodNameStr)
#define CALL_METHOD_0(objNameStr, methodNameStr) ([objNameStr]) call GET_METHOD(OBJECT_PARENT_CLASS_STR(objNameStr), methodNameStr)
#define CALL_METHOD_1(objNameStr, methodNameStr, a) ([objNameStr, a]) call GET_METHOD(OBJECT_PARENT_CLASS_STR(objNameStr), methodNameStr)
#define CALL_METHOD_2(objNameStr, methodNameStr, a, b) ([objNameStr, a, b]) call GET_METHOD(OBJECT_PARENT_CLASS_STR(objNameStr), methodNameStr)
#define CALL_METHOD_3(objNameStr, methodNameStr, a, b, c) ([objNameStr, a, b, c]) call GET_METHOD(OBJECT_PARENT_CLASS_STR(objNameStr), methodNameStr)
#define CALL_METHOD_4(objNameStr, methodNameStr, a, b, c, d) ([objNameStr, a, b, c, d]) call GET_METHOD(OBJECT_PARENT_CLASS_STR(objNameStr), methodNameStr)
#define CALL_CLASS_METHOD(classNameStr, objNameStr, methodNameStr, extraParams) ([objNameStr] + extraParams) call GET_METHOD(classNameStr, methodNameStr)
#define CALL_STATIC_METHOD(classNameStr, methodNameStr, extraParams) ([classNameStr] + extraParams) call GET_METHOD(classNameStr, methodNameStr)

// Shortened variants of macros
#define CALLM(a, b, c) CALL_METHOD(a, b, c)
#define CALLCM(a, b, c) CALL_CLASS_METHOD(a, b, c)
#define CALLSM(a, b, c) CALL_STATIC_METHOD(a, b, c)

// Macros for multiple variables
#define CALLM0(a, b) CALL_METHOD_0(a, b)
#define CALLM1(a, b, c) CALL_METHOD_1(a, b, c)
#define CALLM2(a, b, c, d) CALL_METHOD_2(a, b, c, d)
#define CALLM3(a, b, c, d, e) CALL_METHOD_3(a, b, c, d, e)
#define CALLM4(a, b, c, d, e, f) CALL_METHOD_4(a, b, c, d, e, f)

// Remote executions
#define REMOTE_EXEC_METHOD(objNameStr, methodNameStr, targets, extraParams) [objNameStr, methodNameStr, extraParams] remoteExec("OOP_callFromRemote", targets, false)
#define REMOTE_EXEC_CALL_METHOD(objNameStr, methodNameStr, targets, extraParams) [objNameStr, methodNameStr, extraParams] remoteExecCall("OOP_callFromRemote", targets, false)

// -----------------------------------------------------
// |       M E M B E R   D E C L A R A T I O N S       |
// -----------------------------------------------------

#define VARIABLE(varNameStr) _oop_memList pushBackUnique varNameStr

#define STATIC_VARIABLE(varNameStr) _oop_staticMemList pushBackUnique varNameStr

#define MEMBER(memNameStr) VARIABLE(memNameStr)

#define STATIC_MEMBER(memNameStr) STATIC_VARIABLE(memNameStr)

#define METHOD(methodNameStr) _oop_methodList pushBackUnique methodNameStr; \
NAMESPACE setVariable [CLASS_METHOD_NAME_STR(_oop_classNameStr, methodNameStr),

#define ENDMETHOD ]

#define METHOD_FILE(methodNameStr, path) _oop_methodList pushBackUnique methodNameStr; \
NAMESPACE setVariable [CLASS_METHOD_NAME_STR(_oop_classNameStr, methodNameStr), compile preprocessFileLineNumbers path]

#define STATIC_METHOD(methodNameStr) _oop_methodList pushBackUnique methodNameStr; \
NAMESPACE setVariable [CLASS_METHOD_NAME_STR(_oop_classNameStr, methodNameStr),

#define STATIC_METHOD_FILE(methodNameStr, path) _oop_methodList pushBackUnique methodNameStr; \
NAMESPACE setVariable [CLASS_METHOD_NAME_STR(_oop_classNameStr, methodNameStr), compile preprocessFileLineNumbers path]

// ----------------------------------------
// |              C L A S S               |
// ----------------------------------------

/*
 * Technical info:
 * First we initialize special members of the class, then we initialize new, delete and copy methods.
 * The name of this class is added to the hierarchy of its base class, if it's not "".
 * The methods of base class are copied to the methods of the derived class, except for "new" and "delete", because they will be called through the hierarchy anyway.
 */

#define CLASS(classNameStr, baseClassNameStr)	[] call { \
scopeName "scopeClass"; \
private _oop_classNameStr = classNameStr; \
SET_SPECIAL_MEM(_oop_classNameStr, NEXT_ID_STR, 0); \
private _oop_memList = []; \
private _oop_staticMemList = []; \
private _oop_parents = []; \
private _oop_methodList = []; \
if (baseClassNameStr != "") then { \
	if (!([baseClassNameStr, __FILE__, __LINE__] call OOP_assert_class)) then {breakOut "scopeClass";}; \
	_oop_parents = +GET_SPECIAL_MEM(baseClassNameStr, PARENTS_STR); _oop_parents pushBackUnique baseClassNameStr; \
	_oop_memList = +GET_SPECIAL_MEM(baseClassNameStr, MEM_LIST_STR); \
	_oop_staticMemList = +GET_SPECIAL_MEM(baseClassNameStr, STATIC_MEM_LIST_STR); \
	_oop_methodList = +GET_SPECIAL_MEM(baseClassNameStr, METHOD_LIST_STR); \
	private _oop_topParent = _oop_parents select ((count _oop_parents) - 1); \
	{ private _oop_methodCode = FORCE_GET_METHOD(_oop_topParent, _x); \
	FORCE_SET_METHOD(classNameStr, _x, _oop_methodCode); \
	} forEach (_oop_methodList - ["new", "delete", "copy"]); \
}; \
SET_SPECIAL_MEM(_oop_classNameStr, PARENTS_STR, _oop_parents); \
SET_SPECIAL_MEM(_oop_classNameStr, MEM_LIST_STR, _oop_memList); \
SET_SPECIAL_MEM(_oop_classNameStr, STATIC_MEM_LIST_STR, _oop_staticMemList); \
SET_SPECIAL_MEM(_oop_classNameStr, METHOD_LIST_STR, _oop_methodList); \
METHOD("new") {} ENDMETHOD; \
METHOD("delete") {} ENDMETHOD; \
METHOD("copy") {} ENDMETHOD; \
VARIABLE(OOP_PARENT_STR);

// ----------------------------------------
// |           E N D C L A S S            |
// ----------------------------------------

/*
 * Technical info:
 * It just terminates the call block of the CLASS
 */

#define ENDCLASS }

// ----------------------------------------------------------------------
// |        C O N S T R U C T O R  O F   E X I S T I N G   O B J E C T  |
// ----------------------------------------------------------------------

/*
 * Technical info:
 * Creates an object with given name, doesn't call its constructor.
 */

#define NEW_EXISTING(classNameStr, objNameStr) [] call { \
FORCE_SET_MEM(objNameStr, OOP_PARENT_STR, classNameStr); \
objNameStr \
}

// ----------------------------------------
// |        C O N S T R U C T O R         |
// ----------------------------------------

/*
 * Technical info:
 * Check the class name if needed.
 * Increase the object counter for this class.
 * Call all constructors of the base classes from base to derived classes.
 */

#ifdef OOP_ASSERT
#define CONSTRUCTOR_ASSERT_CLASS(classNameStr) if (!([classNameStr, __FILE__, __LINE__] call OOP_assert_class)) exitWith {format ["ERROR_NO_CLASS_%1", classNameStr]};
#else
#define CONSTRUCTOR_ASSERT_CLASS(classNameStr)
#endif

#define NEW(classNameStr, extraParams) [] call { \
CONSTRUCTOR_ASSERT_CLASS(classNameStr) \
private _oop_nextID = GET_SPECIAL_MEM(classNameStr, NEXT_ID_STR); \
if (isNil "_oop_nextID") then { SET_SPECIAL_MEM(classNameStr, NEXT_ID_STR, 0);	_oop_nextID = 0;}; \
SET_SPECIAL_MEM(classNameStr, NEXT_ID_STR, _oop_nextID+1); \
private _objNameStr = OBJECT_NAME_STR(classNameStr, _oop_nextID); \
FORCE_SET_MEM(_objNameStr, OOP_PARENT_STR, classNameStr); \
private _oop_parents = GET_SPECIAL_MEM(classNameStr, PARENTS_STR); \
private _oop_i = 0; \
private _oop_parentCount = count _oop_parents; \
while {_oop_i < _oop_parentCount} do { \
	([_objNameStr] + extraParams) call GET_METHOD((_oop_parents select _oop_i), "new"); \
	_oop_i = _oop_i + 1; \
}; \
CALL_METHOD(_objNameStr, "new", extraParams); \
_objNameStr \
}

// ----------------------------------------
// |         D E S T R U C T O R          |
// ----------------------------------------

/*
 * Technical info:
 * Check object validity if needed.
 * Call all destructors of the base classes from derived classes to base classes.
 * Clean (set to nil) all members of this object.
 */

#ifdef OOP_ASSERT
#define DESTRUCTOR_ASSERT_OBJECT(objNameStr) if (!([objNameStr, __FILE__, __LINE__] call OOP_assert_object)) exitWith {};
#else
#define DESTRUCTOR_ASSERT_OBJECT(objNameStr)
#endif

#define DELETE(objNameStr) [] call { \
DESTRUCTOR_ASSERT_OBJECT(objNameStr) \
private _oop_classNameStr = OBJECT_PARENT_CLASS_STR(objNameStr); \
private _oop_parents = GET_SPECIAL_MEM(_oop_classNameStr, PARENTS_STR); \
private _oop_parentCount = count _oop_parents; \
private _oop_i = _oop_parentCount - 1; \
CALL_METHOD(objNameStr, "delete", []); \
while {_oop_i > -1} do { \
[objNameStr] call GET_METHOD((_oop_parents select _oop_i), "delete"); \
_oop_i = _oop_i - 1; \
}; \
private _oop_memList = GET_SPECIAL_MEM(_oop_classNameStr, MEM_LIST_STR); \
{FORCE_SET_MEM(objNameStr, _x, nil);} forEach _oop_memList; \
}
