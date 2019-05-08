#define OOP_INFO
#define OOP_ERROR
#define OOP_WARNING
#define OFSTREAM_FILE "GameMode.rpt"

#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "..\CriticalSection\CriticalSection.hpp"
#include "..\AI\Commander\AICommander.hpp"
#include "..\AI\Commander\LocationData.hpp"

#define IS_HEADLESSCLIENT (!hasInterface && !isDedicated)
