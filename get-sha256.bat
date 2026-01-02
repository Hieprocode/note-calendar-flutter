@echo off
echo ========================================
echo   LAY SHA-256 FINGERPRINT CHO FIREBASE
echo ========================================
echo.

REM Tim Java trong cac vi tri pho bien
set "JAVA_CANDIDATES=C:\Program Files\Java C:\Program Files (x86)\Java %ProgramFiles%\Android\Android Studio\jbr %LOCALAPPDATA%\Android\Sdk\jre"

set FOUND_JAVA=
for %%d in (%JAVA_CANDIDATES%) do (
    if exist "%%d" (
        for /d %%j in ("%%d\jdk*" "%%d\jre*" "%%d\*") do (
            if exist "%%j\bin\java.exe" (
                set "FOUND_JAVA=%%j"
                goto :found
            )
        )
    )
)

:found
if not defined FOUND_JAVA (
    echo [ERROR] Khong tim thay Java!
    echo.
    echo Vui long cai dat Java JDK hoac Android Studio.
    echo Hoac them Java vao PATH.
    echo.
    pause
    exit /b 1
)

echo [OK] Tim thay Java: %FOUND_JAVA%
echo.

REM Set JAVA_HOME tam thoi
set "JAVA_HOME=%FOUND_JAVA%"
set "PATH=%JAVA_HOME%\bin;%PATH%"

REM Chay gradlew
cd /d "%~dp0android"
echo Dang chay gradlew signingReport...
echo.

call gradlew.bat signingReport

echo.
echo ========================================
echo Tim dong "SHA-256" trong output phia tren
echo Copy toan bo dong do (bao gom dau :)
echo ========================================
echo.
pause
