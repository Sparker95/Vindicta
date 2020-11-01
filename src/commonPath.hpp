#include "config\pboVariant.hpp"

#define QUOTE(text) #text

// This header adds macro to resolve common path within the mission,
// Which can be configured differently depending if we are building a combined mission pbo
// Or separate mission pbo files

#ifdef PBO_VARIANT_STANDALONE_MISSION
#define COMMON_PATH(path) ("src\" + path)
#define __COMMON_PATH_NO_QUOTES(path) src\##path
#else
// vindicta_missions matches the prefix name of the pbo with combined missions
#define COMMON_PATH(path) ("vindicta_missions\src\" + path)
#define __COMMON_PATH_NO_QUOTES(path) vindicta_missions\src\##path
#endif

#define QUOTE_COMMON_PATH(path) QUOTE(__COMMON_PATH_NO_QUOTES(path))

#define CALL_COMPILE_COMMON(path) call compile preprocessFileLineNumbers COMMON_PATH(path)

#define COMPILE_COMMON(path) compile preprocessFileLineNumbers COMMON_PATH(path)