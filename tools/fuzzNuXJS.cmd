@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
CD /D "%~dp0.."
REM Usage: fuzzNuXJS.cmd [seconds = 600] [parallel jobs = 8] [stdlib]. Build output\NuXJSFuzz.exe first with
REM buildReplFuzz.cmd, or output\NuXJSFuzzStdlib.exe with `buildReplFuzz.cmd stdlib` and pass stdlib here too.
REM The committed corpus is unpacked into output\fuzz\corpus, which is where libFuzzer writes new inputs, so the
REM archive in tests\fuzz\ stays untouched. Crashes land in output\fuzz\crashes.

SET "duration=%~1"
IF "%duration%"=="" SET "duration=600"
SET "jobs=%~2"
IF "%jobs%"=="" SET "jobs=8"
SET "binary=output\NuXJSFuzz.exe"
IF /I "%~3"=="stdlib" SET "binary=output\NuXJSFuzzStdlib.exe"
IF NOT EXIST "%binary%" (
	ECHO %binary% not built; run tools\buildReplFuzz.cmd %~3 first
	EXIT /b 1
)

IF NOT EXIST output\fuzz\corpus MKDIR output\fuzz\corpus
IF NOT EXIST output\fuzz\crashes MKDIR output\fuzz\crashes
REM Name the system tar, which is bsdtar and reads both .tar.gz and .zip. A plain `tar` can pick up a GNU tar from some
REM other tool's bin directory, and GNU tar cannot read a zip.
SET "tarExe=%SystemRoot%\System32\tar.exe"
IF NOT EXIST "%tarExe%" SET "tarExe=tar"
IF EXIST tests\fuzz\corpus.tar.gz (
	"%tarExe%" -xzf tests\fuzz\corpus.tar.gz --strip-components=1 -C output\fuzz\corpus || GOTO error
) ELSE IF EXIST tests\fuzz\corpus.zip (
	"%tarExe%" -xf tests\fuzz\corpus.zip --strip-components=1 -C output\fuzz\corpus || GOTO error
)
IF EXIST tests\fuzz\seeds COPY /Y tests\fuzz\seeds\* output\fuzz\corpus\ >NUL
REM The archives have carried macOS metadata before now, and libFuzzer would feed it to the engine as an input. Only
REM hash-named files belong here, so anything that arrived as a directory or a dotfile goes.
FOR /D %%d IN (output\fuzz\corpus\*) DO RMDIR /S /Q "%%d"
IF EXIST output\fuzz\corpus\.DS_Store DEL /Q output\fuzz\corpus\.DS_Store

REM Run from output\fuzz, because -jobs writes its fuzz-<n>.log files into the working directory.
PUSHD output\fuzz
"..\..\%binary%" corpus -jobs=%jobs% -workers=%jobs% -max_total_time=%duration% -timeout=10 ^
		-rss_limit_mb=4096 -dict=..\..\tests\fuzz\fuzz.dict -artifact_prefix=crashes/ -print_final_stats=1 || GOTO error
POPD
EXIT /b 0

:error
EXIT /b %ERRORLEVEL%
