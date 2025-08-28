@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

PUSHD %~dp0

SET target=%~1
SET model=%~2
IF "%target%"=="" SET target=debug
IF "%model%"=="" SET model=x64
IF "%CPP_OPTIONS%"=="" SET CPP_OPTIONS=/FS

REM Build PikaCmd and update stdlibJS.cpp
PUSHD ..\externals\PikaCmd
CALL .\BuildPikaCmd.cmd || GOTO error
POPD
..\externals\PikaCmd\PikaCmd.exe .\stdlibToCpp.pika ..\src\stdlib.js ..\src\stdlibJS.cpp || GOTO error

REM Optional dual-variant test mode (ES3 and ES5) — default OFF if not set
IF "%NUXJS_TEST_ES5_VARIANTS%"=="" SET NUXJS_TEST_ES5_VARIANTS=0
IF "%NUXJS_TEST_ES5_VARIANTS%"=="1" (
    IF /I "%target%"=="release" IF "%NUXJS_SKIP_RELEASE%"=="1" (
        ECHO Skipping release per NUXJS_SKIP_RELEASE=1
        POPD
        EXIT /b 0
    )

    SET CPP_OPTIONS_BASE=%CPP_OPTIONS%
    MKDIR ..\output >NUL 2>&1
    FOR %%E IN (0 1) DO (
        ECHO Building and testing with NUXJS_ES5=%%E (%target% %model%)
        SET CPP_OPTIONS=%CPP_OPTIONS_BASE% /DNUXJS_ES5=%%E
        IF /I "%target%"=="release" SET CPP_OPTIONS=/GR- %CPP_OPTIONS%
        CALL .\BuildCpp.cmd %target% %model% ..\output\NuXJSTest_%target%_%model%.exe .\NuXJSTest.cpp ..\src\NuXJS.cpp ..\src\stdlibJS.cpp || GOTO error
        ..\output\NuXJSTest_%target%_%model% -s >NUL 2>&1 || GOTO error
        ..\output\NuXJSTest_%target%_%model% || GOTO error
        CALL .\BuildCpp.cmd %target% %model% ..\output\NuXJS_%target%_%model%.exe .\NuXJSREPL.cpp ..\src\NuXJS.cpp ..\src\stdlibJS.cpp || GOTO error
        IF "%%E"=="1" (
            SET TEST_DIRS=..\tests\conforming ..\tests\erroneous ..\tests\es3only ..\tests\es5 ..\tests\extremes ..\tests\from262 ..\tests\migrated ..\tests\regression ..\tests\stdlib ..\tests\unconforming ..\tests\unsorted
        ) ELSE (
            SET TEST_DIRS=..\tests\conforming ..\tests\erroneous ..\tests\es3only ..\tests\extremes ..\tests\from262 ..\tests\migrated ..\tests\regression ..\tests\stdlib ..\tests\unconforming ..\tests\unsorted
        )
        ..\externals\PikaCmd\PikaCmd.exe .\test.pika -e -x ..\output\NuXJS_%target%_%model% %TEST_DIRS% || GOTO error
        CALL runExamples.cmd %target% || GOTO error
        ECHO Done NUXJS_ES5=%%E (%target% %model%)
    )
    ECHO Success!
    POPD
    EXIT /b 0
)

REM Default single-pass build and test
IF /I "%target%"=="release" SET CPP_OPTIONS=/GR- %CPP_OPTIONS%
MKDIR ..\output >NUL 2>&1
CALL .\BuildCpp.cmd %target% %model% ..\output\NuXJSTest_%target%_%model%.exe .\NuXJSTest.cpp ..\src\NuXJS.cpp ..\src\stdlibJS.cpp || GOTO error
..\output\NuXJSTest_%target%_%model% -s >NUL 2>&1 || GOTO error
..\output\NuXJSTest_%target%_%model% || GOTO error
CALL .\BuildCpp.cmd %target% %model% ..\output\NuXJS_%target%_%model%.exe .\NuXJSREPL.cpp ..\src\NuXJS.cpp ..\src\stdlibJS.cpp || GOTO error
REM Select test directories; include ES5 tests unless explicitly disabled with /DNUXJS_ES5=0
ECHO %CPP_OPTIONS% | FINDSTR /C:"/DNUXJS_ES5=0" >NUL
IF ERRORLEVEL 1 (
    SET TEST_DIRS=..\tests\conforming\ ..\tests\erroneous\ ..\tests\es3only\ ..\tests\es5\ ..\tests\extremes\ ..\tests\from262\ ..\tests\migrated\ ..\tests\regression\ ..\tests\stdlib\ ..\tests\unconforming\ ..\tests\unsorted
) ELSE (
    SET TEST_DIRS=..\tests\conforming\ ..\tests\erroneous\ ..\tests\es3only\ ..\tests\extremes\ ..\tests\from262\ ..\tests\migrated\ ..\tests\regression\ ..\tests\stdlib\ ..\tests\unconforming\ ..\tests\unsorted
)
..\externals\PikaCmd\PikaCmd.exe .\test.pika -e -x\ ..\output\NuXJS_%target%_%model% %TEST_DIRS% || GOTO error
CALL runExamples.cmd %target% || GOTO error
ECHO Success!
POPD
EXIT /b 0

:error
ECHO Error %ERRORLEVEL%
POPD
EXIT /b %ERRORLEVEL%
