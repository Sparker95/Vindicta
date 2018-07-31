#include "OOP_Light\OOP_Light.h"
#include "Message\Message.hpp"

private _timerService = NEW("TimerService", []);

// Create a test MessageReceiver and MessageLoop
private _msgLoop = NEW("MessageLoop", []);

private _msg = MESSAGE_NEW();
_msg set [MESSAGE_ID_DESTINATION, ];
private _timer0 = NEW("Timer", _args);