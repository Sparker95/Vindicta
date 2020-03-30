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

// /*
// Enum: GROUP_TYPE
// Must include: Group\Group.hpp

// GROUP_TYPE_IDLE - Group which is doing nothing specific at the location now. Probably a reserve non-structured infantry squad or a vehicle without assigned crew.
// GROUP_TYPE_VEH_STATIC - Static vehicle(s) and its/their crew
// GROUP_TYPE_VEH_NON_STATIC - Non-static vehicles and their crew
// GROUP_TYPE_PATROL - Patrols that are walking around
// GROUP_TYPE_BUILDING_SENTRY - Infantry inside buildings in firing positions like snipers/marksmen/sharpshooters
// */

#define GROUP_TYPE_IDLE 			0 
#define GROUP_TYPE_VEH_STATIC 		1
#define GROUP_TYPE_VEH_NON_STATIC	2
#define GROUP_TYPE_PATROL			3
#define GROUP_TYPE_BUILDING_SENTRY	4

gDebugGroupTypeNames = [
	"IDLE",
	"VEH_STATIC",
	"VEH_NON_STATIC",
	"PATROL",
	"BUILDING_SENTRY"
];

// Array with all group types
#define GROUP_TYPE_ALL [0, 1, 2, 3, 4]
