@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
PUSHD %~dp0\..

IF NOT EXIST output\examples mkdir output\examples
SET target=%~1
IF "%target%"=="" SET target=debug
SET fail=0
SET exe=output\examples\examples.exe

ECHO Building examples
CALL tools\BuildCpp.cmd %target% %exe% examples\examples.cpp src\NuXJS.cpp src\stdlibJS.cpp || SET fail=1

IF %fail% EQU 0 (
	ECHO Running examples
	%exe% > output\examples\all.log 2>&1
	IF ERRORLEVEL 1 (
		ECHO examples failed
		TYPE output\examples\all.log
		SET fail=1
	) ELSE (
		IF EXIST examples\expected_examples.txt (
			FC examples\expected_examples.txt output\examples\all.log >NUL
			IF ERRORLEVEL 1 (
				ECHO examples output mismatch
				SET fail=1
			) ELSE (
				ECHO examples ok
			)
		) ELSE (
			ECHO examples ok (no expected output)
		)
	)
)
POPD
EXIT /B %fail%
