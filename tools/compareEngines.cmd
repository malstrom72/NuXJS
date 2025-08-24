@ECHO OFF
CD /D "%~dp0\.."
bash tools/compareEngines.sh %* || EXIT /b %ERRORLEVEL%
