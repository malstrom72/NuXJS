@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
CD /D "%~dp0\.."
IF "%CPP_COMPILER%"=="" SET "CPP_COMPILER=clang++"
IF NOT EXIST output mkdir output
"%CPP_COMPILER%" -std=c++17 -DLIBFUZZ -fsanitize=fuzzer,address tools\NuXJSREPL.cpp src\NuXJS.cpp src\stdlibJS.cpp -o output\NuXJSFuzz.exe
IF ERRORLEVEL 1 GOTO error
EXIT /b 0
:error
EXIT /b %ERRORLEVEL%
