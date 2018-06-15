/*
This message defines the message structure.
Messages are structores that objects in the mission can send to each other.
Internally message is an array with several elements.

Author: Sparker
15.06.2018
*/

#define MSG_ID_DESTINATION 0
#define MSG_ID_SOURCE 1
#define MSG_ID_TYPE 2
#define MSG_ID_DATA	3

#define MSG_NEW() ["", "", "", 0]