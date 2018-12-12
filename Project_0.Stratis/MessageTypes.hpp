// All message types in the mission
// Author: Sparker 05.08.2018

// Global messages - can be sent to different kinds of objects
#define MESSAGE_UNIT_DESTROYED	50

// Location messages
// Messages
#define LOCATION_MESSAGE_PROCESS 110

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

// Suspiciousness monitor
#define SMON_MESSAGE_PROCESS		600
#define SMON_MESSAGE_BEING_SPOTTED	601

// Group monitor
#define GROUP_MONITOR_MESSAGE_PROCESS 700