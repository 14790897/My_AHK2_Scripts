@echo off
echo Compiling WindowIMEMemory.ahk...
"C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in "WindowIMEMemory.ahk" /out "WindowIMEMemory.exe" /base "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
if exist "WindowIMEMemory.exe" (
    echo Compilation successful!
    dir WindowIMEMemory.exe
) else (
    echo Compilation failed!
)
pause
