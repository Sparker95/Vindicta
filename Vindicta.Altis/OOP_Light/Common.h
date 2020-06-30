/*
Some generic macros
*/

// Wraps contents in quotes
#define QUOTE(smth) #smth

//Macro for global OOP variables
#define OOP_GVAR(var) o_##var
#define OOP_GVAR_STR(var) format["o_%1", #var]

// Unpacking a _thisObject variable into a private _variable
// So if we have private _var = GET_VAR(_thisObject, "var"), this macros can help
#define T_PRVAR(varName) private _##varName = GET_VAR(_thisObject, QUOTE(varName))

// Macro for global OOP variables
#define OOP_GVAR(var) o_##var
#define OOP_GVAR_STR(var) format["o_%1", #var]
// ---------------------------------------------------
// |         T H R E A D I N G    U T I L S          |
// ---------------------------------------------------

#define CRITICAL_SECTION isNil

// -----------------------------------------------------
// |       M E T H O D   P A R A M E T E R S           |
// -----------------------------------------------------

#define P_THISOBJECT ["_thisObject", ""]
#define P_THISCLASS ["_thisClass", ""]
#define P_STRING(paramNameStr) [paramNameStr, "", [""]]
#define P_STRING_DEFAULT(paramNameStr, defaultVal) [paramNameStr, defaultVal, [""]]
#define P_TEXT(paramNameStr) paramNameStr
#define P_OBJECT(paramNameStr) [paramNameStr, objNull, [objNull]]
#define P_GROUP(paramNameStr) [paramNameStr, grpNull, [grpNull]]
#define P_NUMBER(paramNameStr) [paramNameStr, 0, [0]]
#define P_NUMBER_DEFAULT(paramNameStr, defaultVal) [paramNameStr, defaultVal, [0]]
#define P_SIDE(paramNameStr) [paramNameStr, WEST, [WEST]]
#define P_BOOL(paramNameStr) [paramNameStr, false, [false]]
#define P_BOOL_DEFAULT_TRUE(paramNameStr) [paramNameStr, true, [true]]
#define P_ARRAY(paramNameStr) [paramNameStr, [], [[]]]
#define P_ARRAY_DEFAULT(paramNameStr, defaultVal) [paramNameStr, defaultVal, [[]]]
#define P_COLOR(paramNameStr) [paramNameStr, [1,1,1,1]]
#define P_POSITION(paramNameStr) [paramNameStr, [], [[]]]
#define P_CODE(paramNameStr) [paramNameStr, {}, [{}]]
#define P_DYNAMIC(paramNameStr) [paramNameStr, nil]
#define P_DYNAMIC_DEFAULT(paramNameStr, defaultVal) [paramNameStr, defaultVal]
#define P_CONTROL(paramNameStr) [paramNameStr, controlNull, [controlNull]]
#define P_DISPLAY(paramNameStr) [paramNameStr, displayNull, [displayNull]]

#define P_OOP_OBJECT(paramNameStr) P_STRING(paramNameStr)

// ----------------------------------------------------------------------
// |                               M I S C                              |
// ----------------------------------------------------------------------

// Can be used instead of , in macro
#define ARG ,

// Index find and findIf return when they don't find anything
#define NOT_FOUND -1

// For use with sort
#define ASCENDING true
#define DESCENDING false

// ----------------------------------------------------------------------
// |                            M A R K U P                             |
// ----------------------------------------------------------------------
// Use these to markup functions and variables to as documentation

// Can be used to mark a return statement, doesn't have any functionality
#define return 

// METHOD attributes
#define public 			+["public"]
#define protected 		+["protected"]
#define virtual 		+["virtual"]
#define override 		+["override"]
#define server 			+["server"]		// Only called on server
#define client 			+["client"]		// Only called on client
#define thread 			+["thread"]		// Only called in this objects thread
#define event 			//+["event"]		// Only called in event handlers
// This little macro just extracts the string from the attribute for use when searching the attribute array
#define attr(n) ((n) select 0)
// This macro suspends thread affinity asserts within the scope it is defined (and all child scopes)
#define SCOPE_IGNORE_THREAD_AFFINITY(class) private __ignoreThreadAffinity##class = true
#define SCOPE_IGNORE_ACCESS(class) private __ignoreAccess##class = true
#define SCOPE_ACCESS_MIMIC(classStr) __classScope = classStr