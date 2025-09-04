@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

CD /D "%~dp0\.."

SET branch=main
IF "%1"=="--branch" (
SET branch=%2
SHIFT
SHIFT
)

SET remove=
FOR %%i IN (%*) DO (
IF "%%i"=="--remove" SET remove=1
)

IF DEFINED remove (
CALL python tools\diffguard.py NUXJS_ES5 --remove src\NuXJS.cpp src\NuXJS.cpp || GOTO error
CALL python tools\diffguard.py NUXJS_ES5 --remove src\NuXJS.h src\NuXJS.h || GOTO error
EXIT /b 0
)

SET tmp_cpp=%TEMP%\es5guard_cpp.tmp
SET tmp_h=%TEMP%\es5guard_h.tmp

git show %branch%:src/NuXJS.cpp > "%tmp_cpp%" || GOTO error
git show %branch%:src/NuXJS.h > "%tmp_h%" || GOTO error

CALL python tools\diffguard.py NUXJS_ES5 %* "%tmp_cpp%" src\NuXJS.cpp src\NuXJS.cpp || GOTO error
CALL python tools\diffguard.py NUXJS_ES5 %* "%tmp_h%" src\NuXJS.h src\NuXJS.h || GOTO error

DEL "%tmp_cpp%"
DEL "%tmp_h%"
EXIT /b 0
:error
EXIT /b %ERRORLEVEL%

