@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
PUSHD %~dp0\..
IF NOT EXIST output\examples mkdir output\examples
SET target=%~1
IF "%target%"=="" SET target=debug
SET fail=0
FOR %%F IN (examples\*.cpp) DO (
    SET name=%%~nF
    ECHO Building %%F
    CALL tools\BuildCpp.cmd %target% output\examples\!name! %%F src\NuXJScript.cpp src\stdlibJS.cpp || SET fail=1
    IF !fail! EQU 0 (
        ECHO Running !name!
        output\examples\!name!.exe > output\examples\!name!.log 2>&1
        IF ERRORLEVEL 1 (
            ECHO !name! failed
            TYPE output\examples\!name!.log
            SET fail=1
        ) ELSE (
            IF EXIST examples\expected_!name!.txt (
                FC examples\expected_!name!.txt output\examples\!name!.log >NUL
                IF ERRORLEVEL 1 (
                    ECHO !name! output mismatch
                    SET fail=1
                ) ELSE (
                    ECHO !name! ok
                )
            ) ELSE (
                ECHO !name! ok (no expected output)
            )
        )
    )
)
POPD
EXIT /B %fail%
