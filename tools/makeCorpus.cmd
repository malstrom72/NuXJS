@ECHO OFF
SETLOCAL
CD /D "%~dp0\.."

SET "PYTHON_CMD="
py -3 -c "exit()" >NUL 2>NUL
IF %ERRORLEVEL% EQU 0 SET "PYTHON_CMD=py -3"
IF NOT DEFINED PYTHON_CMD (
	python3 -c "exit()" >NUL 2>NUL
	IF %ERRORLEVEL% EQU 0 SET "PYTHON_CMD=python3"
)
IF NOT DEFINED PYTHON_CMD (
	python -c "exit()" >NUL 2>NUL
	IF %ERRORLEVEL% EQU 0 SET "PYTHON_CMD=python"
)
IF NOT DEFINED PYTHON_CMD (
	ECHO Unable to locate python interpreter.
	EXIT /b 1
)

IF "%~1"=="" (
	%PYTHON_CMD% "tools\makeCorpus.py"
) ELSE (
	%PYTHON_CMD% "tools\makeCorpus.py" %*
)

EXIT /b %ERRORLEVEL%
