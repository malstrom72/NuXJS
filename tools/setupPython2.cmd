@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

REM Setup Python 2 on Windows using a portable Miniconda install.
REM Mirrors the behavior of tools/setupPython2.sh as closely as possible.

REM Always run from this script's folder so relative paths work from any caller dir
CD /D "%~dp0\.."

REM Paths inside the repo to avoid sandbox/out-of-tree writes
SET "ROOT=%CD%\"
SET "OUTDIR=%ROOT%output\python2"
SET "DL_DIR=%ROOT%output\downloads"
SET "MC_DIR=%OUTDIR%\miniconda3"
SET "PY2_DIR=%OUTDIR%\env"
SET "CONDAX=%MC_DIR%\Scripts\conda.exe"
SET "PYTHONX=%PY2_DIR%\python.exe"
SET "MINICONDA_EXE=%DL_DIR%\Miniconda3-latest-Windows-x86_64.exe"

IF NOT EXIST "%DL_DIR%" MD "%DL_DIR%"
IF ERRORLEVEL 1 GOTO error
IF NOT EXIST "%OUTDIR%" MD "%OUTDIR%"
IF ERRORLEVEL 1 GOTO error

REM 1) Download Miniconda installer locally if needed (no temp outside repo)
IF NOT EXIST "%MINICONDA_EXE%" (
	REM Prefer PowerShell; fall back to curl if available
	POWERSHELL -NoProfile -ExecutionPolicy Bypass ^
		"try { [Net.ServicePointManager]::SecurityProtocol = 'Tls12'; Invoke-WebRequest 'https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe' -OutFile '%MINICONDA_EXE%'; exit 0 } catch { Write-Error $_; exit 1 }"
	IF ERRORLEVEL 1 (
		IF EXIST "%SystemRoot%\System32\curl.exe" (
			"%SystemRoot%\System32\curl.exe" -fL "https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe" -o "%MINICONDA_EXE%" || GOTO error
		) ELSE (
			ECHO Failed to download Miniconda installer. PowerShell and curl are unavailable.
			GOTO error
		)
	)
)

REM 2) Install Miniconda into the repo if missing
IF NOT EXIST "%CONDAX%" (
	"%MINICONDA_EXE%" /S /InstallationType=JustMe /AddToPath=0 /RegisterPython=0 /D=%MC_DIR%
	IF ERRORLEVEL 1 GOTO error
)

REM 3) Ensure conda is usable (skip updating to avoid defaults/TOS prompts)

REM 4) Create a Python 2.7 environment pinned to the archival conda-forge label
IF NOT EXIST "%PYTHONX%" (
	"%CONDAX%" create -y -p "%PY2_DIR%" --override-channels ^
		-c conda-forge/label/cf202003 -c conda-forge ^
		"python=2.7" "pip<21" "setuptools<45" "wheel<1.0"
	IF ERRORLEVEL 1 GOTO error
)

REM 5) Verify
"%PYTHONX%" --version
IF ERRORLEVEL 1 GOTO error

ECHO Done. Portable Python 2 created at: "%PY2_DIR%"
ECHO To use it directly: "%PYTHONX%" script.py
REM 6) Create a user-level shim so `python2` works from any directory
SET "SHIM_DIR=%USERPROFILE%\.local\bin"
SET "SHIM_FILE=%SHIM_DIR%\python2.cmd"
IF NOT EXIST "%SHIM_DIR%" MD "%SHIM_DIR%"
IF ERRORLEVEL 1 GOTO error

REM Write shim that forwards to the portable interpreter (use real CRLFs)
(
  ECHO @echo off
  ECHO "%PYTHONX%" %%*
) > "%SHIM_FILE%" || GOTO error

REM Ensure the shim directory is on PATH now and for future shells
ECHO %PATH% | FIND /I "%SHIM_DIR%" >NUL
IF ERRORLEVEL 1 (
	SET "NEWPATH=%PATH%;%SHIM_DIR%"
	SETX PATH "%NEWPATH%" >NUL
) ELSE (
	SET "NEWPATH=%PATH%"
)

REM Ensure .CMD is in PATHEXT so bare `python2` resolves
ECHO %PATHEXT% | FIND /I ".CMD" >NUL
IF ERRORLEVEL 1 (
	SET "NEWPATHEXT=%PATHEXT%;.CMD"
	SETX PATHEXT "%NEWPATHEXT%" >NUL
) ELSE (
	SET "NEWPATHEXT=%PATHEXT%"
)

REM Propagate updates to the current shell despite SETLOCAL
ENDLOCAL & SET "PATH=%NEWPATH%" & SET "PATHEXT=%NEWPATHEXT%" & ECHO Shim installed: "%SHIM_FILE%" & ECHO If the current shell does not see it, open a new shell. & EXIT /b 0

:error
ECHO Failed with errorlevel %ERRORLEVEL%.
EXIT /b %ERRORLEVEL%
