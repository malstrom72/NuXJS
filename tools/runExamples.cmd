@ECHO OFF
SETLOCAL
CD /D "%~dp0"
CD ..
SET "TARGET=%~1"
IF EXIST examples (
	ECHO runExamples.cmd: executing NuXJS example suite
	FOR %%F IN (examples\*.io) DO (
		ECHO - Skipping placeholder for %%~nxF (no runner defined)
	)
) ELSE (
	IF NOT "%TARGET%"=="" (
		ECHO runExamples.cmd: no examples directory found for target '%TARGET%', skipping
	) ELSE (
		ECHO runExamples.cmd: no examples directory found, skipping
	)
)
EXIT /B 0
