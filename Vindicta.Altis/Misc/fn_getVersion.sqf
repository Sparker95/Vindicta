/*
returns version string
*/

private _major =
#include "..\config\majorVersion.hpp"
;

private _minor =
#include "..\config\minorVersion.hpp"
;

private _build =
#include "..\config\buildVersion.hpp"
;

format ["%1.%2.%3", _major, _minor, _build];