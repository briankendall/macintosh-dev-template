#include <Dialogs.h>

#include "logging.h"

static void InitToolbox()
{
    InitGraf(&qd.thePort);
    InitFonts();
    InitWindows();
    InitMenus();
    TEInit();
    InitDialogs( 0L );
    FlushEvents(everyEvent, 0);
    InitCursor();
}

int main(void)
{
    InitToolbox();
    InitializeLogging();
    
    printLog("Hello world from the console!\n");
    
	ParamText("\pHello world!", NULL, NULL, NULL);
	Alert(128, 0L);
    
    DeinitializeLogging();
    return 0;
}
