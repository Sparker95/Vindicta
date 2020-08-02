



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

// Origin is not important
#define ORIGIN_NONE				0
// Value from goal world state, planner will return it by reference (ID)
#define ORIGIN_GOAL_WS			1
// Special type to indicate that the value of world state depends on action input parameter with given tag
#define ORIGIN_ACTION_PARAMETER 5 
// Value is from goal parameter, planner will return it by reference (tag from goal parameters)
#define ORIGIN_GOAL_PARAMETER	7
// Value is static, planner will return it by value directly
#define ORIGIN_STATIC_VALUE		8
// Value is dynamic and originates from dynamic action preconditions
#define ORIGIN_DYNAMIC_ACTION_PRECONDITIONS 11