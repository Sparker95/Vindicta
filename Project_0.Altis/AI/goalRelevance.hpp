// Relevance levels





// TODO: REMOVE THIS FILES (FIX DEPENDENCIES)






// Relevance from 200 and beyond is for goals supplied by higher agents
#define GOAL_RELEVANCE_BIAS_HIGHER	200

// Relevance of own goals
#define GOAL_RELEVANCE_BIAS_SELF	100

// Releavance of goals supplied by lower agents
// If a goal returns this relevance, it is ignored
#define GOAL_RELEVANCE_BIAS_LOWER	0

// ============== Universal goals ===============

// ============== Garrison goals ================
#define GOAL_RELEVANCE_GARRISON_REPAIR_ALL_VEHICLES (GOAL_RELEVANCE_BIAS_SELF+10)
#define GOAL_RELEVANCE_GARRISON_MOVE (GOAL_RELEVANCE_BIAS_SELF+8)
#define GOAL_RELEVANCE_GARRISON_RELAX (GOAL_RELEVANCE_BIAS_LOWER+1)




// =============== Group goals ==================
#define GOAL_RELEVANCE_GROUP_RELAX (GOAL_RELEVANCE_BIAS_SELF+1)


// =============== Unit goals ===================
#define GOAL_RELEVANCE_UNIT_SALUTE (GOAL_RELEVANCE_BIAS_SELF+10)
#define GOAL_RELEVANCE_UNIT_RELAX (GOAL_RELEVANCE_BIAS_SELF+1)
#define GOAL_RELEVANCE_UNIT_SCAREAWAY (GOAL_RELEVANCE_BIAS_SELF+20)
#define GOAL_RELEVANCE_UNIT_SHOOT_NEAR_TARGET (GOAL_RELEVANCE_BIAS_SELF+30)