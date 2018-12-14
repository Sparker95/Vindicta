// World Fact is a record about the world by some AI agent

#define WF_ID_TYPE					0
#define WF_ID_VALUE					1
#define WF_ID_RELEVANCE				2
#define WF_ID_SOURCE				3
#define WF_ID_POS					4
#define WF_ID_LAST_UPDATE_TIME		5
#define WF_ID_LIFETIME				6

#define WF_TYPE_DEFAULT				-1
#define WF_VALUE_DEFAULT			0
#define WF_RELEVANCE_DEFAULT		0
#define WF_SOURCE_DEFAULT			objNull
#define WF_POS_DEFAULT				0
#define WF_LAST_UPDATE_TIME_DEFAULT time
#define WF_LIFETIME_DEFAULT			0

#define WF_VALUE_TYPES [0, objNull, "", []]
#define WF_SOURCE_TYPES [objNull, ""]

#define WF_NEW() [WF_TYPE_DEFAULT, WF_VALUE_DEFAULT, WF_RELEVANCE_DEFAULT, WF_SOURCE_DEFAULT ,WF_POS_DEFAULT, WF_LAST_UPDATE_TIME_DEFAULT, WF_LIFETIME_DEFAULT]


// Macros for getting values

#define WF_GET_RELEVANCE(_wf) _wf select WF_ID_RELEVANCE
#define WF_GET_TYPE(_wf) _wf select WF_ID_TYPE
#define WF_GET_VALUE(_wf) _wf select WF_ID_VALUE
#define WF_GET_SOURCE(_wf) _wf select WF_ID_SOURCE
// todo finish it
/*
#define WF_GET_XXX(_wf) _wf select WF_ID_XXX
#define WF_GET_XXX(_wf) _wf select WF_ID_XXX
#define WF_GET_XXX(_wf) _wf select WF_ID_XXX
#define WF_GET_XXX(_wf) _wf select WF_ID_XXX
#define WF_GET_XXX(_wf) _wf select WF_ID_XXX
*/

// Macros for setting values


/*
wf_fnc_setXXX = {
	params [["_fact", [], [[]]], ["_XXX", 0, [WF_XXX_DEFAULT]] ];
	_fact set [WF_ID_XXX, _XXX];
};*/