// File which is included by all other files in this project

// OOP_Light.h
#include "OOP_Light\OOP_Light.h"

// Common path
#include "commonPath.hpp"

// -----------------------------------------------------
// |              L I N E   N U M B E R S              |
// -----------------------------------------------------

// Some BS to force Arma preprocessor line numbers to be correct.
// You basically have to put this after every pre-processor block if you want the correct line numbers
#define FIX_LINE_NUMBERS2(sharp) sharp##line __LINE__ __FILE__
// Use this with () but WITHOUT terminating ; like:
// FIX_LINE_NUMBERS()
#define FIX_LINE_NUMBERS() FIX_LINE_NUMBERS2(#)


// ----------------------------------------------------------------------
// |                       L O C A L I Z A T I O N                      |
// ----------------------------------------------------------------------

#define LOCS(scope, id) (localize ("STR_" + scope + "_" + id))
#define LOC(id) LOCS(LOC_SCOPE, id)

// ----------------------------------------------------------------------
// |                               M A T H                              |
// ----------------------------------------------------------------------
// Zero the height component of a vector
#define ZERO_HEIGHT(pos) ([(pos) select 0, (pos) select 1, 0])
// Ensure a vector has 3 components
#define VECTOR3(pos) (if(count (pos) == 2) then { pos + [0] } else { pos })

// Clamp val_ between min_ and max_
#define CLAMP(val_, min_, max_) ((min_) max (val_) min (max_))
// Return greater of two numbers
#define MAXIMUM(a_, b_) ((a_) max (b_))
// Return lesser of two numbers
#define MINIMUM(a_, b_) ((a_) min (b_))
// Clamp val_ between 0 and 1
#define SATURATE(val_) CLAMP(val_, 0, 1)
// Clamp val_ between 0 and +inf
#define CLAMP_POSITIVE(val_) MAXIMUM(val_, 0)
// Clamp val_ between 0 and -inf
#define CLAMP_NEGATIVE(val_) MINIMUM(val_, 0)
// Map v from (a, b) to (s, t)
#ifndef _SQF_VM
#define MAP_TO_RANGE(v, a, b, s, t) (linearConversion [a, b, v, s, t, false])
#else
#define MAP_TO_RANGE(v, a, b, s, t) ((s) + ((v) - (a)) * ((t) - (s)) / ((b) - (a)))
#endif

// Functions to help with applying difficulty to values
// h is difficulty setting
// Interpolate linearly between s and t by h (0 <= h <= 1)
#define MAP_LINEAR(h, s, t) MAP_TO_RANGE(h, 0, 1, s, t)
// Interpolates between s and t, with m as a fixed point that always maps to h = 0.5. 
// i.e. linear between s and m for h <= 0.5 and m and t for h > 0.5
#define MAP_LINEAR_SET_POINT(h, s, m, t) (if ((h) <= 0.5) then { MAP_TO_RANGE(h, 0, 0.5, s, m) } else { MAP_TO_RANGE(h, 0.5, 1, m, t) } )
// Something like a generalized gamma correction function
// See https://www.desmos.com/calculator/knchi5fjrz for example of how this function works (k = 0.5 here)
#define MAP_GAMMA(h, x) ((x) ^ ((1 - (h) * 0.5 + 0.25) ^ 6))

// ----------------------------------------------------------------------
// |                       R E M O T E   E X E C                        |
// ----------------------------------------------------------------------
#define ON_ALL 		0
#define ON_SERVER 	2
#define ON_CLIENTS	([0, -2] select IS_DEDICATED)
#define NO_JIP 		false
#define ALWAYS_JIP	true


// Agents
#define SET_AGENT_FLAG(obj) obj setVariable ["vin_isAgent", true]
#define GET_AGENT_FLAG(obj) obj getVariable ["vin_isAgent", false]

// Arrested variable name
// Shared between bots and players
#define SET_ARRESTED_FLAG(obj) obj setVariable ["vin_arrested", true, true]
#define RESET_ARRESTED_FLAG(obj) obj setVariable ["vin_arrested", false, true]
#define GET_ARRESTED_FLAG(obj) (obj getVariable ["vin_arrested", false])

// private keyword
#define pr private

// Code to string
#define CODE_TO_STRING(code) 0 call {private __codeToStringTemp = str code; __codeToStringTemp select [1, (count __codeToStringTemp)-2];}


// Profiler scopes
#ifdef ASP_ENABLE
#define ASP_SCOPE_START(name) private __ASPScope##name = createProfileScope #name
#define ASP_SCOPE_END(name) __ASPScope##name=nil
#else
#define ASP_SCOPE_START(name) ;
#define ASP_SCOPE_END(name) ;
#endif
