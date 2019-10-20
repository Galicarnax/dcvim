#pragma comment(lib, "user32.lib") 

// avoid console popup
#pragma comment(linker, "/SUBSYSTEM:windows /ENTRY:mainCRTStartup")

#include <windows.h>

int main(int argc, char const *argv[])
{
    if (argc < 2)
    {
        return 0;
    }

    INPUT ip;

    ip.type = INPUT_KEYBOARD;
    ip.ki.wScan = 0;
    ip.ki.time = 0;
    ip.ki.dwExtraInfo = 0;

    if (!strcmp(argv[1], "Up")) ip.ki.wVk = VK_UP;
    else if (!strcmp(argv[1], "Down")) ip.ki.wVk = VK_DOWN;
    else if (!strcmp(argv[1], "Left")) ip.ki.wVk = VK_LEFT;
    else if (!strcmp(argv[1], "Right")) ip.ki.wVk = VK_RIGHT;
    else if (!strcmp(argv[1], "Enter")) ip.ki.wVk = VK_RETURN;
    else if (!strcmp(argv[1], "PageUp")) ip.ki.wVk = VK_PRIOR;
    else if (!strcmp(argv[1], "PageDown")) ip.ki.wVk = VK_NEXT;
    else if (!strcmp(argv[1], "Home")) ip.ki.wVk = VK_HOME;
    else if (!strcmp(argv[1], "End")) ip.ki.wVk = VK_END;
    else
    {
        return 0;
    }

    ip.ki.dwFlags = 0; // 0 for key press
    
    int n = 1;
    if (argc == 3) n = atoi(argv[2]);

    for (int i = 0; i < n; ++i)
    {
        SendInput(1, &ip, sizeof(INPUT));
        if (i != n - 1) Sleep(10);
    }

    // Release the key
    ip.ki.dwFlags = KEYEVENTF_KEYUP;
    SendInput(1, &ip, sizeof(INPUT));

    return 0;
}
