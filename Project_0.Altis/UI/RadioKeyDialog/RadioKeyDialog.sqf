#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\..\OOP_Light\OOP_Light.h"

CLASS("RadioKeyDialog", "DialogBase")

	METHOD("new") {
		params [P_THISOBJECT];

		T_CALLM2("addTab", "RadioKeyTab", "");
		
		T_CALLM1("enableMultiTab", false);
		T_CALLM1("setCurrentTab", 0);
		T_CALLM2("setContentSize", 0.7, 1.0);
		T_CALLM1("setHeadlineText", "Manage radio cryptokeys");
		T_CALLM1("setHintText", "Check enemy tablets to find their radio cryptokeys");

	} ENDMETHOD;

ENDCLASS;