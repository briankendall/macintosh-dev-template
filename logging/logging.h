#ifndef LOGGING_H
#define LOGGING_H

#define INCLUDE_LOGGING 1

#include <Types.h>

#if INCLUDE_LOGGING

void InitializeLogging();
void DeinitializeLogging();
void printLog(const char *str, ...);

#else

#define InitializeLogging()
#define DeinitializeLogging()
#define printLog

#endif

#endif
