#include "..\config\global_config.hpp"

#include "Common.h"

//  * OOP-Light
//  * A preprocessor-based limited OOP implementation for SQF
//  * Author: Sparker
//  * 02.06.2018

// ----------------------------------------------------
// |          C O N T R O L  F L A G S                |
// ----------------------------------------------------

// Defines the ofstream file name for OOP_INFO_, OOP_ERROR_, OOP_WARNING_ macros
// Must be defined before including OOP_Light.h into your class definition .sqf file
//#define OFSTREAM_FILE "OOP.rpt"

// Enables output to external file with ofstream in all OOP classes
// It's a global flag, must be defined here

// #define OFSTREAM_ENABLE

// #define OOP_PROFILE

// Enables checks for member accesses at runtime
// As well as other assertions
// It's a global flag, must be defined here

//#define OOP_ASSERT
// #define OOP_ASSERT_ACCESS

// Enables support for Arma Script Profiler globally
// Set it in this file
//#define ASP_ENABLE

// Enables macros for Arma Script Profiler counters, enables global counter variables per every class
// Define it at the top of the file per every class where you need to count objects
//#define PROFILER_COUNTERS_ENABLE

// Enables logging of each REF/UNREF on OOP objects
//#define OOP_LOG_REF_UNREF

// This class name without quotes
#define OOP_DEFAULT_CLASS_NAME UnknownClassName
#ifndef OOP_CLASS_NAME
#define OOP_CLASS_NAME OOP_DEFAULT_CLASS_NAME
#endif

// Default OFSTREAM_FILE to put data to
#ifndef OFSTREAM_FILE
#define OFSTREAM_FILE "OOP.rpt"
#endif
#ifndef OFSTREAM_ENABLE
#undef OFSTREAM_FILE
#endif

// Include platform-dependant redefinitions
#include "Platform.h"

// ----------------------------------------------------------------------
// |                P R O F I L E R   C O U N T E R S                   |
// ----------------------------------------------------------------------
#ifndef ASP_ENABLE
#undef PROFILER_COUNTERS_ENABLE
#endif

#define COUNTER_NAME_STR(nameStr) ("g_profCnt_" + nameStr)

#ifdef PROFILER_COUNTERS_ENABLE
#define PROFILER_COUNTER_INIT(nameStr) missionNamespace setVariable[COUNTER_NAME_STR(nameStr), 0];
#else
#define PROFILER_COUNTER_INIT(nameStr)
#endif

#ifdef ASP_ENABLE
#define PROFILER_COUNTER_INC(nameStr) isNil { \
	private _oop_cnt = missionNamespace getVariable COUNTER_NAME_STR(nameStr); \
	if(!isNil "_oop_cnt") then { \
		missionNamespace setVariable [COUNTER_NAME_STR(nameStr), _oop_cnt+1]; \
		nameStr profilerSetCounter _oop_cnt; \
	}; \
};

#define PROFILER_COUNTER_DEC(nameStr) isNil { \
	private _oop_cnt = missionNamespace getVariable COUNTER_NAME_STR(nameStr); \
	if(!isNil "_oop_cnt") then { \
		missionNamespace setVariable [COUNTER_NAME_STR(nameStr), _oop_cnt-1]; \
		nameStr profilerSetCounter _oop_cnt; \
	}; \
};
#else
#define PROFILER_COUNTER_INC(nameStr)
#define PROFILER_COUNTER_DEC(nameStr)
#endif

// Minimum amount of time for a function to take before its profile entry will be written out
#ifndef OOP_PROFILE_MIN_T
	#define OOP_PROFILE_MIN_T 0.1
#endif

/*
#ifdef OOP_ASSERT
	diag_log "[OOP] Warning: member assertion is enabled. Disable it for better performance.";
#endif
*/

// Defines into which namespace this class is going to store variables
// Not all OOP functionality is supported with namespaces yet!
// ! ! ! ! ! Namespaces don't work at all, don't even try to use them, just use mission namespace ! ! ! ! ! !
#ifndef NAMESPACE
	#define NAMESPACE missionNameSpace
#endif

// ---------------------------------------------------------------------------------
// |          A R M A   S C R I P T   P R O F I L E R   S C O P E S                |
// ---------------------------------------------------------------------------------

#ifdef ASP_ENABLE
#define PROFILER_FUNCTION_NAME(className,methodName) className##_fnc_##methodName
#define ASP_CREATE_PROFILE_SCOPE(className,methodName) private _oop_ASPScope_##className##methodName = createProfileScope QUOTE(PROFILER_FUNCTION_NAME(className,methodName));
#else
#define ASP_CREATE_PROFILE_SCOPE(className,methodName)
#endif

// ----------------------------------------------------------------------
// |                 I N T E R N A L   S T R I N G S                    |
// ----------------------------------------------------------------------

#define OOP_PREFIX "o_"
#define OBJECT_SEPARATOR "_N_"
#define SPECIAL_SEPARATOR "_spm_"
#define STATIC_SEPARATOR "_stm_"
#define METHOD_SEPARATOR "_fnc_"
#define METHOD_ATTR_SEPARATOR "_fncattr_"
#define INNER_PREFIX "inner_"
#define GLOBAL_SEPARATOR "global_"

// ----------------------------------------------------------------------
// |          I N T E R N A L   N A M E   F O R M A T T I N G           |
// ----------------------------------------------------------------------

//Name of a specific instance of object
#define OBJECT_NAME_STR(classNameStr, objIDInt)  (format ["o_%1_c%2_s%3_n%4", classNameStr, CLIENT_OWNER, OOP_GVAR(sessionID), objIDInt])

//String name of a static member
#define CLASS_STATIC_MEM_NAME_STR(classNameStr, memNameStr) ((OOP_PREFIX) + (classNameStr) + STATIC_SEPARATOR + (memNameStr))

//String name of a method
#define CLASS_METHOD_NAME_STR(classNameStr, methodNameStr) ((classNameStr) + METHOD_SEPARATOR + (methodNameStr))

//String name of method attributes
#define CLASS_METHOD_ATTR_STR(classNameStr, methodNameStr) ((classNameStr) + METHOD_ATTR_SEPARATOR + (methodNameStr))

//String name of a special member
#define CLASS_SPECIAL_MEM_NAME_STR(classNameStr, memNameStr) (OOP_PREFIX + (classNameStr) + SPECIAL_SEPARATOR + (memNameStr))

//String name of a non-static member
#define OBJECT_MEM_NAME_STR(objNameStr, memNameStr) ((objNameStr) + "_" + memNameStr)

//Gets parent class of an object
#define OBJECT_PARENT_CLASS_STR(objNameStr) (_GETV(objNameStr, OOP_PARENT_STR))

//String name of an inner method
#define INNER_METHOD_NAME_STR(methodNameStr) (INNER_PREFIX + methodNameStr)

// ==== Private special members
#define NEXT_ID_STR "nextID"
#define MEM_LIST_STR "memList"
#define STATIC_MEM_LIST_STR "staticMemList"
#define SERIAL_MEM_LIST_STR "serialMemList"
#define METHOD_LIST_STR "methodList"
#define OWN_METHOD_LIST_STR "ownMethodList"
#define PARENTS_STR "parents"
#define OOP_PARENT_STR "oop_parent"
#define OOP_PUBLIC_STR "oop_public"
#define NAMESPACE_STR "namespace"

// Other important strings
#define OOP_ERROR_DEBRIEFING_SECTION_VAR_NAME_STR "oop_missionEndText"
// CfgDebriefing class entry in description.ext which is shown when a critical OOP error happens
#define OOP_ERROR_DEBRIEFING_CLASS_NAME	end_OOP_class_error
#define OOP_ERROR_DEBRIEFING_CLASS_NAME_STR "end_OOP_class_error"

// ----------------------------------------------------------------------
// |          I N T E R N A L   A C C E S S   M E M B E R S             |
// ----------------------------------------------------------------------

#define _SETV(objNameStr, memNameStr, value) 					NAMESPACE setVariable [OBJECT_MEM_NAME_STR(objNameStr, memNameStr), value]
#define _SETV_NS(ns, objNameStr, memNameStr, value) 			ns setVariable [OBJECT_MEM_NAME_STR(objNameStr, memNameStr), value]
#define _SETV_REF(objNameStr, memNameStr, value) \
	isNil { \
		private _oldVal = NAMESPACE getVariable [OBJECT_MEM_NAME_STR(objNameStr, memNameStr), NULL_OBJECT]; \
		if (!IS_NULL_OBJECT(_oldVal)) then { UNREF(_oldVal); }; \
		if (!IS_NULL_OBJECT(value)) then { REF((value)); }; \
		NAMESPACE setVariable [OBJECT_MEM_NAME_STR(objNameStr, memNameStr), value] \
	}

#define _SETSV(classNameStr, memNameStr, value) 				NAMESPACE setVariable [CLASS_STATIC_MEM_NAME_STR(classNameStr, memNameStr), value]
#define _SET_METHOD(classNameStr, methodNameStr, code) 			NAMESPACE setVariable [CLASS_METHOD_NAME_STR(classNameStr, methodNameStr), code]
#define _GETV(objNameStr, memNameStr) 							( NAMESPACE getVariable OBJECT_MEM_NAME_STR(objNameStr, memNameStr) )
#define _GETSV(classNameStr, memNameStr) 						( NAMESPACE getVariable CLASS_STATIC_MEM_NAME_STR(classNameStr, memNameStr) )
#define _GET_METHOD(classNameStr, methodNameStr) 				( NAMESPACE getVariable CLASS_METHOD_NAME_STR(classNameStr, methodNameStr) )

#ifndef _SQF_VM
#define _PUBLIC_VAR(objNameStr, memNameStr) 					publicVariable OBJECT_MEM_NAME_STR(objNameStr, memNameStr)
#define _PUBLIC_STATIC_VAR(classNameStr, memNameStr) 			publicVariable CLASS_STATIC_MEM_NAME_STR(classNameStr, memNameStr)
#else
#define _PUBLIC_VAR(objNameStr, memNameStr)
#define _PUBLIC_STATIC_VAR(classNameStr, memNameStr)
#endif

//Special members don't use run time checks
#define _SET_SPECIAL_MEM(classNameStr, memNameStr, value) 		NAMESPACE setVariable [CLASS_SPECIAL_MEM_NAME_STR(classNameStr, memNameStr), value]
#define _GET_SPECIAL_MEM(classNameStr, memNameStr) 				( NAMESPACE getVariable CLASS_SPECIAL_MEM_NAME_STR(classNameStr, memNameStr) )

// -----------------------------------------------------
// |           A C C E S S   M E M B E R S             |
// -----------------------------------------------------

#ifdef OOP_ASSERT_ACCESS
	#define _ASSERT_SET_MEMBER_ACCESS(objNameStr, memNameStr) 			[objNameStr, memNameStr, __FILE__, __LINE__] call OOP_assert_set_member_access
	#define _ASSERT_SET_STATIC_MEMBER_ACCESS(classNameStr, memNameStr) 	[classNameStr, memNameStr, __FILE__, __LINE__] call OOP_assert_set_static_member_access
	#define _ASSERT_GET_MEMBER_ACCESS(objNameStr, memNameStr) 			[objNameStr, memNameStr, __FILE__, __LINE__] call OOP_assert_get_member_access
	#define _ASSERT_GET_STATIC_MEMBER_ACCESS(classNameStr, memNameStr)	[classNameStr, memNameStr, __FILE__, __LINE__] call OOP_assert_get_static_member_access
#else
	#define _ASSERT_SET_MEMBER_ACCESS(objNameStr, memNameStr) 			
	#define _ASSERT_SET_STATIC_MEMBER_ACCESS(classNameStr, memNameStr) 	
	#define _ASSERT_GET_MEMBER_ACCESS(objNameStr, memNameStr) 			
	#define _ASSERT_GET_STATIC_MEMBER_ACCESS(classNameStr, memNameStr)	
#endif

#ifdef OOP_ASSERT
	#define SETV(objNameStr, memNameStr, value) \
		if([objNameStr, memNameStr, __FILE__, __LINE__] call OOP_assert_member_is_not_ref) then { \
			_ASSERT_SET_MEMBER_ACCESS(objNameStr, memNameStr); \
			_SETV(objNameStr, memNameStr, value) \
		}
	#define SETV_REF(objNameStr, memNameStr, value) \
		if([objNameStr, memNameStr, __FILE__, __LINE__] call OOP_assert_member_is_ref) then { \
			_ASSERT_SET_MEMBER_ACCESS(objNameStr, memNameStr); \
			_SETV_REF(objNameStr, memNameStr, value) \
		}
	#define SETSV(classNameStr, memNameStr, value) \
		if([classNameStr, memNameStr, __FILE__, __LINE__] call OOP_assert_staticMember) then { \
			_ASSERT_SET_STATIC_MEMBER_ACCESS(classNameStr, memNameStr); \
			_SETSV(classNameStr, memNameStr, value) \
		}
	#define GETV(objNameStr, memNameStr) \
		( if([objNameStr, memNameStr, __FILE__, __LINE__] call OOP_assert_member) then { \
			_ASSERT_GET_MEMBER_ACCESS(objNameStr, memNameStr); \
			_GETV(objNameStr, memNameStr) \
		}else{nil} )
	#define GETSV(classNameStr, memNameStr) \
		( if([classNameStr, memNameStr, __FILE__, __LINE__] call OOP_assert_staticMember) then { \
			_ASSERT_GET_STATIC_MEMBER_ACCESS(classNameStr, memNameStr); \
			_GETSV(classNameStr, memNameStr) \
		}else{nil} )
	#define PUBLIC_VAR(objNameStr, memNameStr) \
		if([objNameStr, memNameStr, __FILE__, __LINE__] call OOP_assert_member) then { \
			_PUBLIC_VAR(objNameStr, memNameStr) \
		}
	#define PUBLIC_STATIC_VAR(classNameStr, memNameStr) \
		if([classNameStr, memNameStr, __FILE__, __LINE__] call OOP_assert_staticMember) then { \
			_PUBLIC_STATIC_VAR(classNameStr, memNameStr) \
		}
	#define GET_METHOD(classNameStr, methodNameStr) \
		( if([classNameStr, methodNameStr, "", __FILE__, __LINE__] call OOP_assert_method) then { \
			_GET_METHOD(classNameStr, methodNameStr) \
		}else{nil} )
	#define GET_METHOD_OBJ(classNameStr, methodNameStr, objectNameStr) \
		( if([classNameStr, methodNameStr, objectNameStr, __FILE__, __LINE__] call OOP_assert_method) then { \
			_GET_METHOD(classNameStr, methodNameStr) \
		}else{nil} )
#else
	#define SETV(objNameStr, memNameStr, value) _SETV(objNameStr, memNameStr, value)
	#define SETV_REF(objNameStr, memNameStr, value) _SETV_REF(objNameStr, memNameStr, value)
	#define SETSV(classNameStr, memNameStr, value) _SETSV(classNameStr, memNameStr, value)
	#define GETV(objNameStr, memNameStr) _GETV(objNameStr, memNameStr)
	#define GETSV(classNameStr, memNameStr) _GETSV(classNameStr, memNameStr)
	#define PUBLIC_VAR(objNameStr, memNameStr) _PUBLIC_VAR(objNameStr, memNameStr)
	#define PUBLIC_STATIC_VAR(classNameStr, memNameStr) _PUBLIC_STATIC_VAR(classNameStr, memNameStr)
	#define GET_METHOD(classNameStr, methodNameStr) _GET_METHOD(classNameStr, methodNameStr)
	#define GET_METHOD_OBJ(classNameStr, methodNameStr, objectNameStr) _GET_METHOD(classNameStr, methodNameStr)
#endif

#define SET_VAR_PUBLIC(a, b, c) 				SETV(a, b, c); PUBLIC_VAR(a, b)

// Getting/setting variables of _thisObject
#define T_SETV(varNameStr, varValue) 			SETV(_thisObject, varNameStr, varValue)
#define T_SETV_REF(varNameStr, varValue) 		SETV_REF(_thisObject, varNameStr, varValue)
#define T_PUBLIC_VAR(varNameStr) 				PUBLIC_VAR(_thisObject, varNameStr)
#define T_SETV_PUBLIC(varNameStr, varValue) 	SET_VAR_PUBLIC(_thisObject, varNameStr, varValue)
#define T_GETV(varNameStr) 						GETV(_thisObject, varNameStr)

// Returns object class name
#define GET_OBJECT_CLASS(objNameStr) 			OBJECT_PARENT_CLASS_STR(objNameStr)

// Returns true if reference passed is pointing at a valid object 
#define IS_OOP_OBJECT(objNameStr) 				(! (isNil {GET_OBJECT_CLASS(objNameStr)}))

// Returns variable names of this class
#define GET_CLASS_MEMBERS(classNameStr) 		_GET_SPECIAL_MEM(classNameStr, MEM_LIST_STR)

// -----------------------------------------------------
// |             M E T H O D   C A L L S               |
// -----------------------------------------------------

//Same performance for small functions
//#define CALLM(objNameStr, methodNameStr, extraParams) ([objNameStr] + extraParams) call (call compile (CLASS_STATIC_MEM_NAME_STR(OBJECT_PARENT_CLASS_STR(objNameStr), methodNameStr)))

// #ifdef OOP_METHOD_CALL_ASSERT
// 	#define GET_METHOD_STD(objNameStr, methodNameStr) 					(call {[OBJECT_PARENT_CLASS_STR(objNameStr), methodNameStr, __FILE__, __LINE__] call OOP_assert_method_call; GET_METHOD(OBJECT_PARENT_CLASS_STR(objNameStr), methodNameStr)})
// 	#define GET_METHOD_THIS(methodNameStr) 								(call {[OBJECT_PARENT_CLASS_STR(_thisObject), methodNameStr, __FILE__, __LINE__] call OOP_assert_method_call; GET_METHOD(OBJECT_PARENT_CLASS_STR(_thisObject), methodNameStr)})
// 	#define GET_METHOD_STATIC(classNameStr, methodNameStr) 				(call {[classNameStr, methodNameStr, __FILE__, __LINE__] call OOP_assert_method_call; GET_METHOD(classNameStr, methodNameStr)})
// 	#define GET_METHOD_CLASS(classNameStr, objNameStr, methodNameStr) 	(call {[classNameStr, methodNameStr, __FILE__, __LINE__] call OOP_assert_method_call; GET_METHOD(classNameStr, methodNameStr)})
// 	#define GET_METHOD_THIS_CLASS(classNameStr, methodNameStr) 			(call {[classNameStr, methodNameStr, __FILE__, __LINE__] call OOP_assert_method_call; GET_METHOD(classNameStr, methodNameStr)})

// 	// #define GET_METHOD_STD(objNameStr, methodNameStr) 					(if ([objNameStr, methodNameStr, __FILE__, __LINE__] call OOP_assert_method_std_call) then { GET_METHOD(OBJECT_PARENT_CLASS_STR(objNameStr), methodNameStr) } else { nil })
// 	// #define GET_METHOD_THIS(methodNameStr) 								(if ([methodNameStr, __FILE__, __LINE__] call OOP_assert_method_this_call) then { GET_METHOD(OBJECT_PARENT_CLASS_STR(_thisObject), methodNameStr) } else { nil })
// 	// #define GET_METHOD_STATIC(classNameStr, methodNameStr) 				(if ([classNameStr, methodNameStr, __FILE__, __LINE__] call OOP_assert_method_static_call) then { GET_METHOD(classNameStr, methodNameStr) } else { nil })
// 	// #define GET_METHOD_CLASS(classNameStr, objNameStr, methodNameStr) 	(if ([classNameStr, objNameStr, methodNameStr, __FILE__, __LINE__] call OOP_assert_method_class_call) then { GET_METHOD(classNameStr, methodNameStr) } else { nil })
// 	// #define GET_METHOD_THIS_CLASS(classNameStr, methodNameStr) 			(if ([classNameStr, methodNameStr, __FILE__, __LINE__] call OOP_assert_method_this_class_call) then { GET_METHOD(classNameStr, methodNameStr) } else { nil })
// #else
#define GET_METHOD_STD(objNameStr, methodNameStr) 					GET_METHOD_OBJ(OBJECT_PARENT_CLASS_STR(objNameStr), methodNameStr, objNameStr)
#define GET_METHOD_THIS(methodNameStr) 								GET_METHOD_OBJ(OBJECT_PARENT_CLASS_STR(_thisObject), methodNameStr, _thisObject)
#define GET_METHOD_STATIC(classNameStr, methodNameStr) 				GET_METHOD(classNameStr, methodNameStr)
#define GET_METHOD_CLASS(classNameStr, objNameStr, methodNameStr) 	GET_METHOD_OBJ(classNameStr, methodNameStr, objNameStr)
#define GET_METHOD_THIS_CLASS(classNameStr, methodNameStr) 			GET_METHOD_OBJ(classNameStr, methodNameStr, _thisObject)
//#endif

// Standard call
#define CALLM(objNameStr, methodNameStr, extraParams) 			(([objNameStr] + extraParams) call GET_METHOD_STD(objNameStr, methodNameStr))
#define CALLM0(objNameStr, methodNameStr) 						([objNameStr] call GET_METHOD_STD(objNameStr, methodNameStr))
#define CALLM1(objNameStr, methodNameStr, a) 					([objNameStr, a] call GET_METHOD_STD(objNameStr, methodNameStr))
#define CALLM2(objNameStr, methodNameStr, a, b) 				([objNameStr, a, b] call GET_METHOD_STD(objNameStr, methodNameStr))
#define CALLM3(objNameStr, methodNameStr, a, b, c) 				([objNameStr, a, b, c] call GET_METHOD_STD(objNameStr, methodNameStr))
#define CALLM4(objNameStr, methodNameStr, a, b, c, d) 			([objNameStr, a, b, c, d] call GET_METHOD_STD(objNameStr, methodNameStr))

// This call
#define T_CALLM(methodNameStr, extraParams) 					(([_thisObject] + extraParams) call GET_METHOD_THIS(methodNameStr))
#define T_CALLM0(methodNameStr) 								([_thisObject] call GET_METHOD_THIS(methodNameStr))
#define T_CALLM1(methodNameStr, a) 								([_thisObject, a] call GET_METHOD_THIS(methodNameStr))
#define T_CALLM2(methodNameStr, a, b) 							([_thisObject, a, b] call GET_METHOD_THIS(methodNameStr))
#define T_CALLM3(methodNameStr, a, b, c) 						([_thisObject, a, b, c] call GET_METHOD_THIS(methodNameStr))
#define T_CALLM4(methodNameStr, a, b, c, d) 					([_thisObject, a, b, c, d] call GET_METHOD_THIS(methodNameStr))

// Static call
#define CALLSM(classNameStr, methodNameStr, extraParams) 		(([classNameStr] + extraParams) call GET_METHOD_STATIC(classNameStr, methodNameStr))
#define CALLSM0(classNameStr, methodNameStr)					([classNameStr] call GET_METHOD_STATIC(classNameStr, methodNameStr))
#define CALLSM1(classNameStr, methodNameStr, a) 				(([classNameStr, a]) call GET_METHOD_STATIC(classNameStr, methodNameStr))
#define CALLSM2(classNameStr, methodNameStr, a, b) 				(([classNameStr, a, b]) call GET_METHOD_STATIC(classNameStr, methodNameStr))
#define CALLSM3(classNameStr, methodNameStr, a, b, c) 			(([classNameStr, a, b, c]) call GET_METHOD_STATIC(classNameStr, methodNameStr))
#define CALLSM4(classNameStr, methodNameStr, a, b, c, d) 		(([classNameStr, a, b, c, d]) call GET_METHOD_STATIC(classNameStr, methodNameStr))

// Call class method (used for calling base class usually)
#define CALLCM(classNameStr, objNameStr, methodNameStr, extraParams) (([objNameStr] + extraParams) call GET_METHOD_CLASS(classNameStr, objNameStr, methodNameStr))

// Call an overidden method from the overriding method.
#define T_CALLCM(classNameStr, methodNameStr, extraParams) 		([_thisObject]+extraParams 		call GET_METHOD_THIS_CLASS(classNameStr, methodNameStr))
#define T_CALLCM0(classNameStr, methodNameStr) 					([_thisObject] 					call GET_METHOD_THIS_CLASS(classNameStr, methodNameStr))
#define T_CALLCM1(classNameStr, methodNameStr, a) 				([_thisObject, a] 				call GET_METHOD_THIS_CLASS(classNameStr, methodNameStr))
#define T_CALLCM2(classNameStr, methodNameStr, a, b) 			([_thisObject, a, b] 			call GET_METHOD_THIS_CLASS(classNameStr, methodNameStr))
#define T_CALLCM3(classNameStr, methodNameStr, a, b, c) 		([_thisObject, a, b, c] 		call GET_METHOD_THIS_CLASS(classNameStr, methodNameStr))
#define T_CALLCM4(classNameStr, methodNameStr, a, b, c, d) 		([_thisObject, a, b, c, d] 		call GET_METHOD_THIS_CLASS(classNameStr, methodNameStr))
#define T_CALLCM5(classNameStr, methodNameStr, a, b, c, d, e) 	([_thisObject, a, b, c, d, e] 	call GET_METHOD_THIS_CLASS(classNameStr, methodNameStr))

// Remote executions
#define REMOTE_EXEC_METHOD(objNameStr, methodNameStr, extraParams, targets) [objNameStr, methodNameStr, extraParams] remoteExec ["OOP_callFromRemote", targets, false]
#define REMOTE_EXEC_CALL_METHOD(objNameStr, methodNameStr, extraParams, targets) [objNameStr, methodNameStr, extraParams] remoteExecCall ["OOP_callFromRemote", targets, false]

#ifdef OOP_ASSERT
#define REMOTE_EXEC_STATIC_METHOD(classNameStr, methodNameStr, extraParams, targets, JIP) [classNameStr, methodNameStr, extraParams] remoteExec ["OOP_callStaticMethodFromRemote", targets, JIP];
#define REMOTE_EXEC_CALL_STATIC_METHOD(classNameStr, methodNameStr, extraParams, targets, JIP) [classNameStr, methodNameStr, extraParams] remoteExecCall ["OOP_callStaticMethodFromRemote", targets, JIP];
#else
#define REMOTE_EXEC_STATIC_METHOD(classNameStr, methodNameStr, extraParams, targets, JIP) ([classNameStr] + extraParams) remoteExec [CLASS_METHOD_NAME_STR(classNameStr, methodNameStr), targets, JIP];
#define REMOTE_EXEC_CALL_STATIC_METHOD(classNameStr, methodNameStr, extraParams, targets, JIP) ([classNameStr] + extraParams) remoteExecCall [CLASS_METHOD_NAME_STR(classNameStr, methodNameStr), targets, JIP];
#endif

#ifdef _SQF_VM
#define CLEAR_REMOTE_EXEC_JIP(JIP)
#else
#define CLEAR_REMOTE_EXEC_JIP(JIP) remoteExec ["", JIP]
#endif

// ----------------------------------------
// |         A T T R I B U T E S          |
// ----------------------------------------

#define ATTR_REFCOUNTED		1
#define ATTR_SERIALIZABLE	2
#define ATTR_PRIVATE		3

// Needs more work to implement this (walking classes to find the first place a member was defined etc.)
// #define ATTR_PROTECTED 4
#define ATTR_GET_ONLY 5
#define ATTR_THREAD_AFFINITY_ID 6
#define ATTR_THREAD_AFFINITY(getThreadFn) [ATTR_THREAD_AFFINITY_ID, getThreadFn]

// For serialization when saving
#define ATTR_SAVE			7
#define ATTR_SAVE_VER(ver)	[7,ver]
// #define ATTR_DEFAULT_KEY	8
// #define ATTR_DEFAULT(val)	[8,val]

#define ATTR_USERBASE 1000

// -----------------------------------------------------
// |       M E M B E R   D E C L A R A T I O N S       |
// -----------------------------------------------------

#define VARIABLE(varNameStr) VARIABLE_ATTR(varNameStr, [])
#define STATIC_VARIABLE(varNameStr) STATIC_VARIABLE_ATTR(varNameStr, [])

#ifdef OOP_ASSERT
#define VARIABLE_ATTR(varNameStr, attributes) \
	if(!((varNameStr) in [OOP_PARENT_STR, OOP_PUBLIC_STR]) && (_oop_memList findIf { (_x select 0) isEqualTo (varNameStr) } != NOT_FOUND)) then { \
		OOP_ERROR_2("Class %1 is hiding variable '%2' in parent", _oop_classNameStr, varNameStr); \
	}; \
	_oop_memList pushBackUnique [varNameStr, attributes]
#define STATIC_VARIABLE_ATTR(varNameStr, attributes) \
	if(_oop_staticMemList findIf { (_x select 0) isEqualTo (varNameStr) } != NOT_FOUND) then { \
		OOP_ERROR_2("Class %1 is hiding static variable '%2' in parent", _oop_classNameStr, varNameStr); \
	}; \
	_oop_staticMemList pushBackUnique [varNameStr, attributes]
#else
#define VARIABLE_ATTR(varNameStr, attributes) _oop_memList pushBackUnique [varNameStr, attributes]
#define STATIC_VARIABLE_ATTR(varNameStr, attributes) _oop_staticMemList pushBackUnique [varNameStr, attributes]
#endif

// -----------------------------------------------------
// |                 P R O F I L I N G                 |
// -----------------------------------------------------

#ifdef OOP_ASSERT
	#define OOP_ASSERT_BOOL true
#else
	#define OOP_ASSERT_BOOL false
#endif

#ifdef OOP_PROFILE
	#define _OOP_FUNCTION_WRAPPERS

	#define PROFILE_SCOPE_START(scopeName) \
		private _profileTStart##scopeName = diag_tickTime; \
		private _extraProfileFields = [];

	#define PROFILE_SCOPE_END(scopeName, minT) \
		private _totalProfileT##scopeName = diag_tickTime - _profileTStart##scopeName; \
		if(_totalProfileT##scopeName > minT) then { \
			private _str = format ["{ ""profile"": { ""scope"": ""%1"", ""time"": %2 }}", #scopeName, _totalProfileT##scopeName]; \
			OOP_PROFILE_0(_str); \
		};

	#define OOP_FUNC_HEADER_PROFILE \
		private _profileTStart = diag_tickTime; \
		private _class = if(isNil "_thisClass") then { if(isNil "_thisObject") then { "(unknown)" } else { OBJECT_PARENT_CLASS_STR(_thisObject) } } else { _thisClass }; \
		private _profileTag = if(_class != "(unknown)") then { _GETSV(_class, "profile__tag") } else { "" }; \
		private _scopeKey = if(isNil "_profileTag" or isNil "_thisObject") then { \
			_class \
		} else { \
			if(_profileTag == "" or isNil "_thisObject") then { _objOrClass } else { GETV(_thisObject, _profileTag) } \
		}; \
		private _class1 = OBJECT_PARENT_CLASS_STR(_thisObject); \
		private _scopeKey = _class1; \
		private _extraProfileFields = [];

	#define OOP_FUNC_HEADER_PROFILE_STATIC \
		private _profileTStart = diag_tickTime; \
		private _class1 = _thisClass; \
		private _scopeKey = _class1; \
		private _extraProfileFields = [];

	#define OOP_FUNC_FOOTER_PROFILE \
		private _totalProfileT = diag_tickTime - _profileTStart; \
		if(_totalProfileT > OOP_PROFILE_MIN_T) then { \
			private _extraFieldsObj = ""; \
			if(count _extraProfileFields > 0) then { \
				{ \
					_x params ["_fieldName", "_fieldVal"]; \
					if(_extraFieldsObj != "") then { _extraFieldsObj = _extraFieldsObj + "," }; \
					if(_fieldVal isEqualType "") then {	 \
						_extraFieldsObj = _extraFieldsObj + (format [ """%1"": ""%2""", _fieldName, _fieldVal ]); \
					} else { \
						_extraFieldsObj = _extraFieldsObj + (format [ """%1"": %2", _fieldName, _fieldVal ]); \
					}; \
				} forEach _extraProfileFields; \
				_extraFieldsObj = ", ""extra"": { " + _extraFieldsObj + " }"; \
			}; \
			private _str = format ["{ ""profile"": { ""class"": ""%1"", ""method"": ""%2"", ""scope"": ""%5.%2"", ""time"": %3, ""object_or_class"": ""%4"", ""oop_assert"": %7%6 }}", _class1, _methodNameStr, _totalProfileT, _objOrClass, _scopeKey, _extraFieldsObj, OOP_ASSERT_BOOL]; \
			OOP_PROFILE_0(_str); \
		}
	
	#define PROFILE_ADD_EXTRA_FIELD(fieldName, fieldVal) _extraProfileFields pushBack [fieldName, fieldVal]
#else
	#define PROFILE_SCOPE_START(scopeName)
	#define PROFILE_SCOPE_END(scopeName, minT)
	#define PROFILE_ADD_EXTRA_FIELD(fieldName, fieldVal)
	#define OOP_FUNC_HEADER_PROFILE
	#define OOP_FUNC_HEADER_PROFILE_STATIC
	#define OOP_FUNC_FOOTER_PROFILE
#endif

// Enable function wrappers if access assertions are enabled
#ifdef OOP_ASSERT_ACCESS
#define _OOP_FUNCTION_WRAPPERS
#endif

#ifdef OOP_ASSERT_METHOD_CALL
#define _OOP_FUNCTION_WRAPPERS
#define OOP_METHOD_CALL_ASSERT_HEADER private __classScope = QUOTE(OOP_CLASS_NAME)
#else
#define OOP_METHOD_CALL_ASSERT_HEADER
#endif

// Enable function wrappers if access assertions are enabled
#ifdef OOP_TRACE_FUNCTIONS
#define OOP_DEBUG
#define _OOP_FUNCTION_WRAPPERS
#define OOP_TRACE_ENTER_FUNCTION OOP_DEBUG_MSG("> enter function %1", [_this])
#define OOP_TRACE_EXIT_FUNCTION OOP_DEBUG_MSG("< exit function", [])
#else
#define OOP_TRACE_ENTER_FUNCTION 
#define OOP_TRACE_EXIT_FUNCTION 
#endif

#ifdef OOP_DEBUG_CLASS_DEF
#define LOG_CLASS_BEGIN(class, base)	diag_log format ["CLASS %1 : %2", class, base]
#define LOG_METHOD(method)				diag_log format ["  METHOD %1", method]
#define LOG_CLASS_END(class)			diag_log format ["ENDCLASS %1", class]
#else
#define LOG_METHOD(method)
#define LOG_CLASS_BEGIN(class, base)
#define LOG_CLASS_END(class)
#endif

// -----------------------------------------------------
// |                   M E T H O D S                   |
// -----------------------------------------------------

// If some enabled functionality requires function wrappers we set them here. If you want to conditionally add more stuff to the wrapped functions
// (e.g. additional asserts, parameter manipulation etc.) then define them as macros and then include them in the wrapped blocks in the same manner
// that OOP_PROFILE does.

// OOP_assert_standard_call = {
// 	params ["_obj", "_fn"];
// 	private _attributes = missionNamespace getVariable [CLASS_METHOD_ATTR_STR(OBJECT_PARENT_CLASS_STR(_obj), _fn), []];
// 	ASSERT_MSG("public" in attributes, "Cannot call function outside of class methods");
// 	ASSERT_MSG(isServer || !("server" in attributes), "Can only call function on server");
// 	// etc...
// };
// #define CALLM0(obj, fn) ([obj, QUOTE(fn)] call OOP_assert_standard_call; CALLM0(obj, fn))
// #define T_CALLM0(fn) ([_thisObject, QUOTE(fn)] call OOP_assert_this_call; CALLM0(_thisObject, fn))

#ifdef _OOP_FUNCTION_WRAPPERS
	#define METHOD(methodNameStr) \
		+[] call { [_oop_classNameStr, QUOTE(methodNameStr), _this] call OOP_set_method_attr }; \
		LOG_METHOD(QUOTE(methodNameStr)); \
		_oop_methodList pushBackUnique QUOTE(methodNameStr);  \
		_oop_newMethodList pushBackUnique QUOTE(methodNameStr); \
		missionNamespace setVariable [CLASS_METHOD_NAME_STR(_oop_classNameStr, QUOTE(methodNameStr)), { \
			private _thisClass = nil; \
			private _thisObject = _this select 0; \
			private _methodNameStr = QUOTE(methodNameStr); \
			private _objOrClass = _this select 0; \
			OOP_METHOD_CALL_ASSERT_HEADER; \
			OOP_FUNC_HEADER_PROFILE; \
			OOP_TRACE_ENTER_FUNCTION; \
			private _result = ([0] apply { _this call { \
			ASP_CREATE_PROFILE_SCOPE(OOP_CLASS_NAME,methodNameStr)

	#define ENDMETHOD }}) select 0;\
			OOP_TRACE_EXIT_FUNCTION; \
			OOP_FUNC_FOOTER_PROFILE; \
			if !(isNil "_result") then { _result } else { nil } \
		} ]

	#define METHOD_FILE(methodNameStr, path) \
		+[] call { [_oop_classNameStr, QUOTE(methodNameStr), _this] call OOP_set_method_attr }; \
		LOG_METHOD(QUOTE(methodNameStr)); \
		_oop_methodList pushBackUnique QUOTE(methodNameStr); \
		_oop_newMethodList pushBackUnique QUOTE(methodNameStr); \
		missionNamespace setVariable [CLASS_METHOD_NAME_STR(_oop_classNameStr, INNER_METHOD_NAME_STR(QUOTE(methodNameStr))), compile preprocessFileLineNumbers path]; \
		missionNamespace setVariable [CLASS_METHOD_NAME_STR(_oop_classNameStr, QUOTE(methodNameStr)), { \
			private _thisClass = nil; \
			private _thisObject = _this select 0; \
			private _methodNameStr = QUOTE(methodNameStr); \
			private _objOrClass = _this select 0; \
			OOP_METHOD_CALL_ASSERT_HEADER; \
			OOP_FUNC_HEADER_PROFILE; \
			OOP_TRACE_ENTER_FUNCTION; \
			private _fn = missionNamespace getVariable CLASS_METHOD_NAME_STR(OBJECT_PARENT_CLASS_STR(_objOrClass), INNER_METHOD_NAME_STR(QUOTE(methodNameStr))); \
			private _result = ([0] apply { _this call _fn }) select 0; \
			OOP_TRACE_EXIT_FUNCTION; \
			OOP_FUNC_FOOTER_PROFILE; \
			if !(isNil "_result") then { _result } else { nil } \
		}]

	#define STATIC_METHOD(methodNameStr) \
		+[] call { [_oop_classNameStr, QUOTE(methodNameStr), _this, true] call OOP_set_method_attr }; \
		LOG_METHOD(QUOTE(methodNameStr)); \
		_oop_methodList pushBackUnique QUOTE(methodNameStr); \
		_oop_newMethodList pushBackUnique QUOTE(methodNameStr); \
		missionNamespace setVariable [CLASS_METHOD_NAME_STR(_oop_classNameStr, QUOTE(methodNameStr)), { \
			private _thisObject = nil; \
			private _thisClass = _this select 0; \
			private _methodNameStr = QUOTE(methodNameStr); \
			private _objOrClass = _this select 0; \
			OOP_METHOD_CALL_ASSERT_HEADER; \
			OOP_FUNC_HEADER_PROFILE_STATIC; \
			OOP_TRACE_ENTER_FUNCTION; \
			private _result = ([0] apply { _this call {

	#define STATIC_METHOD_FILE(methodNameStr, path) \
		+[] call { [_oop_classNameStr, QUOTE(methodNameStr), _this, true] call OOP_set_method_attr }; \
		LOG_METHOD(QUOTE(methodNameStr)); \
		_oop_methodList pushBackUnique QUOTE(methodNameStr); \
		_oop_newMethodList pushBackUnique QUOTE(methodNameStr); \
		missionNamespace setVariable [CLASS_METHOD_NAME_STR(_oop_classNameStr, INNER_METHOD_NAME_STR(QUOTE(methodNameStr))), compile preprocessFileLineNumbers path]; \
		missionNamespace setVariable [CLASS_METHOD_NAME_STR(_oop_classNameStr, QUOTE(methodNameStr)), { \
			private _thisObject = nil; \
			private _thisClass = _this select 0; \
			private _methodNameStr = QUOTE(methodNameStr); \
			private _objOrClass = _this select 0; \
			OOP_METHOD_CALL_ASSERT_HEADER; \
			OOP_FUNC_HEADER_PROFILE_STATIC; \
			OOP_TRACE_ENTER_FUNCTION; \
			private _fn = missionNamespace getVariable CLASS_METHOD_NAME_STR(_objOrClass, INNER_METHOD_NAME_STR(QUOTE(methodNameStr))); \
			private _result = ([0] apply { _this call _fn}) select 0; \
			OOP_TRACE_EXIT_FUNCTION; \
			OOP_FUNC_FOOTER_PROFILE; \
			if !(isNil "_result") then { _result } else { nil } \
		}]
#else
	#define METHOD(methodNameStr) \
		+[] call { [_oop_classNameStr, QUOTE(methodNameStr), _this] call OOP_set_method_attr }; \
		LOG_METHOD(QUOTE(methodNameStr)); \
		_oop_methodList pushBackUnique QUOTE(methodNameStr); \
		_oop_newMethodList pushBackUnique QUOTE(methodNameStr); \
		missionNamespace setVariable [CLASS_METHOD_NAME_STR(_oop_classNameStr, QUOTE(methodNameStr)), { \
		ASP_CREATE_PROFILE_SCOPE(OOP_CLASS_NAME,methodNameStr)

	#define ENDMETHOD }]

	#define METHOD_FILE(methodNameStr, path) \
		+[] call { [_oop_classNameStr, QUOTE(methodNameStr), _this] call OOP_set_method_attr }; \
		LOG_METHOD(QUOTE(methodNameStr)); \
		_oop_methodList pushBackUnique QUOTE(methodNameStr); \
		_oop_newMethodList pushBackUnique QUOTE(methodNameStr); \
		missionNamespace setVariable [CLASS_METHOD_NAME_STR(_oop_classNameStr, QUOTE(methodNameStr)), compile preprocessFileLineNumbers path]

	#define STATIC_METHOD(methodNameStr) \
		+[] call { [_oop_classNameStr, QUOTE(methodNameStr), _this, true] call OOP_set_method_attr }; \
		LOG_METHOD(QUOTE(methodNameStr)); \
		_oop_methodList pushBackUnique QUOTE(methodNameStr); \
		_oop_newMethodList pushBackUnique QUOTE(methodNameStr); \
		missionNamespace setVariable [CLASS_METHOD_NAME_STR(_oop_classNameStr, QUOTE(methodNameStr)), { \
		ASP_CREATE_PROFILE_SCOPE(OOP_CLASS_NAME,methodNameStr)

	#define STATIC_METHOD_FILE(methodNameStr, path) \
		+[] call { [_oop_classNameStr, QUOTE(methodNameStr), _this, true] call OOP_set_method_attr }; \
		LOG_METHOD(QUOTE(methodNameStr)); \
		_oop_methodList pushBackUnique QUOTE(methodNameStr); \
		_oop_newMethodList pushBackUnique QUOTE(methodNameStr); \
		missionNamespace setVariable [CLASS_METHOD_NAME_STR(_oop_classNameStr, QUOTE(methodNameStr)), compile preprocessFileLineNumbers path]
#endif

// --------------------------------------------------------
// |              C L A S S   C O U N T E R               |
// --------------------------------------------------------
// Every object has a unique ID, and a specific class counter implementation might be different


// Initial value when class is initialized
#define OOP_ID_COUNTER_NEW [0]
// Increases the value and returns a new value
#define OOP_ID_COUNTER_PLUS_ONE(value) (value call { \
	private _this = +_this; \
	private _c = count _this; \
	private _nfound = true; \
	for "_i" from 0 to (_c-1) do { \
		private _num = _this select _i; \
		if (_num < 999999) exitWith { \
			_this set [_i, _num + 1]; \
			_nfound = false; \
		}; \
		_this set [_i, 0]; \
	}; \
	if (_nfound) then {	_this pushBack 1; }; \
	_this \
})

/*
// Plain numeric counters
#define OOP_ID_COUNTER_NEW 0
// Increases the value and returns a new value
#define OOP_ID_COUNTER_PLUS_ONE(value) (value + 1)
*/

// ----------------------------------------
// |              C L A S S               |
// ----------------------------------------

// /*
//  * Technical info:
//  * First we initialize special members of the class, then we initialize new, delete and copy methods.
//  * The name of this class is added to the hierarchy of its base class, if it's not "".
//  * The methods of base class are copied to the methods of the derived class, except for "new" and "delete", because they will be called through the hierarchy anyway.
//  */

#define CLASS(classNameStr, baseClassNames) \
	if (QUOTE(OOP_CLASS_NAME) == QUOTE(OOP_DEFAULT_CLASS_NAME)) then { diag_log format ["[OOP] Error: class %1 has no macro OOP_CLASS_NAME defined!", classNameStr]; }; \
	LOG_CLASS_BEGIN(class, base); \
	call { \
		private _oop_classNameStr = classNameStr; \
		([_oop_classNameStr, baseClassNames] call OOP_init_class) params ["_oop_memList", "_oop_staticMemList", "_oop_methodList", "_oop_newMethodList"]; \
		PROFILER_COUNTER_INIT(_oop_classNameStr); \
		METHOD(new) ENDMETHOD; \
		METHOD(delete) ENDMETHOD; \
		METHOD(copy) _this call OOP_clone_default ENDMETHOD; \
		METHOD(assign) _this call OOP_assign_default ENDMETHOD; \
		VARIABLE(OOP_PARENT_STR); \
		VARIABLE(OOP_PUBLIC_STR);


// ----------------------------------------
// |           E N D C L A S S            |
// ----------------------------------------

// /*
//  * Technical info:
//  * It just terminates the call block of the CLASS
//  * Also it calculates an array with serializable members
//  */

#define ENDCLASS  \
		LOG_CLASS_END(_oop_classNameStr); \
		private _serialVariables = _GET_SPECIAL_MEM(_oop_classNameStr, MEM_LIST_STR); \
		_serialVariables = _serialVariables select { \
			_x params ["_varName", "_attributes"]; \
			ATTR_SERIALIZABLE in _attributes \
		}; \
		_SET_SPECIAL_MEM(_oop_classNameStr, SERIAL_MEM_LIST_STR, _serialVariables); \
	}

// ----------------------------------------------------------------------
// |        C O N S T R U C T O R  O F   E X I S T I N G   O B J E C T  |
// ----------------------------------------------------------------------

// /*
//  * Technical info:
//  * Creates an object with given name, doesn't call its constructor.
//  */

#define NEW_EXISTING(classNameStr, objNameStr) [] call { \
_SETV(objNameStr, OOP_PARENT_STR, classNameStr); \
objNameStr \
}

#define NEW_PUBLIC_EXISTING(classNameStr, objNameStr) [] call { \
_SETV(objNameStr, OOP_PARENT_STR, classNameStr); \
_SETV(objNameStr, OOP_PUBLIC_STR, 1); \
PUBLIC_VAR(objNameStr, OOP_PUBLIC_STR); \
PUBLIC_VAR(objNameStr, OOP_PARENT_STR); \
objNameStr \
}

// ----------------------------------------
// |        C O N S T R U C T O R         |
// ----------------------------------------

// /*
//  * Technical info:
//  * Check the class name if needed.
//  * Increase the object counter for this class.
//  * Call all constructors of the base classes from base to derived classes.
//  */

#ifdef OOP_ASSERT
#define CONSTRUCTOR_ASSERT_CLASS(classNameStr) if (!([classNameStr, __FILE__, __LINE__] call OOP_assert_class)) exitWith {format ["ERROR_NO_CLASS_%1", classNameStr]};
#else
#define CONSTRUCTOR_ASSERT_CLASS(classNameStr)
#endif

#define NEW(classNameStr, extraParams) ([classNameStr, extraParams] call OOP_new)

// -----------------------------------------------------------------------
// |        C O N S T R U C T O R  O F  P U B L I C   O B J E C T        |
// -----------------------------------------------------------------------

// /*
//  * Creates a 'public' object that will also exist across other computers in multiplayer.
//  * Same as constructor, but also marks the object as public with a OOP_PUBLIC_STR variable.
//  * It also transmits oop_parent and oop_public variables with publicVariable.
//  * It doesn't mean the object's variables will be streamed across MP network, you still need to do it yourself.
//  */

#define NEW_PUBLIC(classNameStr, extraParams) ([classNameStr, extraParams] call OOP_new_public) 

// ----------------------------------------
// |         D E S T R U C T O R          |
// ----------------------------------------

// /*
//  * Technical info:
//  * Check object validity if needed.
//  * Call all destructors of the base classes from derived classes to base classes.
//  * Clean (set to nil) all members of this object.
//  * If the object was global, also broadcast this.
//  */

#ifdef OOP_ASSERT
#define DESTRUCTOR_ASSERT_OBJECT(objNameStr) if (!([objNameStr, __FILE__, __LINE__] call OOP_assert_object)) exitWith {};
#else
#define DESTRUCTOR_ASSERT_OBJECT(objNameStr)
#endif

#define DELETE(objNameStr) ([objNameStr] call OOP_delete)

// ----------------------------------------
// |              C L O N E               |
// ----------------------------------------

#define CLONE(objNameStr) ([objNameStr] call OOP_clone)

// ----------------------------------------
// |             A S S I G N              |
// ----------------------------------------

#define ASSIGN(destObjNameStr, srcObjNameStr) CALLM(destObjNameStr, "assign", [srcObjNameStr])

// ----------------------------------------
// |             U P D A T E              |
// ----------------------------------------
// Same as assign but copies only existing variables of an object (those that are not nil)
#define UPDATE(destObjNameStr, srcObjNameStr) [destObjNameStr, srcObjNameStr, false] call OOP_assign_default;

// ----------------------------------------
// |    U P D A T E   V I A   A T T R     |
// ----------------------------------------
// Same as update but filters by specified attribute (e.g. ATTR_SERIALIZABLE)
#define UPDATE_VIA_ATTR(destObjNameStr, srcObjNameStr, attr) [destObjNameStr, srcObjNameStr, false, attr] call OOP_assign_default;

// ----------------------------------------
// |          S E R I A L I Z E           |
// ----------------------------------------
// Packs variables into an array and returns the array
#define SERIALIZE(objNameStr) ([objNameStr] call OOP_serialize)
#define SERIALIZED_CLASS_NAME(array) (array select 0)
#define SERIALIZED_OBJECT_NAME(array) (array select 1)
#define SERIALIZED_SET_OBJECT_NAME(array, name) array set [1, name]

// Serialize all variables which have a specified attributes
#define SERIALIZE_ATTR(objNameStr, attr) ([objNameStr, attr] call OOP_serialize_attr)
#define SERIALIZE_SAVE(objNameStr) ([objNameStr] call OOP_serialize_save)

// Serialize all variables regardless of their attributes
#define SERIALIZE_ALL(objNameStr) ([objNameStr, 0, true] call OOP_serialize_attr)

// ----------------------------------------
// |        D E S E R I A L I Z E         |
// ----------------------------------------
// Returns ref to the object passed in the array
// Object must exist before you can DESERIALIZE an array into it!
#define DESERIALIZE(objNameStr, array) ([objNameStr, array] call OOP_deserialize)
#define DESERIALIZE_ATTR(objNameStr, array, attr) ([objNameStr, array, attr] call OOP_deserialize_attr)
#define DESERIALIZE_ALL(objNameStr, array) ([objNameStr, array, 0, true] call OOP_deserialize_attr)
#define DESERIALIZE_SAVE(objNameStr, array) ([objNameStr, array] call OOP_deserialize_save)
#define DESERIALIZE_SAVE_VER(objNameStr, array, version) ([objNameStr, array, version] call OOP_deserialize_save)

// ---------------------------------------------
// |         R E F   C O U N T I N G           |
// ---------------------------------------------

#ifdef OOP_LOG_REF_UNREF

#define REF(objNameStr) CALLM0(objNameStr, "ref"); \
diag_log format ["[REF/UNREF]: REF: %1, %2, %3", objNameStr, __FILE__, __LINE__]

#define UNREF(objNameStr) CALLM0(objNameStr, "unref"); \
diag_log format ["[REF/UNREF]: UNREF: %1, %2, %3", objNameStr, __FILE__, __LINE__]

#else
#define REF(objNameStr) CALLM0(objNameStr, "ref")
#define UNREF(objNameStr) CALLM0(objNameStr, "unref")
#endif

// ----------------------------------------------------------------------
// |                A S S E R T I O N S  A N D   C H E C K S            |
// ----------------------------------------------------------------------
// ASSERT_OBJECT_CLASS(objNameStr, classNameStr)
// Exits current scope if provided object's class doesn't match specified class
#ifdef OOP_ASSERT
	#define ASSERT_OBJECT(objNameStr) ([objNameStr, __FILE__, __LINE__] call OOP_assert_object)
	#define ASSERT_OBJECT_CLASS(objNameStr, classNameStr) ([objNameStr, classNameStr, __FILE__, __LINE__] call OOP_assert_objectClass)
	#define ASSERT_MSG(condition, msg) \
		if (!(condition)) then { \
			private _str = str({ condition; }); \
			OOP_ERROR_2("Assertion failed: %2", _str, msg); \
			DUMP_CALLSTACK; \
			throw [__FILE__, __LINE__, msg]; \
		}
	#define ASSERT(condition) \
		if (!(condition)) then { \
			private _str = str({ condition; }); \
			OOP_ERROR_1("Assertion failed (%1)", _str); \
			DUMP_CALLSTACK; \
			throw [__FILE__, __LINE__, msg]; \
		}
	#define FAILURE(msg) \
		OOP_ERROR_1("Failure: %1", msg); \
		DUMP_CALLSTACK; \
		throw [__FILE__, __LINE__, msg]
#else
	#define ASSERT_OBJECT(object)
	#define ASSERT_OBJECT_CLASS(objNameStr, classNameStr)
	#define ASSERT_MSG(condition, msg)
	#define ASSERT(condition)
	#define FAILURE(msg)
#endif

// Returns true if given object is public, i.e. was created with NEW_PUBLIC
#define IS_PUBLIC(objNameStr) (! (isNil {GETV(objNameStr, OOP_PUBLIC_STR)} ) )


// ----------------------------------------------------
// |     O B J E C T   T Y P E                        |
// |     N U L L   O B J E C T                        |
// ----------------------------------------------------

// Is the object handle valid?
//#define NOT_NULL_OBJECT(object) ((object isEqualType "") and {!(object isEqualTo "")})
#define IS_NULL_OBJECT(object) (object isEqualTo "")

// Value to assign to an object handle to indicate it is deliberately invalid.
#define NULL_OBJECT ""

#define OOP_OBJECT_TYPE ""

// Logging macros - must be inserted here
#include "OOP_Log.h"

// Log which flags are enabled which can affect performance
/*
#ifdef OOP_TRACE_FUNCTIONS
diag_log "[OOP] Warning: OOP_TRACE_FUNCTIONS is enabled";
#endif

#ifdef OOP_PROFILE
diag_log "[OOP] Warning: OOP_PROFILE is enabled";
#endif

#ifdef _OOP_FUNCTION_WRAPPERS
diag_log "[OOP] Warning: _OOP_FUNCTION_WRAPPERS is enabled";
#endif

#ifdef OOP_ASSERT
diag_log "[OOP] Warning: OOP_ASSERT is enabled";
#endif

#ifdef OOP_ASSERT_ACCESS
diag_log "[OOP] Warning: OOP_ASSERT_ACCESS is enabled";
#endif
*/