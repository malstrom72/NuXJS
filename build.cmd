@ECHO OFF

SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION



SET target=%1

SET model=%2

IF "%target%"=="" SET target=release

IF "%model%"=="" SET model=native



CALL tools\buildAndTest.cmd %target% %model% || GOTO error

IF EXIST output\NuXJScript_%target%_%model%.exe (

	MOVE /Y output\NuXJScript_%target%_%model%.exe output\NuXJScript.exe >NUL

)

EXIT /b 0



:error

EXIT /b %ERRORLEVEL%

