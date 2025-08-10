Write-Host "Cole o conteúdo HTML e depois pressione Ctrl+Z e Enter para finalizar a entrada:"

# Ler todo o texto colado no console até Ctrl+Z (EOF)
$htmlContent = [Console]::In.ReadToEnd()

# Definir pasta e nome do arquivo para salvar
$pastaDestino = "..\html_files"

if (-not (Test-Path $pastaDestino)) {
    New-Item -ItemType Directory -Path $pastaDestino | Out-Null
}
$arquivoDestino = Join-Path $pastaDestino "pagina.html"

# Salvar o conteúdo no arquivo
Set-Content -Path $arquivoDestino -Value $htmlContent -Encoding UTF8

Write-Host "Arquivo salvo em $arquivoDestino"
