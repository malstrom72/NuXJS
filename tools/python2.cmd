@ECHO OFF
REM Lightweight shim to the repo's portable Python 2 interpreter
REM Works from any caller directory if the repo's tools/ is on PATH.

"%~dp0..\output\python2\env\python.exe" %*

