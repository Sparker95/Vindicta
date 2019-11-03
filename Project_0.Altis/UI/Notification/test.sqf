#include "..\..\OOP_Light\OOP_Light.h"

private _args = ["", "PROMOTION", "You have been promoted!", "", 4];
CALLSM("Notification", "createNotification", _args);

private _args = ["", "TOTAL SHAME", "You have been depromoted!", "", 6];
CALLSM("Notification", "createNotification", _args);