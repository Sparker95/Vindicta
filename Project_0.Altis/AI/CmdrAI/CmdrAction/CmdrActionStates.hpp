#define CMDR_ACTION_STATE_NONE		-1000
#define CMDR_ACTION_STATE_START 	0
#define CMDR_ACTION_STATE_END 		1
#define CMDR_ACTION_STATE_ALL 		-1
#define CMDR_ACTION_STATE_CUSTOM	1000

#define CMDR_ACTION_PRIOR_TOP 		0
#define CMDR_ACTION_PRIOR_HIGH 		1
#define CMDR_ACTION_PRIOR_LOW 		10

#define MAKE_AST_VAR(value) [value]
#define GET_AST_VAR(wrapper) (wrapper select 0)
#define SET_AST_VAR(wrapper, value) (wrapper set [0, value])
#define T_GET_AST_VAR(property) (T_GETV(property) select 0)
#define T_SET_AST_VAR(property, value) (T_GETV(property) set [0, value])

#define P_AST_VAR(paramNameStr) P_ARRAY(paramNameStr)
#define P_AST_STATE(paramNameStr) P_NUMBER(paramNameStr)