@echo off
title Verificador PowerShell 7.6

echo ========================================
echo Verificando PowerShell 7.6...
echo ========================================

:: Verifica se o pwsh existe
where pwsh >nul 2>&1

if %errorlevel% neq 0 (
    echo PowerShell 7 nao encontrado.
    goto install
)

:: Obtém a versão instalada
for /f "delims=" %%v in ('pwsh -NoProfile -Command "$PSVersionTable.PSVersion.ToString()"') do set PSVERSION=%%v

echo Versao encontrada: %PSVERSION%

:: Verifica se a versão começa com 7.6
echo %PSVERSION% | findstr /b "7.6" >nul

if %errorlevel%==0 (
    echo PowerShell 7.6 ja esta instalado.
    goto executar
)

echo Versao incorreta encontrada: %PSVERSION%

:install
echo.
echo Instalando PowerShell 7.6...
winget install Microsoft.PowerShell --version 7.6 --accept-package-agreements --accept-source-agreements

if %errorlevel% neq 0 (
    echo Erro ao instalar o PowerShell 7.6.
    pause
    exit /b 1
)

:executar
echo.
echo Executando script PowerShell...

set "PWSH=%ProgramFiles%\PowerShell\7\pwsh.exe"

if exist "%PWSH%" (
    "%PWSH%" -ExecutionPolicy Bypass -File "src/script.ps1"
) else (
    pwsh -ExecutionPolicy Bypass -File "src/script.ps1"
)

pause