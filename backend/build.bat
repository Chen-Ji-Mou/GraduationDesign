@echo off

set ROOT_PATH=%~dp0
set JAR_PATH=%ROOT_PATH%jar

call mvn clean package

if exist %JAR_PATH% rmdir /s /q %JAR_PATH%
mkdir %JAR_PATH%

cd %ROOT_PATH%target

copy backend-0.0.1-SNAPSHOT.jar %JAR_PATH%\

cd %JAR_PATH%

rename %JAR_PATH%\backend-0.0.1-SNAPSHOT.jar backend-release.jar