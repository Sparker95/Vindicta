/*
*/

#define DATA_ID_CAT				0
#define DATA_ID_SUBCAT			1
#define DATA_ID_CLASS_NAME		2
#define DATA_ID_OBJECT_HANDLE	3
#define DATA_ID_GARRISON		4
#define DATA_ID_OWNER			5
#define DATA_ID_GROUP			6
#define DATA_ID_MUTEX			7

#define DATA_SIZE				8

//							 0, 1,  2,       3,  4, 5,  6,  7
#define DATA_DEFAULT		[0, 0, "", objNull, "", 2, "", []]

//Class name of Unit class, in case I need to rename it everywhere
#define UNIT_CLASS_NAME "Unit"