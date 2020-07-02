// Class: AICommander

// /*
// Enum: CLD
// Stands for Commander Location Data
// Data about spotted locations is stored in Commander AI world facts in this way.
// */

// /*Field: CLD_ID_TYPE
// Type of this location*/
#define CLD_ID_TYPE 0

// /*Field: CLD_ID_SIDE
// Side that controls this location*/
#define CLD_ID_SIDE 1

// /*Field: CLD_ID_UNITS
// Array with subarrays which hold how many units of specific types/subtypes are there
// Structure of the array: [infantry, vehicles, drones]
// infantry - [amount of subcategory 0, 1, 2, ...]
// vehicles - [amount of subcategory 0, 1, 2, ...]
// drones - [amount of subcategory 0, 1, 2, ...]
// If [], means unit amounts are not known
// */
#define CLD_ID_UNIT_AMOUNT 2

// 2D position
#define CLD_ID_POS 3

// Last time it was updated
#define CLD_ID_TIME 4

// Extra data
// Marker, makes sense only for clients
#define CLD_ID_MARKER 5

// Location, ref to actual location object
#define CLD_ID_LOCATION 6

#define CLD_UNIT_AMOUNT_UNKNOWN []
#define CLD_UNIT_AMOUNT_FULL call { \
	private _a = [[], [], []]; \
	(_a select T_INF) resize T_INF_SIZE; \
	(_a select T_VEH) resize T_VEH_SIZE; \
	(_a select T_DRONE) resize T_DRONE_SIZE; \
	_a};
	
#define CLD_SIDE_UNKNOWN sideUnknown

#define CLD_NEW() [0, CIVILIAN, CLD_UNIT_AMOUNT_UNKNOWN, [0, 0], 0, "", ""]

// Levels of gained intel
// Only position is known
#define CLD_UPDATE_LEVEL_TYPE_UNKNOWN	0
// Only position and type are known
#define CLD_UPDATE_LEVEL_TYPE			1
// Type and side are known
#define CLD_UPDATE_LEVEL_SIDE			2
// Position, type and units are known
#define CLD_UPDATE_LEVEL_UNITS			3