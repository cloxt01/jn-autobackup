@echo off
setlocal

:: === LOKASI FOLDER SCRIPT & LOG UTAMA ===
set "SCRIPT_DIR=%~dp0"
set "LOG_DIR=%SCRIPT_DIR%log"
set "MASTER_LOG=%LOG_DIR%\master_backup_log.txt"

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

echo ===================================================================== >> "%MASTER_LOG%"
echo [%DATE% %TIME%] === MEMULAI SELURUH PROSES BACKUP OTOMATIS === >> "%MASTER_LOG%"
echo [%DATE% %TIME%] === MEMULAI SELURUH PROSES BACKUP OTOMATIS ===

:: === 1. JALANKAN BACKUP RADIUS ===
if exist "%SCRIPT_DIR%backup_radius.bat" (
    echo [%DATE% %TIME%] [1/4] Menjalankan backup_radius.bat... >> "%MASTER_LOG%"
    echo [1/4] Menjalankan backup_radius.bat...
    call "%SCRIPT_DIR%backup_radius.bat"
    echo [%DATE% %TIME%] [1/4] Selesai backup_radius.bat (Exit Code: %errorlevel%) >> "%MASTER_LOG%"
) else (
    echo [%DATE% %TIME%] [SKIP] File backup_radius.bat tidak ditemukan. >> "%MASTER_LOG%"
)

:: === 2. JALANKAN BACKUP CACTI ===
if exist "%SCRIPT_DIR%backup_cacti.bat" (
    echo [%DATE% %TIME%] [2/4] Menjalankan backup_cacti.bat... >> "%MASTER_LOG%"
    echo [2/4] Menjalankan backup_cacti.bat...
    call "%SCRIPT_DIR%backup_cacti.bat"
    echo [%DATE% %TIME%] [2/4] Selesai backup_cacti.bat (Exit Code: %errorlevel%) >> "%MASTER_LOG%"
) else (
    echo [%DATE% %TIME%] [SKIP] File backup_cacti.bat tidak ditemukan. >> "%MASTER_LOG%"
)

:: === 3. JALANKAN BACKUP ZIMBRA DB ===
if exist "%SCRIPT_DIR%backup_zimbra.bat" (
    echo [%DATE% %TIME%] [3/4] Menjalankan backup_zimbra.bat... >> "%MASTER_LOG%"
    echo [3/4] Menjalankan backup_zimbra_db.bat...
    call "%SCRIPT_DIR%backup_zimbra_db.bat"
    echo [%DATE% %TIME%] [3/4] Selesai backup_zimbra.bat (Exit Code: %errorlevel%) >> "%MASTER_LOG%"
) else (
    echo [%DATE% %TIME%] [SKIP] File backup_zimbra.bat tidak ditemukan. >> "%MASTER_LOG%"
)

:: === 4. JALANKAN BACKUP ZIMBRA MAILBOX ===
if exist "%SCRIPT_DIR%backup_zimbra_mailbox.bat" (
    echo [%DATE% %TIME%] [4/4] Menjalankan backup_zimbra_mailbox.bat... >> "%MASTER_LOG%"
    echo [4/4] Menjalankan backup_zimbra_mailbox.bat...
    call "%SCRIPT_DIR%backup_zimbra_mailbox.bat"
    echo [%DATE% %TIME%] [4/4] Selesai backup_zimbra_mailbox.bat (Exit Code: %errorlevel%) >> "%MASTER_LOG%"
) else (
    echo [%DATE% %TIME%] [SKIP] File backup_zimbra_mailbox.bat tidak ditemukan. >> "%MASTER_LOG%"
)

echo [%DATE% %TIME%] === SELURUH PROSES BACKUP SELESAI === >> "%MASTER_LOG%"
echo ===================================================================== >> "%MASTER_LOG%"
echo. >> "%MASTER_LOG%"
echo [%DATE% %TIME%] === SELURUH PROSES BACKUP SELESAI ===
