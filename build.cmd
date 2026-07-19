@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
PUSHD %~dp0

REM Usage: build.cmd [es3|es5|both] [model] [beta|release]
REM Arguments are recognized by value and may appear in any order. Defaults: both, x64, beta+release.
SET variant=both
SET model=x64
SET targets=beta release

FOR %%A IN (%*) DO (
	IF "%%~A"=="es3" ( SET variant=es3
	) ELSE IF "%%~A"=="es5" ( SET variant=es5
	) ELSE IF "%%~A"=="both" ( SET variant=both
	) ELSE IF "%%~A"=="beta" ( SET targets=beta
	) ELSE IF "%%~A"=="release" ( SET targets=release
	) ELSE ( SET model=%%~A )
)

SET variants=%variant%
IF "%variant%"=="both" SET variants=es3 es5

FOR %%V IN (%variants%) DO (
	FOR %%T IN (%targets%) DO (
		CALL tools\buildAndTest.cmd %%T %model% %%V || GOTO error
	)
)

IF EXIST output\NuXJS_release_%model%.exe (
	MOVE /Y output\NuXJS_release_%model%.exe output\NuXJS.exe >NUL
)
IF EXIST output\NuXJS_es5_release_%model%.exe (
	MOVE /Y output\NuXJS_es5_release_%model%.exe output\NuXJS_ES5.exe >NUL
)
ECHO === ALL BUILDS AND TESTS COMPLETED SUCCESSFULLY ===
POPD
EXIT /b 0

:error
EXIT /b %ERRORLEVEL%
