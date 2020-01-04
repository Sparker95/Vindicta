
// Default oop config overrides.
// Nothing here cos we don't want to override any stuff by default!
// Undefine debug and info logging, leave warning and error logging.
//#undef OOP_DEBUG
//#undef OOP_INFO
//#undef OOP_WARNING
//#undef OOP_ERROR

// Undefine all asserts
// #undef OOP_ASSERT
#undef OOP_ASSERT_ACCESS

// Undefine Arma Debug Engine
//#undef ADE

// Undefine Arma Script Profiler
#undef ASP_ENABLE

// Undefine arma-ofstream
//#undef OFSTREAM_ENABLE
//#undef OFSTREAM_FILE

// Define a macro for this build config, use this to toggle specific behaviour elsewhere
//#define RELEASE_BUILD

// Accelerates virtual route speed
// Increases planning frequency, plans all action types on each iteration
//#define CMDR_AI_TESTING

// Disables planning for cmdr ai, in case we want to test something
//#define CMDR_AI_NO_PLAN

// Profiling
//#define OOP_PROFILE
// Don't set it above 0.002 or so! Or even above 0.004! diag_tickTime precision is only 0.001 and degrades as the game runs
#define OOP_PROFILE_MIN_T 0.002

// Various runtime OOP assertions (class existence, member variable existence, etc)
//#define OOP_ASSERT

// This is an interesting flag
// It disables GameMode init, GameManager init, for faster loading and testing
//#define GAME_MODE_DISABLE

// Defined only in this file
// Means that we are in the editor
#define EDITOR_PREVIEW

// ========= Release config ============
/*
// Undefine debug and info logging, leave warning and error logging.
#undef OOP_DEBUG
#undef OOP_INFO
//#undef OOP_WARNING
//#undef OOP_ERROR

// Undefine all asserts
#undef OOP_ASSERT
#undef OOP_ASSERT_ACCESS

// Undefine Arma Debug Engine
#undef ADE

// Undefine Arma Script Profiler
#undef ASP_ENABLE

// Undefine arma-ofstream
#undef OFSTREAM_ENABLE
#undef OFSTREAM_FILE

// Define a macro for this build config, use this to toggle specific behaviour elsewhere
#define RELEASE_BUILD
*/