@echo off
echo Removendo PowerShell 7...

winget uninstall Microsoft.PowerShell --accept-source-agreements

echo.
echo Processo concluido.
pause