// All message types in the mission
// Some are not used though :\
// Author: Sparker 05.08.2018

// Global messages - can be sent to different kinds of objects
#define MESSAGE_UNIT_DESTROYED	50

// Location messages
// Messages
#define LOCATION_MESSAGE_PROCESS 110

// Garrison messages
#define GARRISON_MESSAGE_PROCESS 115

// Goal messages
// This message is sent to the goal by a timer to make it call its process method
#define ACTION_MESSAGE_PROCESS	120
// Send this message to a goal so that it deletes itself
#define ACTION_MESSAGE_DELETE		121
//  Send it to a goal which was handling an animation, like sitting on a bench or
// by a campfire, when a bot has been interrupted, for example by spotting an enemy
#define ACTION_MESSAGE_ANIMATION_INTERRUPTED 122

// AnimObject messages
// Sent by a unit when he has freed a position with any reason
#define ANIM_OBJECT_MESSAGE_POS_FREE	200

// AI messages
#define AI_MESSAGE_PROCESS 500
#define AI_MESSAGE_DELETE 501

// Undercover monitor
#define SMON_MESSAGE_PROCESS		600
#define SMON_MESSAGE_BEING_SPOTTED	601
#define SMON_MESSAGE_COMPROMISED	602
#define SMON_MESSAGE_DELETE			603
#define SMON_MESSAGE_ARRESTED		604

// Group monitor
#define GROUP_MONITOR_MESSAGE_PROCESS 700

// Location Visibility Monitor
#define LVMON_MESSAGE_PROCESS 800

// Garrison Server
#define GARRISON_SERVER_MESSAGE_PROCESS 900