// Macros for doing things with world state
#define WS_SET(ws, id, value) ((ws select 0) set [id, value])
#define WS_GET(ws, id) ((ws select 0) select id)