@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

PUSHD %~dp0

SET tmp=%TEMP%\nuxjs_test%RANDOM%.cpp
ECHO int main() { return 0; } > "%tmp%"

SET fail=0

CALL :testModel x86
CALL :testModel x64
CALL :testModel arm64

DEL "%tmp%" >NUL 2>&1

IF %fail% EQU 0 (
ECHO Success!
POPD
EXIT /B 0
) ELSE (
GOTO error
)

:error
ECHO Error %ERRORLEVEL%
POPD
EXIT /B %ERRORLEVEL%

:testModel
CALL BuildCpp.cmd debug %1 %TEMP%\nuxjs_model.exe "%tmp%" >NUL 2>&1
IF ERRORLEVEL 1 (
ECHO Skipping %1 - compiler not available
EXIT /B 0
)
DEL %TEMP%\nuxjs_model.exe >NUL 2>&1
CALL buildAndTest.cmd debug %1 || SET fail=1
CALL buildAndTest.cmd release %1 || SET fail=1
EXIT /B 0
