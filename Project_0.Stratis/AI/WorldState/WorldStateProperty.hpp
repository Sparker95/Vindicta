#define WSP_NEW(key, value) value

#define WSP_TYPE_DOES_NOT_EXIST		0
#define WSP_TYPE_NUMBER				1
#define WSP_TYPE_STRING				2
#define WSP_TYPE_OBJECT_HANDLE		3
#define WSP_TYPE_BOOL				4
#define WSP_TYPE_ARRAY				5

// Special type to indicate that the value of world state depends on action input parameter with given tag
#define WSP_TYPE_ACTION_PARAMETER	6

// Special type to indicate that the value of world state depends on goal input parameter with given tag
#define WSP_TYPE_GOAL_PARAMETER		7

#define WSP_TYPES [0, "", objNull, true, []]