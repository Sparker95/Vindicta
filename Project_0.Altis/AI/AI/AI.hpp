



// Macros for manipulating A* nodes

#define ASTAR_NODE_ID_WS				0
#define ASTAR_NODE_ID_ACTION			1
#define ASTAR_NODE_ID_ACTION_PARAMETERS	2
#define ASTAR_NODE_ID_G					3
#define ASTAR_NODE_ID_F					4
#define ASTAR_NODE_ID_H					5
#define ASTAR_NODE_ID_NEXT_NODE			6

#define ASTAR_NODE_DOES_NOT_EXIST		666
#define ASTAR_ACTION_DOES_NOT_EXIST		555

#define ASTAR_NODE_NEW(worldState) [worldState, ASTAR_ACTION_DOES_NOT_EXIST, 0, 0, 0, 0, ASTAR_NODE_DOES_NOT_EXIST]