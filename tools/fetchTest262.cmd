@ECHO OFF
CD /D "%~dp0\.."
SET COMMIT=b947715fdda79a420b253821c1cc52272a77222d
SET TMP=%TEMP%\nuxjs-test262-%RANDOM%
MD "%TMP%" || GOTO error
POWERSHELL -NoProfile -Command ^
 "$commit='%COMMIT%';$tmp='%TMP%';" ^
 "Invoke-WebRequest -Uri \"https://github.com/tc39/test262/archive/$commit.tar.gz\" -OutFile \"$tmp/test262.tar.gz\";" ^
 "tar -xzf \"$tmp/test262.tar.gz\" -C \"$tmp\";" ^
 "Rename-Item \"$tmp/test262-$commit\" test262-master;" ^
 "if (!(Test-Path externals)) { New-Item externals -ItemType Directory | Out-Null };" ^
 "tar -czf externals/test262-master.tar.gz -C \"$tmp\" test262-master;" ^
 "Remove-Item -Recurse -Force \"$tmp\"" || GOTO error
EXIT /b 0
:error
EXIT /b %ERRORLEVEL%
