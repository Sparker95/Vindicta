#include "..\defineCommon.inc"



//---------------------------------
//      Converstion types
//---------------------------------

#define TYPE_CREATE 0
#define TYPE_OVERWRITE 1
#define TYPE_INHERIT 2

//---------------------------------
//      Node types
//---------------------------------

#define TYPE_SENTENCE 10
#define TYPE_SENTENCE_SILENECE 11

#define TYPE_QUESTION 20
#define TYPE_QUESTION_SILENECE 21
#define TYPE_ANSWER 22
#define TYPE_ANSWER_SILENECE 23
#define TYPE_ANSWER_AI 24
#define TYPE_REMOVE_ANSWER 25

#define TYPE_JUMP_TO 30

//---------------------------------
//      Event types
//---------------------------------

#define TYPE_ON_WALKED_AWAY 40
#define TYPE_ON_OUT_OF_TIME 41
#define TYPE_ON_DEATH 42
#define TYPE_ON_END 43
#define TYPE_ON_UNEXPECTED_END 44


//---------------------------------
//      settings
//---------------------------------

#define STRING_ICON_UP_ARROW "\a3\ui_f\data\IGUI\Cfg\Actions\arrow_up_gs.paa"

#define STRING_QUESTION_RETURN_EVENT "dialogue_question_return"

//general settings
#define FLOAT_MAX_LISTENING_DISTANCE 20.0           // how far you can hear the conversation
#define FLOAT_MAX_LEAVING_DISTANCE 10.0             // cancel conversation if you go further then this
#define FLOAT_MAX_LEAVING_DISTANCE_QUESTION 6.0    // cancel question if you go further then this
#define FLOAT_MAX_WAIT_FOR_ANSWER 7.0               // cancel question if you wait longer then this 
#define FLOAT_TIME_INCREASE_SENTENCE_LIMIT 5.0     // If player is talking the dialogue gets bigger for this amount of time
#define FLOAT_SPEACH_TIME(SENTENCE) (count (SENTENCE) / 40.0 + 0.7)

//HUD settings
#define FLOAT_TEXT_HIGHT 0.04
#define FLOAT_POS_Y  (1 - safezoney-0.2)
#define FLOAT_DISPLAYTIME  7
#define FLOAT_FADE_TIME  1
#define FLOAT_SCROLL_TIME  0.05
#define FLOAT_ICON_WITDH  0.2
#define INT_SENTENCE_LIMIT 3
#define INT_SENTENCE_LIMIT_PLAYER_INVOLVED 6


//used only internaly

#define DEFAULT_EVENT_TYPES [TYPE_ON_WALKED_AWAY,TYPE_ON_OUT_OF_TIME,TYPE_ON_DEATH,TYPE_ON_UNEXPECTED_END]

#define TYPE_ON_END_OVERWRITE 30
#define INHERIT_TYPES [TYPE_ANSWER_AI,TYPE_JUMP_TO,TYPE_ON_WALKED_AWAY,TYPE_ON_OUT_OF_TIME,TYPE_ON_DEATH,TYPE_ON_UNEXPECTED_END,TYPE_ON_END_OVERWRITE]


#define SILENCE_TYPES [TYPE_SENTENCE_SILENECE,TYPE_QUESTION_SILENECE,TYPE_ANSWER_SILENECE]


//events used internaly
#define TYPE_EVENT_WALKED_AWAY 0                    // when you walk a way to far
#define TYPE_EVENT_OUT_OF_TIME 1                    // when waiting to long
#define TYPE_EVENT_DEATH 2                         // when unit gets killed or unconciuos
#define TYPE_EVENT_UNEXPECTED_END 3                 // when conversation ends without reaching #end (same as the other events combined)
#define TYPE_EVENT_ERROR 4
#define EVENT_TYPES [TYPE_EVENT_WALKED_AWAY,TYPE_EVENT_OUT_OF_TIME,TYPE_EVENT_DEATH,TYPE_EVENT_UNEXPECTED_END,TYPE_EVENT_ERROR]

#define INDEX_SENTENCE_TEXT 0
#define INDEX_SENTENCE_SILENCE 1
#define INDEX_SENTENCE_SPEAKER 2
#define INDEX_SENTENCE_LISTENER 3
#define INDEX_SENTENCE_LOUDNESS 4
#define INDEX_SENTENCE_SCRIPT 5
#define INDEX_SENTENCE_ARGS 6

#define INDEX_ANSWER_JUMP 0
#define INDEX_ANSWER_SCRIPT 1
#define INDEX_ANSWER_ARGS 2
#define INDEX_ANSWER_TEXT 3
#define INDEX_ANSWER_NR 4
