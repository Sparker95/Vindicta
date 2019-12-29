/*
returns version string
*/

private _array =
#include "..\config\version.hpp"
;
private _build = 0; // todo
format ["%1.%2.%3", _array#0, _array#1, _build];