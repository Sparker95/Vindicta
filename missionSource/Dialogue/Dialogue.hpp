// ---- Dialogue state ----
// This is state of the whole dialogue
// Running
#define DIALOGUE_STATE_RUN					0
// Waiting for sentence to end
#define DIALOGUE_STATE_WAIT_SENTENCE_END	1
// Dialogue has finished, the dialogue object can be disposed
#define DIALOGUE_STATE_END					2
// Waiting for client to respond to options
#define DIALOGUE_STATE_WAIT_OPTION			3

// Time it takes to say this sentence
#define SENTENCE_DURATION(SENTENCE) (count (SENTENCE) / 50.0 + 0.7)
//#define SENTENCE_DURATION(SENTENCE) 0.5

// Macro to find node with given tag
// Returns -1 if not found
#define FIND_NODE(nodes, tag) (nodes findIf {(_x select NODE_ID_TAG) == tag})

// Dialogue distance
// Dialogue continues while distance is below this
#define DIALOGUE_DISTANCE 8.0

// Hearing distance
// We can hear sentences if we are closer than this distance
#define SENTENCE_HEAR_DISTANCE 12.0 

// Talker IDs
#define TALKER_0		0
#define TALKER_1		1
#define TALKER_NPC		0
#define TALKER_PLAYER	1

// Macros for dialogue nodes

// Node structure
// One of node types (see below)
#define NODE_ID_TYPE	0
// Optional tag of this node
#define NODE_ID_TAG		1
// The rest depends on specific node type

// Node types
// Someone says something
#define NODE_TYPE_SENTENCE	"SENT"
// Someone says something, text resolved from method name
#define NODE_TYPE_SENTENCE_METHOD "SENT_METHOD"
// Unconditional jump to another node
#define NODE_TYPE_JUMP		"JUMP"
// Unconditional jump to another node and push current address to stack
#define NODE_TYPE_CALL		"CALL"
// Returns to address which is in the stack
#define NODE_TYPE_RETURN	"RET"
// Performs JUMP if called method returns true
#define NODE_TYPE_JUMP_IF "JUMPIF"
// Performs CALL if called method returns true
#define NODE_TYPE_CALL_IF "CALLIF"
// Display options to player
#define NODE_TYPE_OPTIONS	"OPTS"
// One variant of options to be selected
#define NODE_TYPE_OPTION	"OPT"
// Calls method of this dialogue object
#define NODE_TYPE_CALL_METHOD "CALLM"
// Ends this dialogue
#define NODE_TYPE_END "END"

// === PUBLIC MACROS BELOW ===

// Macros for nodes
#define NODE_SENTENCE(tag, talker, text)				[NODE_TYPE_SENTENCE,	tag,	talker,			text]
#define NODE_SENTENCE_METHOD(tag, talker, method)		[NODE_TYPE_SENTENCE_METHOD,	tag,	talker,			"", method]
#define NODE_JUMP(tag, tagNext)							[NODE_TYPE_JUMP,		tag,	tagNext]
#define NODE_JUMP_IF(tag, tagNext, method, args)		[NODE_TYPE_JUMP_IF,		tag,	tagNext, method, args]
#define NODE_CALL(tag, tagNext)							[NODE_TYPE_CALL,		tag,	tagNext]
#define NODE_CALL_IF(tag, tagNext,  method, args)		[NODE_TYPE_CALL_IF,		tag,	tagNext, method, args]
#define NODE_OPTIONS(tag, optionsArray)					[NODE_TYPE_OPTIONS,		tag,	optionsArray]
#define NODE_OPTION(tag, text)							[NODE_TYPE_OPTION,		tag,	TALKER_PLAYER,	text]
#define NODE_CALL_METHOD(tag, method, args)				[NODE_TYPE_CALL_METHOD,	tag,	method, args]
#define NODE_RETURN(tag)								[NODE_TYPE_RETURN,		tag]
#define NODE_END(tag)									[NODE_TYPE_END, tag]

// Setters for various values
#define NODE_SET_TAG(node, tag)	node set [1, tag]
#define NODE_SET_TEXT(node, text) node set [3, text]

// Event node tags
#define NODE_TAG_EVENT_AWAY			"EVENT_AWAY"
#define NODE_TAG_EVENT_NOT_ALIVE	"EVENT_NOT_ALIVE"