#define OOP_INFO
#define OOP_ERROR
#define OOP_WARNING
#define OFSTREAM_FILE "AI.rpt"
#define PROFILER_COUNTERS_ENABLE
#include "..\..\common.h"

/*
This class contains virtual methods a GOAP agent must implement.
*/

#define OOP_CLASS_NAME GOAP_Agent
CLASS("GOAP_Agent", "")

	public virtual METHOD(getAI)
		params [P_THISOBJECT];
		OOP_ERROR_0("getAI is not implemented!");
		NULL_OBJECT
	ENDMETHOD;

	public virtual METHOD(getSubagents)
		params [P_THISOBJECT];
		OOP_ERROR_0("getSubagents is not implemented!");
		[]
	ENDMETHOD;

ENDCLASS;