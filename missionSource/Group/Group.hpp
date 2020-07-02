// Class: Group

#define GROUP_CLASS_NAME "Group"

#define GROUP_DATA_ID_UNITS			0
#define GROUP_DATA_ID_SIDE			1
#define GROUP_DATA_ID_GROUP_HANDLE	2
#define GROUP_DATA_ID_MUTEX			3
#define GROUP_DATA_ID_TYPE			4
#define GROUP_DATA_ID_GARRISON		5
#define GROUP_DATA_ID_AI			6
#define GROUP_DATA_ID_SPAWNED		7
#define GROUP_DATA_ID_LEADER		8

//				     		  0,        1,       2,  3, 4,  5,  6,     7
#define GROUP_DATA_DEFAULT	[[], CIVILIAN, grpNull, [], 0, "", "", false, ""]

//
// Enum: GROUP_TYPE
// Must include: Group\Group.hpp
//
// GROUP_TYPE_INF - Infantry only
// GROUP_TYPE_STATIC - Static weapon and crew
// GROUP_TYPE_VEH - Vehicles and crew
// 

#define GROUP_TYPE_INF 				0 
#define GROUP_TYPE_STATIC 			1
#define GROUP_TYPE_VEH				2

gDebugGroupTypeNames = [
	"INF",
	"STATIC",
	"VEH"
];

// Array with all group types
#define GROUP_TYPE_ALL [0, 1, 2]

// String names of public variables set on units
#define GROUP_VAR_NAME_STR "__u"
