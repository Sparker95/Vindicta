//Sometimes we need to make sure some global objects exist which are needed for the work of another object
//That's why I made this macro
//Typically we use it in the constructor of an object

#define ASSERT_GLOBAL_OBJECT(objectStr) if (isNil #objectStr) exitWith { diag_log format ["[Global] Error: file: %1, line: %2, global object doesn't exist: %3", __FILE__, __LINE__, objectStr]; };