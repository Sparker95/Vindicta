// DEFAULT DEBUG CONFIG
// If you want to modify for yourself only then use user_local_config.hpp in this same directory (it will not be committed).

// Various runtime OOP assertions (class existence, member variable existence, etc)
#define OOP_ASSERT

// Undefine oop class member access violation asserts -- they are slow
#undef OOP_ASSERT_ACCESS

// Undefine Arma Script Profiler
#undef ASP_ENABLE

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

#include "user_local_config.hpp"