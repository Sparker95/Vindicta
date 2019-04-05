// Adds/substracts two vectors of length 9
#define VECTOR_ADD_9(a, b) ((a select [0, 3]) vectorAdd (b select [0, 3])) + ((a select [3, 3]) vectorAdd (b select [3, 3])) + ((a select [6, 3]) vectorAdd (b select [6, 3]))
#define VECTOR_SUB_9(a, b) ((a select [0, 3]) vectorDiff (b select [0, 3])) + ((a select [3, 3]) vectorDiff (b select [3, 3])) + ((a select [6, 3]) vectorDiff (b select [6, 3]))

#define T_EFF_SOFT			0
#define T_EFF_MEDIUM		1
#define T_EFF_ARMOR			2
#define T_EFF_AIR			3
#define T_EFF_ANTI_SOFT		4
#define T_EFF_ANTI_MEDIUM	5
#define T_EFF_ANTI_ARMOR	6
#define T_EFF_ANTI_AIR		7
#define T_EFF_DUMMY			8

#define T_EFF_CAN_DESTROY_ALL 4