# Caminho do Tesseract
$tesseract = ".\scr\Com OCR\Arquives\Packages\Tesseract-OCR\tesseract.exe"

# Pasta onde estão as imagens
$imagensPath = ".\Files_create\download_imgs"

# Pasta de saída
$saidaPath = ".\Files_create\Pdf-ocr-create"

# 🧹 Apaga todos os PDFs existentes na pasta de saída
if (Test-Path $saidaPath) {
    Get-ChildItem -Path $saidaPath -Filter *.pdf -File | Remove-Item -Force
}

# Cria a pasta de saída (caso não exista)
New-Item -ItemType Directory -Path $saidaPath -Force | Out-Null

# Definir variável de ambiente para os dados do Tesseract
$env:TESSDATA_PREFIX = (Resolve-Path ".\scr\Com OCR\Arquives\Packages\Tesseract-OCR\tessdata").Path

# Mostrar início do processo
Write-Host "`n🧠 Iniciando OCR com Tesseract..." -ForegroundColor Cyan

# Verifica se há imagens e ordena numericamente (ex: arquivo_1.jpg, arquivo_2.jpg...)
$imagens = Get-ChildItem -Path "$imagensPath\*" -Include *.png, *.jpg, *.jpeg, *.tif, *.tiff -File |
    Sort-Object { [int]($_.BaseName -replace '\D', '') }

if ($imagens.Count -eq 0) {
    Write-Host "Nenhuma imagem encontrada na pasta $imagensPath" -ForegroundColor Yellow
    pause
    exit
}

# Processar cada imagem
foreach ($img in $imagens) {
    $imagem = $img.FullName
    $nomeBase = [System.IO.Path]::GetFileNameWithoutExtension($img.Name)
    $saidaPDF = Join-Path $saidaPath "$nomeBase"

    Write-Host "🔍 Processando imagem: $($img.Name)..."

    # Executa o OCR com Tesseract
    $proc = Start-Process -FilePath $tesseract `
        -ArgumentList "`"$imagem`"", "`"$saidaPDF`"", "-l", "por", "pdf" `
        -NoNewWindow -Wait -PassThru

    if ($proc.ExitCode -ne 0) {
        Write-Host "❌ ERRO ao processar $($img.Name). Código de saída: $($proc.ExitCode)" -ForegroundColor Red
    } else {
        Write-Host "OCR gerado: $($nomeBase).pdf"
    }
}

# Abre a pasta de saída
Start-Process $saidaPath
Write-Host "`n✅ Finalizado em ordem crescente!" -ForegroundColor Green
pause
