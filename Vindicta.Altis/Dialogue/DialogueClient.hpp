// Amount of time it takes a sentence to move
#define DIALOGUE_CLIENT_SENTENCE_ANIMATION_DURATION 0.05

//#define SENTENCE_TEXT_SIZE	(0.04*safeZoneH)
//#define SENTENCE_ROW_SIZE (SENTENCE_TEXT_SIZE + safeZoneH*0.005)

// Coordinates of the box with sentences
#define DIALOGUE_BOX_WIDTH	(0.7*safezoneW)
#define DIALOGUE_BOX_HEIGHT	(0.33*safezoneH)
#define DIALOGUE_BOX_X		(0.5 - 0.5*DIALOGUE_BOX_WIDTH)
#define DIALOGUE_BOX_Y		(safezoney + 0.86*safezoneh - DIALOGUE_BOX_HEIGHT)

// Area of pointers
#define DIALOGUE_POINTER_AREA_X	0.5
#define DIALOGUE_POINTER_AREA_Y (safeZoneY + 0.9*safeZoneH)

// Pointer icon size
#define DIALOGUE_POINTER_WIDTH 0.4
#define DIALOGUE_POINTER_HEIGHT 0.2

// Gap used for various calculations
#define DIALOGUE_GAP (0.005*safeZoneH)

// Vertical gap between lines
#define DIALOGUE_LINE_GAP (0.005*safeZoneH)

// Types of line
// Someone said something
#define LINE_TYPE_SENTENCE	0
// One of options we must choose
#define LINE_TYPE_OPTION	1

// Gets control height
#define CONTROL_HEIGHT(ctrl) ((ctrlPosition ctrl) select 3)
#define CONTROL_POS_X(ctrl) ((ctrlPosition ctrl) select 0)
#define CONTROL_POS_Y(ctrl) ((ctrlPosition ctrl) select 1)

// Enables coloured backgrounds for control elements for easier layour
//#define DIALOGUE_LAYOUT_DEBUG