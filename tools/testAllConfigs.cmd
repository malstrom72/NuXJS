@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

PUSHD %~dp0

CALL buildAndTest.cmd debug x86 || GOTO :error
CALL buildAndTest.cmd debug x64 || GOTO :error
CALL buildAndTest.cmd debug arm64 || GOTO :error
CALL buildAndTest.cmd release x86 || GOTO :error
CALL buildAndTest.cmd release x64 || GOTO :error
CALL buildAndTest.cmd release arm64 || GOTO :error

ECHO Success!
POPD
EXIT /B 0

:error
ECHO Error %ERRORLEVEL%
POPD
EXIT /B %ERRORLEVEL%
