@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
PUSHD %~dp0\..
IF NOT EXIST output mkdir output
SET target=%~1
IF "%target%"=="" SET target=debug
SET fail=0
FOR %%F IN (examples\*.cpp) DO (
    SET name=%%~nF
    ECHO Building %%F
    CALL tools\BuildCpp.cmd %target% output\!name! %%F src\NuXJScript.cpp src\stdlibJS.cpp || SET fail=1
    IF !fail! EQU 0 (
        ECHO Running !name!
        output\!name!.exe > output\!name!.log 2>&1
        IF ERRORLEVEL 1 (
            ECHO !name! failed
            TYPE output\!name!.log
            SET fail=1
        ) ELSE (
            IF EXIST examples\expected_!name!.txt (
                FC examples\expected_!name!.txt output\!name!.log >NUL
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
