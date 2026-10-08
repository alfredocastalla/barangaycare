@echo off
setlocal

set "APP_DIR=%~dp0laravel-api"
set "PHP_EXE="

if not exist "%APP_DIR%\artisan" (
    echo Laravel application not found: "%APP_DIR%"
    pause
    exit /b 1
)

for /d %%D in ("C:\wamp64\bin\php\php8.4*") do (
    if not defined PHP_EXE if exist "%%~D\php.exe" (
        "%%~D\php.exe" -r "exit(PHP_VERSION_ID >= 80300 && extension_loaded('pdo_mysql') ? 0 : 1);"
        if not errorlevel 1 set "PHP_EXE=%%~D\php.exe"
    )
)

for /d %%D in ("C:\wamp64\bin\php\php8.3*") do (
    if not defined PHP_EXE if exist "%%~D\php.exe" (
        "%%~D\php.exe" -r "exit(PHP_VERSION_ID >= 80300 && extension_loaded('pdo_mysql') ? 0 : 1);"
        if not errorlevel 1 set "PHP_EXE=%%~D\php.exe"
    )
)

for /f "delims=" %%D in ('dir /b /ad /o-n "C:\wamp64\bin\php\php*" 2^>nul') do (
    if not defined PHP_EXE if exist "C:\wamp64\bin\php\%%D\php.exe" (
        "C:\wamp64\bin\php\%%D\php.exe" -r "exit(PHP_VERSION_ID >= 80300 && extension_loaded('pdo_mysql') ? 0 : 1);"
        if not errorlevel 1 set "PHP_EXE=C:\wamp64\bin\php\%%D\php.exe"
    )
)

if not defined PHP_EXE (
    for /f "delims=" %%P in ('where php 2^>nul') do (
        if not defined PHP_EXE (
            "%%P" -r "exit(PHP_VERSION_ID >= 80300 && extension_loaded('pdo_mysql') ? 0 : 1);"
            if not errorlevel 1 set "PHP_EXE=%%P"
        )
    )
)

if not defined PHP_EXE (
    echo No PHP 8.3+ CLI with the PDO MySQL extension was found.
    echo Enable pdo_mysql in WAMP or select a compatible PHP version.
    pause
    exit /b 1
)

pushd "%APP_DIR%"
if not exist "vendor\autoload.php" (
    if exist "%~dp0composer.phar" (
        "%PHP_EXE%" "%~dp0composer.phar" install --no-interaction
        if errorlevel 1 (
            popd
            pause
            exit /b 1
        )
    ) else (
        echo Composer dependencies are missing. Install Composer dependencies in "%APP_DIR%".
        popd
        pause
        exit /b 1
    )
)

if not exist "vendor\autoload.php" (
    echo Composer dependencies could not be found after installation.
    popd
    pause
    exit /b 1
)

if not exist ".env" (
    copy ".env.example" ".env" >nul
    if errorlevel 1 (
        echo Could not create .env from .env.example.
        popd
        pause
        exit /b 1
    )
)

findstr /x /c:"APP_KEY=" ".env" >nul
if not errorlevel 1 (
    "%PHP_EXE%" artisan key:generate --force
    if errorlevel 1 (
        popd
        pause
        exit /b 1
    )
)

echo Clearing stale Laravel caches...
"%PHP_EXE%" artisan optimize:clear
if errorlevel 1 (
    echo Laravel could not clear its cached configuration.
    popd
    pause
    exit /b 1
)

"%PHP_EXE%" artisan barangaycare:prepare-database
if errorlevel 1 (
    echo Laravel could not connect to MySQL or create the database. Check that WAMP MySQL is running and DB_* values in "%APP_DIR%\.env" are correct.
    popd
    pause
    exit /b 1
)

"%PHP_EXE%" artisan migrate --seed --force
if errorlevel 1 (
    echo Laravel could not prepare its database. Check that WAMP MySQL is running and DB_* values in "%APP_DIR%\.env" are correct.
    popd
    pause
    exit /b 1
)

echo Starting BarangayCare at http://127.0.0.1:8000
echo Keep this window open while using the app. Press Ctrl+C to stop it.
"%PHP_EXE%" artisan serve --host=127.0.0.1 --port=8000
set "EXIT_CODE=%ERRORLEVEL%"
popd
if not "%EXIT_CODE%"=="0" pause
exit /b %EXIT_CODE%
