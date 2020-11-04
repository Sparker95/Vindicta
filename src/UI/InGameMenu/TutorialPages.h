#define QUOTE(value) #value
#define __TUT_IMAGE(imagename) QUOTE(\z\vindicta\addons\ui\pictures\imagename)

class TutorialPages
{
	// base class, default page
	class TutBasePage 
	{
		textHeadline = $STR_TUTORP_HEADLINE;
		text = $STR_TUTORP_HEADLINE_DESC;
		imagePath = __TUT_IMAGE(tut_image_default.paa);
	};

	class TutPage_AddInfo : TutBasePage
	{
		textHeadline = $STR_TUTORP_LINKS;
		text = $STR_TUTORP_LINKS_DESC;
	};

	class TutPage_Intro : TutBasePage
	{
		textHeadline = $STR_TUTORP_INTRO;
		text = $STR_TUTORP_INTRO_DESC;
		imagePath = __TUT_IMAGE(tut_scenario.paa);
	};

	class TutPage_StepByStep1 : TutBasePage
	{
		textHeadline = $STR_TUTORP_QUICK_I;
		text = $STR_TUTORP_QUICK_I_DESC;
		imagePath = __TUT_IMAGE(tut_scenario.paa);
	};

	class TutPage_StepByStep2 : TutBasePage
	{
		textHeadline = $STR_TUTORP_QUICK_II;
		text = $STR_TUTORP_QUICK_II_DESC;
		imagePath = __TUT_IMAGE(tut_scenario.paa);
	};

	class TutPage_StepByStep3 : TutBasePage
	{
		textHeadline = $STR_TUTORP_QUICK_III;
		text = $STR_TUTORP_QUICK_III_DESC;
		imagePath = __TUT_IMAGE(tut_scenario.paa);
	};

	class TutPage_StepByStep4 : TutBasePage
	{
		textHeadline = $STR_TUTORP_QUICK_IV;
		text = $STR_TUTORP_QUICK_IV_DESC;
		imagePath = __TUT_IMAGE(tut_scenario.paa);
	};

	class TutPage_StepByStep5 : TutBasePage
	{
		textHeadline = $STR_TUTORP_QUICK_V;
		text = STR_TUTORP_QUICK_V_DESC$;
		imagePath = __TUT_IMAGE(tut_scenario.paa);
	};

	class TutPage_setup : TutBasePage
	{
		textHeadline = $STR_TUTORP_SETUP;
		text = $STR_TUTORP_SETUP_DESC;
	};

	class TutPage0 : TutBasePage
	{
		textHeadline = $STR_TUTORP_RESPAWN;
		text = $STR_TUTORP_RESPAWN_DESC;
	};

	class TutPage_campaignProgress : TutBasePage
	{
		textHeadline = $STR_TUTORP_PROGRESS;
		text = $STR_TUTORP_PROGRESS_DESC;
	};

	class TutPageUndercover_1 : TutBasePage
	{
		textHeadline = $STR_TUTORP_UNDERCOVER_I;
		text = $STR_TUTORP_UNDERCOVER_I_DESC;
		imagePath = __TUT_IMAGE(tut_undercover.paa);

	};

	class TutPageUndercover_2 : TutBasePage
	{
		textHeadline = $STR_TUTORP_UNDERCOVER_II;
		text = $STR_TUTORP_UNDERCOVER_II_DESC;
		imagePath = __TUT_IMAGE(tut_undercover.paa);

	};

	class TutPage2 : TutBasePage
	{
		textHeadline = $STR_TUTORP_INTEL_I;
		text = $STR_TUTORP_INTEL_I_DESC;
		imagePath = __TUT_IMAGE(tut_policeStations.paa);

	};

	class TutPage3 : TutBasePage
	{
		textHeadline = $STR_TUTORP_INTEL_II;
		text = $STR_TUTORP_INTEL_II_DESC;
		imagePath = __TUT_IMAGE(tut_civis.paa);
	};

	class TutPage4 : TutBasePage
	{
		textHeadline = $STR_TUTORP_CRYPTO;
		text = $STR_TUTORP_CRYPTO_DESC;
		imagePath = __TUT_IMAGE(tut_radio.paa);
	};

	class TutPageClaiming : TutBasePage
	{
		textHeadline = $STR_TUTORP_CLAIMING;
		text = $STR_TUTORP_CLAIMING_DESC;
		imagePath = __TUT_IMAGE(tut_construction.paa);
	};

	class TutPage5 : TutBasePage
	{
		textHeadline = $STR_TUTORP_CAMPS;
		text = $STR_TUTORP_CAMPS_DESC;
		imagePath = __TUT_IMAGE(tut_construction.paa);
	};

	class TutPage6 : TutBasePage
	{
		textHeadline = $STR_TUTORP_BUILD;
		text = $STR_TUTORP_BUILD_DESC;
		imagePath = __TUT_IMAGE(tut_construction.paa);
	};

	class TutPage7 : TutBasePage
	{
		textHeadline = $STR_TUTORP_ARSENAL;
		text = $STR_TUTORP_ARSENAL_DESC;
	};

	class TutPage8 : TutBasePage
	{
		textHeadline = $STR_TUTORP_CAPACITY;
		text = $STR_TUTORP_CAPACITY_DESC;
	};

	class TutPage9 : TutBasePage
	{
		textHeadline = $STR_TUTORP_COMMAND;
		text = $STR_TUTORP_COMMAND_DESC;
		imagePath = __TUT_IMAGE(tut_high_command.paa);
	};

	class TutPage10 : TutBasePage
	{
		textHeadline = $STR_TUTORP_SAVELOAD;
		text = $STR_TUTORP_SAVELOAD_DESC;
	};

	class TutPage11 : TutBasePage
	{
		textHeadline = $STR_TUTORP_ISSUES;
		text = $STR_TUTORP_ISSUES_DESC;
		imagePath = __TUT_IMAGE(tut_limits.paa);
	};
	
};
