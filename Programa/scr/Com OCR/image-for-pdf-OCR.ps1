# Caminho do executável Tesseract
$tesseractPath = ".\Arquives\Packages\Tesseract-OCR\tesseract.exe"

#Caminho do TESSDATA
$tessdata = ".\Arquives\Packages\Tesseract-OCR\tessdata"


#Verificando se o caminho Tesseract está certo
if (-not (Test-Path $tesseractPath)) {
    Write-Host "
    
    ❌ Caminho do Tesseract inválido: $tesseractPath
    
    " -ForegroundColor Red
    Read-Host "      Pressione ENTER para sair"
    exit
} 
#Verificando se o caminho Tessdata está certo
if (-not (Test-Path $tessdata)) {
    Write-Host "
    
    ❌ Caminho do Tessdata inválido: $tessdata
    
    " -ForegroundColor Red
    Read-Host "     Pressione ENTER para sair"
    exit
}


$tesseract = Resolve-Path $tesseractPath

$env:TESSDATA_PREFIX = (Resolve-Path $tessdata).Path

# Pasta onde estão as imagens
$imagensPath = "..\Files_create\download_imgs"

# Pasta de saída
$saidaPath = ".\Files_create\Pdf-ocr-create"

# Limpar PDFs antigos
if (Test-Path $saidaPath) {
    Get-ChildItem -Path $saidaPath -Filter *.pdf -File | Remove-Item -Force
} 

New-Item -ItemType Directory -Path $saidaPath -Force | Out-Null

Write-Host "`n🧠 Iniciando OCR com Tesseract..." -ForegroundColor Cyan

# Ordenar as imagens de forma segura
$imagens = Get-ChildItem -Path $imagensPath -File |
    Where-Object { $_.Extension -match '^\.(png|jpg|jpeg|tif|tiff)$' } |
    Sort-Object {
        $num = $_.BaseName -replace '\D', ''
        if ([string]::IsNullOrEmpty($num)) { 0 } else { [int]$num }
    }

if ($imagens.Count -eq 0) {
    Write-Host "⚠ Nenhuma imagem encontrada em '$imagensPath'" -ForegroundColor Yellow
    Read-Host "Pressione ENTER para sair"
    exit
}

# Lista para imagens que falharem
$imagensErro = @()

foreach ($img in $imagens) {
    $imagem = $img.FullName
    $nomeBase = [System.IO.Path]::GetFileNameWithoutExtension($img.Name)
    $saidaPDF = Join-Path $saidaPath $nomeBase

    Write-Host "🔍 Processando imagem: $($img.Name)..."

    & $tesseract $imagem $saidaPDF -l por pdf

    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ ERRO ao processar $($img.Name). Código de saída: $LASTEXITCODE" -ForegroundColor Red
        $imagensErro += $img.Name
    } else {
        Write-Host "✅ OCR gerado: $($nomeBase).pdf" -ForegroundColor Green
    }
}

if ($imagensErro.Count -gt 0) {
    Write-Host "`n⚠ Alguns arquivos falharam:" -ForegroundColor Yellow
    $imagensErro | ForEach-Object { Write-Host "- $_" -ForegroundColor Yellow }
}

# Abrir a pasta de saída
Start-Process $saidaPath

Write-Host "`n🏁 Finalizado em ordem crescente!" -ForegroundColor Green
Read-Host "Pressione ENTER para sair"
