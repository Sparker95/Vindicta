#include "..\defineCommon.inc"

#define STRING_ICON_UP_ARROW "\a3\ui_f\data\IGUI\Cfg\Actions\arrow_up_gs.paa"

#define FLOAT_POS_Y  (1)
#define FLOAT_DISPLAYTIME  6.66                                                             //how long the message stays on the screen
#define FLOAT_ICON_WITDH  0.2

#define ARRAY_TEXT_STEPSIZE 0.05                                                            //distance between sentences
#define ARRAY_TEXT_POS_START [0,1-safeZoneY-ARRAY_TEXT_STEPSIZE,1,ARRAY_TEXT_STEPSIZE]      //start position of sentences
#define INT_MAX_LINES_DIALOGUE 7                                                            //how many lines of dialogue are max. shown at ones
#define FLOAT_TEXT_SCROLL_SPEED 0.666                                                       //how fast does the text move up