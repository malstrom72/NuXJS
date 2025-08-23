@ECHO OFF
CD /D "%~dp0\.."
bash tools/runBenchmarks.sh %* || EXIT /b %ERRORLEVEL%
