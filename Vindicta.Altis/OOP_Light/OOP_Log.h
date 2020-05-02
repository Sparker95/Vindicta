/*
Logging functionality
*/

// ----------------------------------------------------------------------
// |                   L O G G I N G   M A C R O S                      |
// ----------------------------------------------------------------------

#define LOG_SCOPE(logScopeName) private _oop_logScope = logScopeName
#define LOG_0 if((isNil "_thisObject")) then { if(!(isNil "_thisClass")) then {_thisClass} else { if(!(isNil "_oop_logScope")) then { _oop_logScope } else { "NoClass" }} } else { _thisObject }

#ifdef _OOP_FUNCTION_WRAPPERS
#define LOG_1 if (isNil "_methodNameStr") then {"fnc"} else {_methodNameStr}
#else
#define LOG_1 "fnc"
#endif

#ifdef ADE
#define DUMP_CALLSTACK ade_dumpCallstack
#define ADE_HALT halt
#define ADE_ASSERT assert 
#else
#define DUMP_CALLSTACK diag_log "callstack"
#define ADE_HALT diag_log "halt"
#define ADE_ASSERT
#endif

// If ofstream addon is globally enabled
#ifdef OFSTREAM_ENABLE

#define __OFSTREAM_OUT(fileName, text) ((ofstream_new (fileName)) ofstream_write(text))
#define WRITE_CRITICAL(text) ((ofstream_new "Critical.rpt") ofstream_write(text))

#else

#define __OFSTREAM_OUT(fileName, str) diag_log TEXT_ str
#define WRITE_CRITICAL(str)

#endif


#define _OFSTREAM_FILE OFSTREAM_FILE

#ifdef OFSTREAM_FILE
#define WRITE_LOG(msg) __OFSTREAM_OUT(OFSTREAM_FILE, msg)
#define WRITE_LOGF(file, msg) __OFSTREAM_OUT(file,  msg)
#else
#define WRITE_LOG(msg) diag_log TEXT_ msg
#define WRITE_LOGF(file, msg) diag_log TEXT_ msg
#endif

#ifdef OOP_PROFILE
#define OOP_PROFILE_MSG(str, a) private _o_str = format ["[%1.%2] PROFILE: %3",LOG_0, LOG_1, format ([str]+a)]; __OFSTREAM_OUT("oop_profile.rpt", _o_str)
#define OOP_PROFILE_0(str) private _o_str = format ["[%1.%2] PROFILE: %3", LOG_0, LOG_1, str]; __OFSTREAM_OUT("oop_profile.rpt", _o_str)
#define OOP_PROFILE_1(str, a) private _o_str = format ["[%1.%2] PROFILE: %3",LOG_0, LOG_1, format [str, a]]; __OFSTREAM_OUT("oop_profile.rpt", _o_str)
#define OOP_PROFILE_2(str, a, b) private _o_str = format ["[%1.%2] PROFILE: %3", LOG_0, LOG_1, format [str, a, b]]; __OFSTREAM_OUT("oop_profile.rpt", _o_str)
#define OOP_PROFILE_3(str, a, b, c) private _o_str = format ["[%1.%2] PROFILE: %3", LOG_0, LOG_1, format [str, a, b, c]]; __OFSTREAM_OUT("oop_profile.rpt", _o_str)
#define OOP_PROFILE_4(str, a, b, c, d) private _o_str = format ["[%1.%2] PROFILE: %3", LOG_0, LOG_1, format [str, a, b, c, d]]; __OFSTREAM_OUT("oop_profile.rpt", _o_str)
#define OOP_PROFILE_5(str, a, b, c, d, e) private _o_str = format ["[%1.%2] PROFILE: %3", LOG_0, LOG_1, format [str, a, b, c, d, e]]; __OFSTREAM_OUT("oop_profile.rpt", _o_str)
#else
#define OOP_PROFILE_MSG(str, a)
#define OOP_PROFILE_0(str)
#define OOP_PROFILE_1(str, a)
#define OOP_PROFILE_2(str, a, b)
#define OOP_PROFILE_3(str, a, b, c)
#define OOP_PROFILE_4(str, a, b, c, d)
#define OOP_PROFILE_5(str, a, b, c, d, e)
#endif

#ifdef OOP_INFO
#define OOP_INFO_MSG(str, a) private _o_str = format ["[%1.%2] INFO: %3",LOG_0, LOG_1, format ([str]+a)]; WRITE_LOG(_o_str)
#define OOP_INFO_0(str) private _o_str = format ["[%1.%2] INFO: %3", LOG_0, LOG_1, str]; WRITE_LOG(_o_str)
#define OOP_INFO_1(str, a) private _o_str = format ["[%1.%2] INFO: %3",LOG_0, LOG_1, format [str, a]]; WRITE_LOG(_o_str)
#define OOP_INFO_2(str, a, b) private _o_str = format ["[%1.%2] INFO: %3", LOG_0, LOG_1, format [str, a, b]]; WRITE_LOG(_o_str)
#define OOP_INFO_3(str, a, b, c) private _o_str = format ["[%1.%2] INFO: %3", LOG_0, LOG_1, format [str, a, b, c]]; WRITE_LOG(_o_str)
#define OOP_INFO_4(str, a, b, c, d) private _o_str = format ["[%1.%2] INFO: %3", LOG_0, LOG_1, format [str, a, b, c, d]]; WRITE_LOG(_o_str)
#define OOP_INFO_5(str, a, b, c, d, e) private _o_str = format ["[%1.%2] INFO: %3", LOG_0, LOG_1, format [str, a, b, c, d, e]]; WRITE_LOG(_o_str)
#define OOP_INFO_6(str, a, b, c, d, e, f) private _o_str = format ["[%1.%2] INFO: %3", LOG_0, LOG_1, format [str, a, b, c, d, e, f]]; WRITE_LOG(_o_str)
#else
#define OOP_INFO_MSG(str, a)
#define OOP_INFO_0(str)
#define OOP_INFO_1(str, a)
#define OOP_INFO_2(str, a, b)
#define OOP_INFO_3(str, a, b, c)
#define OOP_INFO_4(str, a, b, c, d)
#define OOP_INFO_5(str, a, b, c, d, e)
#define OOP_INFO_6(str, a, b, c, d, e, f)
#endif

#ifdef OOP_WARNING
#define OOP_WARNING_MSG(str, a) private _o_str = format ["[%1.%2] WARNING: %3", LOG_0, LOG_1, format ([str]+a)]; WRITE_LOG(_o_str); WRITE_CRITICAL(_o_str)
#define OOP_WARNING_0(str) private _o_str = format ["[%1.%2] WARNING: %3", LOG_0, LOG_1, str]; WRITE_LOG(_o_str); WRITE_CRITICAL(_o_str)
#define OOP_WARNING_1(str, a) private _o_str = format ["[%1.%2] WARNING: %3", LOG_0, LOG_1, format [str, a]]; WRITE_LOG(_o_str); WRITE_CRITICAL(_o_str)
#define OOP_WARNING_2(str, a, b) private _o_str = format ["[%1.%2] WARNING: %3", LOG_0, LOG_1, format [str, a, b]]; WRITE_LOG(_o_str); WRITE_CRITICAL(_o_str)
#define OOP_WARNING_3(str, a, b, c) private _o_str = format ["[%1.%2] WARNING: %3", LOG_0, LOG_1, format [str, a, b, c]]; WRITE_LOG(_o_str); WRITE_CRITICAL(_o_str)
#define OOP_WARNING_4(str, a, b, c, d) private _o_str = format ["[%1.%2] WARNING: %3", LOG_0, LOG_1, format [str, a, b, c, d]]; WRITE_LOG(_o_str); WRITE_CRITICAL(_o_str)
#define OOP_WARNING_5(str, a, b, c, d, e) private _o_str = format ["[%1.%2] WARNING: %3", LOG_0, LOG_1, format [str, a, b, c, d, e]]; WRITE_LOG(_o_str); WRITE_CRITICAL(_o_str)
#else
#define OOP_WARNING_MSG(str, a)
#define OOP_WARNING_0(str)
#define OOP_WARNING_1(str, a)
#define OOP_WARNING_2(str, a, b)
#define OOP_WARNING_3(str, a, b, c)
#define OOP_WARNING_4(str, a, b, c, d)
#define OOP_WARNING_5(str, a, b, c, d, e)
#endif

#ifdef OOP_ERROR
#define OOP_ERROR_MSG(str, a) private _o_str = format ["[%1.%2] ERROR: %3", LOG_0, LOG_1, format ([str]+a) ]; WRITE_LOG(_o_str); diag_log _o_str; WRITE_CRITICAL(_o_str); ADE_HALT
#define OOP_ERROR_0(str) private _o_str = format ["[%1.%2] ERROR: %3", LOG_0, LOG_1, str]; WRITE_LOG(_o_str); diag_log _o_str; WRITE_CRITICAL(_o_str); ADE_HALT
#define OOP_ERROR_1(str, a) private _o_str = format ["[%1.%2] ERROR: %3", LOG_0, LOG_1, format [str, a]]; WRITE_LOG(_o_str); diag_log _o_str; WRITE_CRITICAL(_o_str); ADE_HALT
#define OOP_ERROR_2(str, a, b) private _o_str = format ["[%1.%2] ERROR: %3", LOG_0, LOG_1, format [str, a, b]]; WRITE_LOG(_o_str); diag_log _o_str; WRITE_CRITICAL(_o_str); ADE_HALT
#define OOP_ERROR_3(str, a, b, c) private _o_str = format ["[%1.%2] ERROR: %3", LOG_0, LOG_1, format [str, a, b, c]]; WRITE_LOG(_o_str); diag_log _o_str; WRITE_CRITICAL(_o_str); ADE_HALT
#define OOP_ERROR_4(str, a, b, c, d) private _o_str = format ["[%1.%2] ERROR: %3", LOG_0, LOG_1, format [str, a, b, c, d]]; WRITE_LOG(_o_str); diag_log _o_str; WRITE_CRITICAL(_o_str); ADE_HALT
#define OOP_ERROR_5(str, a, b, c, d, e) private _o_str = format ["[%1.%2] ERROR: %3", LOG_0, LOG_1, format [str, a, b, c, d, e]]; WRITE_LOG(_o_str); diag_log _o_str; WRITE_CRITICAL(_o_str); ADE_HALT
#define OOP_ERROR_6(str, a, b, c, d, e, f) private _o_str = format ["[%1.%2] ERROR: %3", LOG_0, LOG_1, format [str, a, b, c, d, e, f]]; WRITE_LOG(_o_str); diag_log _o_str; WRITE_CRITICAL(_o_str); ADE_HALT
#else
#define OOP_ERROR_MSG(str, a)
#define OOP_ERROR_0(str)
#define OOP_ERROR_1(str, a)
#define OOP_ERROR_2(str, a, b)
#define OOP_ERROR_3(str, a, b, c)
#define OOP_ERROR_4(str, a, b, c, d)
#define OOP_ERROR_5(str, a, b, c, d, e)
#define OOP_ERROR_6(str, a, b, c, d, e, f)
#endif

#ifdef OOP_DEBUG
#define OOP_DEBUG_MSG(str, a) private _o_str = format ["[%1.%2] DEBUG: %3", LOG_0, LOG_1, format ([str]+a) ]; WRITE_LOG(_o_str)
#define OOP_DEBUG_0(str) private _o_str = format ["[%1.%2] DEBUG: %3", LOG_0, LOG_1, str]; WRITE_LOG(_o_str)
#define OOP_DEBUG_1(str, a) private _o_str = format ["[%1.%2] DEBUG: %3", LOG_0, LOG_1, format [str, a]]; WRITE_LOG(_o_str)
#define OOP_DEBUG_2(str, a, b) private _o_str = format ["[%1.%2] DEBUG: %3", LOG_0, LOG_1, format [str, a, b]]; WRITE_LOG(_o_str)
#define OOP_DEBUG_3(str, a, b, c) private _o_str = format ["[%1.%2] DEBUG: %3", LOG_0, LOG_1, format [str, a, b, c]]; WRITE_LOG(_o_str)
#define OOP_DEBUG_4(str, a, b, c, d) private _o_str = format ["[%1.%2] DEBUG: %3", LOG_0, LOG_1, format [str, a, b, c, d]]; WRITE_LOG(_o_str)
#define OOP_DEBUG_5(str, a, b, c, d, e) private _o_str = format ["[%1.%2] DEBUG: %3", LOG_0, LOG_1, format [str, a, b, c, d, e]]; WRITE_LOG(_o_str)
#define OOP_DEBUG_6(str, a, b, c, d, e, f) private _o_str = format ["[%1.%2] DEBUG: %3", LOG_0, LOG_1, format [str, a, b, c, d, e]]; WRITE_LOG(_o_str)
#else
#define OOP_DEBUG_MSG(str, a)
#define OOP_DEBUG_0(str)
#define OOP_DEBUG_1(str, a)
#define OOP_DEBUG_2(str, a, b)
#define OOP_DEBUG_3(str, a, b, c)
#define OOP_DEBUG_4(str, a, b, c, d)
#define OOP_DEBUG_5(str, a, b, c, d, e)
#define OOP_DEBUG_6(str, a, b, c, d, e, f)
#endif

// Log to file
#ifdef OOP_LOGF
#define OOP_LOGF_MSG(f, msg, a) private _o_str = format ([msg]+a); WRITE_LOGF(f, _o_str)
#define OOP_LOGF_0(f, msg) private _o_str = msg; WRITE_LOGF(f, _o_str)
#define OOP_LOGF_1(f, msg, a) private _o_str = format [msg, a]; WRITE_LOGF(f, _o_str)
#define OOP_LOGF_2(f, msg, a, b) private _o_str = format [msg, a, b]; WRITE_LOGF(f, _o_str)
#define OOP_LOGF_3(f, msg, a, b, c) private _o_str = format [msg, a, b, c]; WRITE_LOGF(f, _o_str)
#define OOP_LOGF_4(f, msg, a, b, c, d) private _o_str = format [msg, a, b, c, d]; WRITE_LOGF(f, _o_str)
#define OOP_LOGF_5(f, msg, a, b, c, d, e) private _o_str = format [msg, a, b, c, d, e]; WRITE_LOGF(f, _o_str)
#define OOP_LOGF_6(f, msg, a, b, c, d, e, f) private _o_str = format [msg, a, b, c, d, e]; WRITE_LOGF(f, _o_str)
#else
#define OOP_LOGF_MSG(f, msg, a)
#define OOP_LOGF_0(f, msg)
#define OOP_LOGF_1(f, msg, a)
#define OOP_LOGF_2(f, msg, a, b)
#define OOP_LOGF_3(f, msg, a, b, c)
#define OOP_LOGF_4(f, msg, a, b, c, d)
#define OOP_LOGF_5(f, msg, a, b, c, d, e)
#define OOP_LOGF_6(f, msg, a, b, c, d, e, f)
#endif
