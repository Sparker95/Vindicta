#include "..\..\common.h"

0 spawn {

sleep 2;

private _duration = 3;

private _args = ["", "PROMOTION", "You have been promoted!", "", _duration, "hint"];
CALLSM("Notification", "createNotification", _args);

sleep 1;

private _args = ["", "TOTAL SHAME", "You have been depromoted!", "This lasts for 6 seconds", 6, "hint"];
CALLSM("Notification", "createNotification", _args);

sleep 1;

private _args = ["", "WTF", "They promoted you again!", "", _duration, "hint"];
CALLSM("Notification", "createNotification", _args);
private _args = ["", "WTF", "They promoted you again!", "This notification lasts for 1.5 seconds", 0.5*_duration, "hint"];
CALLSM("Notification", "createNotification", _args);
private _args = ["", "WTF", "They promoted you again!", "This notification lasts for 1 second", 0.3*_duration, "hint"];
CALLSM("Notification", "createNotification", _args);
private _args = ["", "WTF", "They promoted you again!", "", _duration, "hint"];
CALLSM("Notification", "createNotification", _args);
private _args = ["", "WTF", "They promoted you again!", "Hint: you are a commander now!", _duration, "hint"];
CALLSM("Notification", "createNotification", _args);

};

