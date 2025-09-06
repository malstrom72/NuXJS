@ECHO OFF
CD /D "%~dp0\.."
node tools\testdash.node.js --cli %*
IF ERRORLEVEL 1 GOTO error
EXIT /b 0
:error
EXIT /b %ERRORLEVEL%
