/*
Checks if the request with specified requestID has been executed
return value: true or false
*/

#include "garrison.hpp"

params ["_lo", "_requestID"];

private _rID = _lo getVariable ["g_execRequestID", 0];

_rID > _requestID
