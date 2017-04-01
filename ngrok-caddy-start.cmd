@echo off
:: author @wzulfikar - 2017/03/31 19:53 MYT

:: initiating default values
set SHOULD_ASK_EXE_PATH=0
set CURRENT_PATH=%~dp0
set HOST_IP=0.0.0.0
set HOST_NAME=localhost

set dir=%UserProfile%
set ip_config_dump=no
set ngrok_port=88
set ngrok_exe=%CURRENT_PATH%ngrok.exe
set caddy_exe=%CURRENT_PATH%caddy.exe
set caddy_function=browse

echo Ngrok + Caddy
echo.
echo This script will give public url for given directory using ngrok.
echo Enjoy!
echo.

set /p dir=- Which directory to share (defaults to "%dir%")? 
set /p ngrok_port=- What port number to be used (defaults to %ngrok_port%)? 

REM use string manipulation to get rid of quotation marks in directory path
set dir=%dir:"=%

IF not "%SHOULD_ASK_EXE_PATH%" == "1" GOTO CHECK_CADDY
set /p ngrok_exe=- Where is ngrok.exe (defaults to "%ngrok_exe%")? 
set /p caddy_exe=- Where is caddy.exe - answer "no" if you don't want to use caddy (defaults to "%caddy_exe%")? 

:CHECK_CADDY
IF "%caddy_exe%" == "no" call :START_NGROK & exit
echo.
echo Please key in what caddy function to be used, 
set /p caddy_function=either "browse" or "filemanager" (defaults to "%caddy_function%"): 
set COMMAND=%caddy_exe% -host %HOST_IP% -port %ngrok_port% %caddy_function%

echo.
set /p ip_config_dump=Dump ip config of this machine (defaults to no)? 
IF not "%ip_config_dump%" == "no" call :DUMP_IP_CONFIG
exit

:DUMP_IP_CONFIG
set ip_config_dump=%dir%\ipconfig.txt
start /i /b /wait cmd /c ipconfig > %ip_config_dump%


echo.
echo Preparing execution of:
echo %COMMAND%
echo.
echo Executable paths:
echo %ngrok_exe%
echo %caddy_exe%
echo.
echo Directory to be shared:
echo "%dir%".
echo.
echo.
echo IP config dump:
echo "%ip_config_dump%".
echo.
pause

call :START_NGROK

:: push to specified directory since caddy's default root is `.`
pushd "%dir%"
start /i /b /wait cmd /c %COMMAND%

:START_NGROK
start cmd /c %ngrok_exe% http %ngrok_port%
goto :eof
