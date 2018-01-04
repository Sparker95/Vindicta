/*
These numbers are used in the garrison thread.
*/
#define G_R_STOP				1
#define G_R_SPAWN				10
#define G_R_DESPAWN				20
#define G_R_ADD_EXISTING_UNIT	30
#define G_R_ADD_EXISTING_GROUP	31
#define G_R_ADD_NEW_UNIT		32
#define G_R_ADD_NEW_GROUP		33
#define G_R_REMOVE_UNIT			40
#define G_R_MOVE_GROUP			50
#define G_R_JOIN_GROUP			60
#define G_R_ASSIGN_VEHICLE_ROLES	70

//#define G_S_IDLE				0
//#define G_S_STOPPING			1
//#define G_S_SPAWNED				11

//Structure of g_inf, g_veh, g_drone arrays
#define G_UNIT_CLASSNAME		0
#define G_UNIT_HANDLE			1
#define G_UNIT_ID				2
#define G_UNIT_GROUP_ID			3

//Structure of g_group array
#define G_GROUP_UNITS			0
#define G_GROUP_HANDLE			1
#define G_GROUP_ID				2
#define G_GROUP_TYPE			3