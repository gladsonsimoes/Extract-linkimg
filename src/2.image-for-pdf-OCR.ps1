# Caminho do executável Tesseract
$tesseractPath = "..\modules\Tesseract-OCR\tesseract.exe"

# Caminho do TESSDATA
$tessdata = "..\modules\Tesseract-OCR\tessdata"

# Pasta onde estão as imagens
$imagensPath = "..\output\Files_create\download_imgs"

# Pasta de saída para gerar os PDFs
$saidaPath = "..\output\Files_create\Pdf-ocr-create"

# --- Verificações de caminho ---
if (-not (Test-Path $tesseractPath)) {
    Write-Host "`n❌ Caminho do Tesseract inválido: $tesseractPath" -ForegroundColor Red
    Read-Host "Pressione ENTER para sair"
    exit
} 

if (-not (Test-Path $tessdata)) {
    Write-Host "`n❌ Caminho do Tessdata inválido: $tessdata" -ForegroundColor Red
    Read-Host "Pressione ENTER para sair"
    exit
}

$tesseract = Resolve-Path $tesseractPath
$env:TESSDATA_PREFIX = (Resolve-Path $tessdata).Path

# Limpar PDFs antigos
if (Test-Path $saidaPath) {
    Get-ChildItem -Path $saidaPath -Filter *.pdf -File | Remove-Item -Force
} 

# Criar pasta para saída de PDF caso não exista
if (-not (Test-Path $saidaPath)) {
    New-Item -ItemType Directory -Path $saidaPath | Out-Null
}

Write-Host "`n🧠 Iniciando OCR com Tesseract..." -ForegroundColor Cyan

# Ordenar imagens por número no nome
$imagens = Get-ChildItem -Path $imagensPath -File |
    Where-Object { $_.Extension -match '^\.(png|jpg|jpeg|tif|tiff|bmp)$' } |
    Sort-Object {
        $num = $_.BaseName -replace '\D', ''
        if ([string]::IsNullOrEmpty($num)) { 0 } else { [int]$num }
    }

if ($imagens.Count -eq 0) {
    Write-Host "⚠ Nenhuma imagem encontrada em '$imagensPath'" -ForegroundColor Yellow
    Read-Host "Pressione ENTER para sair"
    exit
}

# Lista de imagens que falharam
$imagensErro = @()

foreach ($img in $imagens) {
    $imagem = $img.FullName
    $nomeBase = [System.IO.Path]::GetFileNameWithoutExtension($img.Name)
    $tempImage = Join-Path $saidaPath "$nomeBase-prep.png"
    $saidaPDF = Join-Path $saidaPath $nomeBase

    Write-Host "🔍 Pré-processando e OCR: $($img.Name)..."

    # Aumenta DPI e melhora contraste (ImageMagick)
    #magick $imagem -density 300 -units PixelsPerInch -resize 300% -colorspace Gray -threshold 50% $tempImage

    # Aumenta DPI mas mantém a cor
    magick $imagem -density 300 -units PixelsPerInch -resize 300% $tempImage


    # OCR otimizado com Tesseract
   # & $tesseract $tempImage $saidaPDF -l por --oem 1 --psm 3 
    #& $tesseract $imagem $saida -l por --dpi 300 --psm 3 -c tessedit_create_pdf=1

    # OCR preservando cor no PDF
    & $tesseract $tempImage $saidaPDF -l por --dpi 300 --psm 3 pdf

    # Remove temporário
    Remove-Item $tempImage -Force

    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ ERRO ao processar $($img.Name). Código: $LASTEXITCODE" -ForegroundColor Red
        $imagensErro += $img.Name
    } else {
        Write-Host "✅ OCR gerado: $($nomeBase).pdf" -ForegroundColor Green
    }
}

# Mostrar imagens que falharam
if ($imagensErro.Count -gt 0) {
    Write-Host "`n⚠ Alguns arquivos falharam:" -ForegroundColor Yellow
    $imagensErro | ForEach-Object { Write-Host "- $_" -ForegroundColor Yellow }
}

# Abrir pasta de saída
Start-Process $saidaPath

Write-Host "`n🏁 Finalizado em ordem crescente!" -ForegroundColor Green
Read-Host "Pressione ENTER para sair"
