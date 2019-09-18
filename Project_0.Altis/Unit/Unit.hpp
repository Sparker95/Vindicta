/*
*/

#define UNIT_DATA_ID_CAT			0
#define UNIT_DATA_ID_SUBCAT			1
#define UNIT_DATA_ID_CLASS_NAME		2
#define UNIT_DATA_ID_OBJECT_HANDLE	3
#define UNIT_DATA_ID_GARRISON		4
#define UNIT_DATA_ID_OWNER			5
#define UNIT_DATA_ID_GROUP			6
#define UNIT_DATA_ID_MUTEX			7
#define UNIT_DATA_ID_AI				8
#define UNIT_DATA_ID_LOADOUT		9
#define UNIT_DATA_ID_BUILD_RESOURCE 10

#define UNIT_DATA_SIZE				10

//								 0, 1,  2,       3,  4, 5,  6,  7,  8,  9, 
#define UNIT_DATA_DEFAULT		[0, 0, "", objNull, "", 2, "", [], "", "", 0]

//Class name of Unit class, in case I need to rename it everywhere
#define UNIT_CLASS_NAME "Unit"

// String names of public variables set on units
#define UNIT_VAR_NAME_STR "__u"
#define UNIT_EFFICIENCY_VAR_NAME_STR "__e"