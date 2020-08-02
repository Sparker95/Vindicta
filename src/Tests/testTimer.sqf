#include "common.h"
#include "Message\Message.hpp"

private _timerService = NEW("TimerService", [0.2]);

// Create a test MessageReceiver and MessageLoop
private _msgLoop = NEW("MessageLoop", []);
diag_log format ["==== MessageLoop: %1", _msgLoop];
private _args = ["Receiver 0", _msgLoop];
private _msgReceiver0 = NEW("DebugPrinter", _args);

// Create slow timer
private _msg = MESSAGE_NEW();
_msg set [MESSAGE_ID_DESTINATION, _msgReceiver0];
_msg set [MESSAGE_ID_SOURCE, ""];
_msg set [MESSAGE_ID_DATA, "Slow timer!"];
_msg set [MESSAGE_ID_TYPE, 666];

private _args = [_msgReceiver0, 4, _msg, _timerService]; // message receiver, interval, message, timer service
private _timer0 = NEW("Timer", _args);

// Create fast timer
private _msg = MESSAGE_NEW();
_msg set [MESSAGE_ID_DESTINATION, _msgReceiver0];
_msg set [MESSAGE_ID_SOURCE, ""];
_msg set [MESSAGE_ID_DATA, "Fast timer!"];
_msg set [MESSAGE_ID_TYPE, 666];

private _args = [_msgReceiver0, 0.5, _msg, _timerService]; // message receiver, interval, message, timer service
private _timer1 = NEW("Timer", _args);