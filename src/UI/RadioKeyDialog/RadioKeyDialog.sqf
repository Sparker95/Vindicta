#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\..\common.h"

#define OOP_CLASS_NAME RadioKeyDialog
CLASS("RadioKeyDialog", "DialogBase")

	METHOD(new)
		params [P_THISOBJECT];

		T_CALLM2("addTab", "RadioKeyTab", "");
		
		T_CALLM1("enableMultiTab", false);
		T_CALLM2("setContentSize", 0.7, 1.0);
		T_CALLM1("setCurrentTab", 0);
		T_CALLM1("setHeadlineText", localize "STR_RKD_MANAGE_KEYS");
		T_CALLM1("setHintText", localize "STR_RKD_HINT");

	ENDMETHOD;

ENDCLASS;