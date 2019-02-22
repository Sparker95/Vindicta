// Structure of a target record
// object handle, knows about, position, age
#define TARGET_ID_OBJECT_HANDLE 0 
#define TARGET_ID_KNOWS_ABOUT 1
#define TARGET_ID_POS 2
#define TARGET_ID_TIME 3

#define TARGET_NEW(hO, knows, pos, time) [hO, knows, pos, time]