/*
This message defines the message structure.
Messages are structores that objects in the mission can send to each other.
Internally message is an array with several elements.

Author: Sparker
15.06.2018
*/

#define MESSAGE_ID_DESTINATION 0
#define MESSAGE_ID_SOURCE 1
#define MESSAGE_ID_TYPE 2
#define MESSAGE_ID_DATA	3

#define MESSAGE_NEW() ["", "", "", 0]

/*
Code to set all parameters:
_msg set [MESSAGE_ID_DESTINATION, ...];
_msg set [MESSAGE_ID_SOURCE, ""];
_msg set [MESSAGE_ID_DATA, ...];
_msg set [MESSAGE_ID_TYPE, ...];
*/