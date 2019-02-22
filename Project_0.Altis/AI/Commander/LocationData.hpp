// Class: AICommander

/*
Enum: CLD
Stands for Commander Location Data
Data about spotted locations is stored in Commander AI world facts in this way.
*/

/*Field: CLD_ID_TYPE
Type of this location*/
#define CLD_ID_TYPE 0

/*Field: CLD_ID_SIDE
Side that controls this location*/
#define CLD_ID_SIDE 1

/*Field: CLD_ID_UNITS
Array with subarrays which hold how many units of specific types/subtypes are there
Structure of the array: [infantry, vehicles, drones]
infantry - [amount of subcategory 0, 1, 2, ...]
vehicles - [amount of subcategory 0, 1, 2, ...]
drones - [amount of subcategory 0, 1, 2, ...]
*/
#define CLD_ID_UNIT_AMOUNT 2

// 2D position
#define CLD_ID_POS 3

// Last time it was updated
#define CLD_ID_TIME 4

// Extra data
// Marker, makes sense only for clients
#define CLD_ID_MARKER 5

#define CLD_NEW() call { \
private _return = [0, CIVILIAN, [[], [], []], [0, 0], 0, ""]; \
(_return select CLD_ID_UNIT_AMOUNT select T_INF) resize T_INF_SIZE; \
(_return select CLD_ID_UNIT_AMOUNT select T_VEH) resize T_VEH_SIZE; \
(_return select CLD_ID_UNIT_AMOUNT select T_DRONE) resize T_DRONE_SIZE; \
_return};
