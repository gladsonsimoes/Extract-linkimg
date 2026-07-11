# ==========================================
# Merge + Compress PDF (Ghostscript)
# ==========================================

# Caminho raiz do projeto
$rootPath = Split-Path $PSScriptRoot -Parent

# Ghostscript
$ghostscriptPath = Join-Path $rootPath "modules\gs\gs10.05.1\bin\gswin64c.exe"

# PDFs gerados pelo OCR
$pdfPath = Join-Path $rootPath "output\Files_create\Pdf-ocr-create"

# Pasta de saída
$outputFolder = Join-Path $rootPath "output\Files_create\pdfFinal"

# Verificações
if (-not (Test-Path $ghostscriptPath)) {
    Write-Host "❌ Ghostscript não encontrado: $ghostscriptPath" -ForegroundColor Red
    Read-Host "Pressione ENTER para sair"
    exit
}

if (-not (Test-Path $pdfPath)) {
    Write-Host "❌ Pasta não encontrada: $pdfPath" -ForegroundColor Red
    Read-Host "Pressione ENTER para sair"
    exit
}

if (-not (Test-Path $outputFolder)) {
    New-Item -ItemType Directory -Path $outputFolder | Out-Null
}

# Lista PDFs em ordem numérica
$pdfs = Get-ChildItem $pdfPath -Filter *.pdf | Sort-Object {
    $num = $_.BaseName -replace '\D', ''
    if ([string]::IsNullOrEmpty($num)) { 0 } else { [int]$num }
}

if ($pdfs.Count -eq 0) {
    Write-Host "⚠ Nenhum PDF encontrado em $pdfPath" -ForegroundColor Yellow
    Read-Host "Pressione ENTER para sair"
    exit
}

$pdfFiles = $pdfs | ForEach-Object { $_.FullName }

# Gera nome automático
$i = 1
do {
    $outputPdf = Join-Path $outputFolder "documento_$i.pdf"
    $i++
} while (Test-Path $outputPdf)

Write-Host ""
Write-Host "📄 Mesclando e comprimindo PDFs..."
Write-Host ""

# Merge + Compress
& $ghostscriptPath `
    -sDEVICE=pdfwrite `
    -dCompatibilityLevel=1.4 `
    -dPDFSETTINGS=/printer `
    -dNOPAUSE `
    -dQUIET `
    -dBATCH `
    "-sOutputFile=$outputPdf" `
    @pdfFiles

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ PDF criado com sucesso!" -ForegroundColor Green
    Write-Host "📄 Arquivo: $outputPdf" -ForegroundColor Green

    Start-Process $outputFolder
}
else {
    Write-Host ""
    Write-Host "❌ Erro ao criar PDF final." -ForegroundColor Red
}

Read-Host "Pressione ENTER para sair"