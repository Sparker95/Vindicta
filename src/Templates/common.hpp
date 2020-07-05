//#define ASP_ENABLE

#ifdef _SQF_VM
#undef ASP_ENABLE
#endif

#ifdef ASP_ENABLE
#define _CREATE_PROFILE_SCOPE(scopeName) private _tempScope = createProfileScope scopeName
#else
#define _CREATE_PROFILE_SCOPE(scopeName)
#endif

#define pr private

#define NOT_FOUND -1