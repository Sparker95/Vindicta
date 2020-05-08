#define WSP_TYPE_DOES_NOT_EXIST		"0"
#define WSP_TYPE_NUMBER				"N"
#define WSP_TYPE_STRING				"S"
#define WSP_TYPE_OBJECT_HANDLE		"H"
#define WSP_TYPE_BOOL				"B"
#define WSP_TYPE_ARRAY				"A"

// Special type to indicate that the value of world state depends on action input parameter with given tag
#define WSP_TYPE_ACTION_PARAMETER	"P"

// Special type to indicate that the value of world state depends on goal input parameter with given tag
#define WSP_TYPE_GOAL_PARAMETER		"G"

#define WSP_TYPES [0, "", objNull, true, []]