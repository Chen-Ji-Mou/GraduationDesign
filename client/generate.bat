@echo off

set ROOT_PATH=%~dp0
set GENERATE_PATH=%ROOT_PATH%lib\generate

rmdir /s /q %GENERATE_PATH%

call flutter packages pub run build_runner build