
// - - Colors - -
#define COLOR_ORANGE 		[1,0.64,0,1]
#define COLOR_ORANGE_HTML 	"#FFA300"
#define COLOR_WHITE 		[1,1,1,1]
#define COLOR_WHITE_HTML	"#FFFFFF"

// - - Global objects or variables - -
//Sometimes we need to make sure some global objects exist which are needed for the work of another object
//That's why I made this macro
//Typically we use it in the constructor of an object
#define ASSERT_GLOBAL_OBJECT(objectStr) if (isNil #objectStr) exitWith { diag_log format ["[Global] Error: file: %1, line: %2, global object doesn't exist: %3", __FILE__, __LINE__, #objectStr]; };

// Comment it out to disable these runtime assertions
// /*
// #define ASSERT_GLOBAL_VARIABLES
// 
// #ifdef ASSERT_GLOBAL_VARIABLES
// #define GLOB(var) (if (isNil #var) then { diag_log format ["Runtime error: %1 line %2: Global variable %3 is not defined!", __FILE__, __LINE__, #var]; nil } else {var})
// #else
// #define GLOB(var) var
// #endif
// 
// // Let's try use it just to verify stuff without assignments or calls or anything
// GLOB(myVarDoesNotExist);
// 
// // Let's try it with simple variables
// b = 4;
// _aNotDefined = GLOB(aNotDefined); // Should raise an error
// _bDefined = GLOB(b);
// diag_log format ["Undefined var value: %1", _aNotDefined];
// diag_log format ["Defined var value: %1", _bDefined];
// 
// // Let's try it with code variables (aka functions)
// fnc_mySquare = {_this*_this};
// 
// _d = 3 call GLOB(fnc_mySquare);
// diag_log format ["D value: %1", _d];
// _e = 4 call GLOB(fnc_myCube); // Should raise an error
// diag_log format ["E value: %1"];
// */
// 
// // Using this on left side will not work, probably will not even get compiled by arma!
// /*
// GLOB(c) = 33;
// diag_log format ["C value: %1", c];
// */