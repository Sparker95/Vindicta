#include "../../common.hpp"

/*
Class: AI.CmdrAI.CmdrStrategy.Strategies.PassiveCmdrStrategy

Commander does nothing ever.
Parent: <AI.CmdrAI.CmdrStrategy.CmdrStrategy>
*/
#define OOP_CLASS_NAME PassiveCmdrStrategy
CLASS("PassiveCmdrStrategy", "CmdrStrategy")

	METHOD(new)
		params [P_THISOBJECT];
		// Do not take outposts
		T_SETV("takeLocOutpostPriority", 0);
		T_SETV("takeLocOutpostCoeff", 0);
		// Do not take bases
		T_SETV("takeLocBasePriority", 0);
		T_SETV("takeLocBaseCoeff", 0);
		// Do not take roadblocks
		T_SETV("takeLocRoadBlockPriority", 0);
		T_SETV("takeLocRoadBlockCoeff", 0);
		// Do not take cities
		T_SETV("takeLocCityPriority", 0);
		T_SETV("takeLocCityCoeff", 0);
	ENDMETHOD;

	public override METHOD(getQRFScore)
		params [P_THISOBJECT,
			P_OOP_OBJECT("_action"), 
			P_ARRAY("_defaultScore"),
			P_OOP_OBJECT("_worldNow"),
			P_OOP_OBJECT("_worldFuture"),
			P_OOP_OBJECT("_srcGarr"),
			P_OOP_OBJECT("_tgtCluster"),
			P_ARRAY("_detachEff")];
		// Do no QRFs
		APPLY_SCORE_STRATEGY(_defaultScore, 0)
	ENDMETHOD;

	public override METHOD(getReinforceScore)
		params [P_THISOBJECT,
			P_OOP_OBJECT("_action"), 
			P_ARRAY("_defaultScore"),
			P_OOP_OBJECT("_worldNow"),
			P_OOP_OBJECT("_worldFuture"),
			P_OOP_OBJECT("_srcGarr"),
			P_OOP_OBJECT("_tgtGarr"),
			P_ARRAY("_detachEff")];
		// Do no reinforcing! 
		APPLY_SCORE_STRATEGY(_defaultScore, 0)
	ENDMETHOD;

	public override METHOD(getTakeLocationScore)
		params [P_THISOBJECT,
			P_OOP_OBJECT("_action"), 
			P_ARRAY("_defaultScore"),
			P_OOP_OBJECT("_worldNow"),
			P_OOP_OBJECT("_worldFuture"),
			P_OOP_OBJECT("_srcGarr"),
			P_OOP_OBJECT("_tgtLoc"),
			P_ARRAY("_detachEff")];
		// Take no locations!
		APPLY_SCORE_STRATEGY(_defaultScore, 0)
	ENDMETHOD;
ENDCLASS;

// Unit test
#ifdef _SQF_VM
#endif