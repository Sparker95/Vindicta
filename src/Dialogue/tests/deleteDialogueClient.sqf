#include "..\common.hpp"

pr _instance = CALLSM0("DialogueClient", "getInstance");
DELETE(_instance);
SETSV("DialogueClient", "instance", NULL_OBJECT);