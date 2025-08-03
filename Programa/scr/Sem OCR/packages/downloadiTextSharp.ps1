# Verifica se a pasta "packages" já existe, caso contrário, cria.
if (-not (Test-Path ".\packages")) {
    mkdir .\packages
}

# Baixa o pacote iTextSharp usando Save-Package para o destino correto
Save-Package -Name iTextSharp -Source https://www.nuget.org/api/v2 -ProviderName NuGet -Path .\packages

# Busca a DLL do iTextSharp na pasta de pacotes
$dllPath = Get-ChildItem -Path ".\packages" -Recurse -Filter "itextsharp.dll" | Select-Object -ExpandProperty FullName -ErrorAction SilentlyContinue

# Verifica se a DLL foi encontrada
if ($null -ne $dllPath -and (Test-Path $dllPath)) {
    Add-Type -Path $dllPath
    Write-Host "Biblioteca iTextSharp carregada com sucesso!" -ForegroundColor Green
} else {
    Write-Host "Erro: Não foi possível encontrar a DLL do iTextSharp na pasta de pacotes." -ForegroundColor Red
    Write-Host "Verifique se o pacote foi baixado corretamente e se a DLL está presente." -ForegroundColor Yellow
}


pause