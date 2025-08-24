@ECHO OFF
CD /D "%~dp0\.."
SET TMP=%TEMP%\nuxjs-test262-%RANDOM%
MD "%TMP%" || GOTO error
POWERSHELL -NoProfile -Command ^
 "$tmp='%TMP%';" ^
 "Invoke-WebRequest -Uri \"https://github.com/tc39/test262/archive/refs/heads/main.tar.gz\" -OutFile \"$tmp/test262.tar.gz\";" ^
 "tar -xzf \"$tmp/test262.tar.gz\" -C \"$tmp\";" ^
 "Rename-Item \"$tmp/test262-main\" test262-master;" ^
 "if (!(Test-Path externals)) { New-Item externals -ItemType Directory | Out-Null };" ^
 "tar -czf externals/test262-master.tar.gz -C \"$tmp\" test262-master;" ^
 "Remove-Item -Recurse -Force \"$tmp\"" || GOTO error
EXIT /b 0
:error
EXIT /b %ERRORLEVEL%
