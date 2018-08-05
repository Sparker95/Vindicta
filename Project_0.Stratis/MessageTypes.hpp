// All message types in the mission
// Author: Sparker 05.08.2018

// Location messages
// Messages
#define LOCATION_MESSAGE_PROCESS 10

// Goal messages
// This message is sent to the goal by a timer to make it call its process method
#define GOAL_MESSAGE_PROCESS	20
// Send this message to a goal so that it deletes itself
#define GOAL_MESSAGE_DELETE		21