#define GROUP_CLASS_NAME "Group"

#define GROUP_DATA_ID_UNITS			0
#define GROUP_DATA_ID_SIDE			1
#define GROUP_DATA_ID_GROUP_HANDLE	2
#define GROUP_DATA_ID_MUTEX			3
#define GROUP_DATA_ID_TYPE			4
#define GROUP_DATA_ID_GARRISON		5
#define GROUP_DATA_ID_ACTION		6

//				     		  0,        1,       2,  3, 4,  5,  6
#define GROUP_DATA_DEFAULT	[[], CIVILIAN, grpNull, [], 0, "", ""]

// Group types
// Used to aid in spawn position selection
// Group which is doing nothing specific at the location now. Probably a reserve non-structured infantry squad or a vehicle without assigned crew.
#define GROUP_TYPE_IDLE 			0 
// Static vehicle(s) and its/their crew
#define GROUP_TYPE_VEH_STATIC 		1
// Non-static vehicles and their crew
#define GROUP_TYPE_VEH_NON_STATIC	2
// Infantry inside buildings in firing positions like snipers/marksmen/sharpshooters
#define GROUP_TYPE_BUILDING_SENTRY	3
//Patrols that are walking around
#define GROUP_TYPE_PATROL			4

// Array with all group types
#define GROUP_TYPE_ALL [0, 1, 2, 3, 4]