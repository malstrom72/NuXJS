@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
CD /D "%~dp0\.."

IF NOT EXIST output\examples mkdir output\examples
SET target=%~1
IF "%target%"=="" SET target=debug
SET exe=output\examples\examples.exe

ECHO Building examples
CALL tools\BuildCpp.cmd %target% %exe% examples\examples.cpp src\NuXJS.cpp src\stdlibJS.cpp || GOTO error

ECHO Running examples
%exe% > output\examples\all.log 2>&1 || GOTO error

IF EXIST examples\expected_examples.txt (
        FC examples\expected_examples.txt output\examples\all.log || GOTO error
)

EXIT /B 0
:error
EXIT /B %ERRORLEVEL%
