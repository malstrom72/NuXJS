@ECHO OFF
REM Setup Python 2 using conda in a portable way (Windows wrapper)
REM Runs the bash implementation so behavior stays identical.

CD /D "%~dp0"

WHERE bash >NUL 2>&1
IF ERRORLEVEL 1 (
  ECHO "bash" not found. Please install Git for Windows or use WSL.
  EXIT /b 1
)

CALL bash "%~dp0\setupPython2.sh" || GOTO error
EXIT /b 0
:error
EXIT /b %ERRORLEVEL%

