/*
Handle message incoming into a garrison object.
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "..\Garrison\Garrison.hpp"

params [ ["_thisObject", "", [""]] , ["_msg", [], [[]]] ];
diag_log format ["[Garrison] Info: HandleMessage: %1", _msg];

private _msgType = _msg select MESSAGE_ID_TYPE;
private _msgData = _msg select MESSAGE_ID_DATA;
private _msgDest = _msg select MESSAGE_ID_DESTINATION;

