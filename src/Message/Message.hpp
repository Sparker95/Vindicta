// /*
// Struct: Message
// File: Message\Message.hpp
// Message is a structure that can be sent to <MessageReceiver> objects.
// Internally message is an array with several elements.

// Author: Sparker
// 15.06.2018
// */

// /*Field: DESTINATION
// The destination <MessageReceiver>.
// You don't have to specify it manually while posting a message.*/
#define MESSAGE_ID_DESTINATION 0
// /*Field: SOURCE
// The source object. Not used by the routing mechanism and can be of any value. You can specify it if it eases your design.*/
#define MESSAGE_ID_SOURCE 1
// /*Field: SOURCE_OWNER
// Owner(client ID) of the machine that has sent this message. You must not set it manually while posting a message.*/
#define MESSAGE_ID_SOURCE_OWNER 2
// /*Field: SOURCE_ID
// Only used if the postMessage method was requested to mark the message as complete. You must not set it manually while posting a message.*/
#define MESSAGE_ID_SOURCE_ID 3
// /*Field: TYPE
// Type of this message. You must set it if your destination <MessageReceiver> can handle different message types.*/
#define MESSAGE_ID_TYPE 4
// /*Field: DATA
// The payload of this message. Can be anything depending on your design.*/
#define MESSAGE_ID_DATA	5

// /*
// macro: MESSAGE_NEW()

// Returns: a new <Message>
// */

#define MESSAGE_NEW() ["", "", CLIENT_OWNER, MESSAGE_ID_NOT_REQUESTED, 0, 0]

// /*Macro: MESSAGE_NEW_SHORT(destination, type)
// Creates a short message which only has destination and type*/
#define MESSAGE_NEW_SHORT(dest, type) [dest, "", CLIENT_OWNER, MESSAGE_ID_NOT_REQUESTED, type, 0]

//msgID value if it was not requested to return it
//needed for MessageReceiver and MessageLoop classes
#define MESSAGE_ID_NOT_REQUESTED -666

// - - - - Macros to set data - - - -

// /* Macro: MESSAGE_SET_DESTINATION(msg, val)
// Sets destination of the message*/
#define MESSAGE_SET_DESTINATION(msg, val) msg set [MESSAGE_ID_DESTINATION, val]
// Macro: MESSAGE_SET_SOURCE(msg, val)
#define MESSAGE_SET_SOURCE(msg, val) msg set [MESSAGE_ID_SOURCE, val]
// Macro: MESSAGE_SET_TYPE(msg, val)
#define MESSAGE_SET_TYPE(msg, val) msg set [MESSAGE_ID_TYPE, val]
// Macro: MESSAGE_SET_DATA(msg, val)
#define MESSAGE_SET_DATA(msg, val) msg set [MESSAGE_ID_DATA, val]
