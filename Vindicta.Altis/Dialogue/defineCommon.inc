#include "..\defineCommon.inc"

#define STRING_ICON_UP_ARROW "\a3\ui_f\data\IGUI\Cfg\Actions\arrow_up_gs.paa"


//general settings
#define FLOAT_MAX_LISTENING_DISTANCE 20.0           // how far you can hear the conversation
#define FLOAT_MAX_LEAVING_DISTANCE 8.0             // cancel conversation if you go further then this
#define FLOAT_MAX_LEAVING_QUESTION_DISTANCE 5.0    // cancel question if you go further then this
#define FLOAT_MAX_WAIT_FOR_ANSWER 7.0               // cancel question if you wait longer then this 


//HUD settings
#define FLOAT_TEXT_HIGHT 0.04
#define FLOAT_POS_Y  (1 - safezoney-0.2)
#define FLOAT_DISPLAYTIME  7
#define FLOAT_FADE_TIME  1
#define FLOAT_SCROLL_TIME  0.05
#define FLOAT_ICON_WITDH  0.2
#define INT_SENTENCE_LIMIT 3
#define INT_SENTENCE_LIMIT_PLAYER_INVOLVED 6

//Converstion types
#define TYPE_CREATE 0
#define TYPE_OVERWRITE 1
#define TYPE_INHERIT 2

#define TYPE_SENTENCE 10
#define TYPE_SENTENCE_SILENECE 11
#define TYPE_QUESTION 12
#define TYPE_QUESTION_SILENECE 13
#define TYPE_ANSWER 14
#define TYPE_ANSWER_AI 15
#define TYPE_REMOVE_ANSWER 16
#define TYPE_JUMP_TO 17


#define SENTENCE_TYPES [TYPE_SENTENCE_SILENECE,TYPE_QUESTION_SILENECE,TYPE_ANSWER_SILENECE]

#define TYPE_EVENT_WALKED_AWAY 5        // when you walk a way to far
#define TYPE_EVENT_OUT_OF_TIME 6        // when waiting to long
#define TYPE_EVENT_DEATH 7              // when unit gets killed or unconciuos
#define TYPE_EVENT_UNEXPECTED_END 8     // when conversation ends without reaching #end (same as the other events combined)
#define TYPE_EVENT_END 9                // when conversation ends (always)
#define EVENT_TYPES [TYPE_EVENT_WALKED_AWAY,TYPE_EVENT_OUT_OF_TIME,TYPE_EVENT_DEATH,TYPE_EVENT_UNEXPECTED_END,TYPE_EVENT_END]

#define INHERIT_TYPES ([TYPE_JUMP_TO,TYPE_ANSWER,TYPE_REMOVE_ANSWER] + EVENT_TYPES)


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

#define INDEX_EVENT_JUMP 0
#define INDEX_EVENT_SCRIPT 1
#define INDEX_EVENT_ARGS 2

