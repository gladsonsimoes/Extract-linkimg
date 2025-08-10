# Caminhos
$inputFolder     = "..\html_files"
$outputFile      = "..\output\Extract_links.txt"
$downloadFolder  = "..\output\Files_create\download_imgs"
$outputImageDpi  = "..\output\Files_create\img_dpi"

# Criação / limpeza de pastas
foreach ($folder in @($downloadFolder, $outputImageDpi)) {
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder | Out-Null
    } else {
        Remove-Item "$folder\*" -Force -Recurse
    }
}

# Verifica pasta HTML
if (-not (Test-Path $inputFolder)) {
    Write-Host "❌ Pasta de entrada não encontrada: $inputFolder" -ForegroundColor Red
    exit
}

# Extrair links rapidamente
$links = @()
Get-ChildItem -Path $inputFolder -Filter "*.html" | ForEach-Object {
    $matches = Select-String -Path $_.FullName -Pattern 'linkimg="([^"]+)"'
    foreach ($m in $matches) {
        $links += $m.Matches.Groups[1].Value
    }
}

# Salva todos os links de uma vez
$links | Set-Content $outputFile
Write-Host "✅ $($links.Count) links extraídos" -ForegroundColor Green

# Baixar imagens sequencialmente
Write-Host "`n⬇ Baixando imagens..." -ForegroundColor Cyan
$imageCounter = 1
foreach ($url in $links) {
    $fileName = "arquivo_$imageCounter.jpg"
    $destinationPath = Join-Path $downloadFolder $fileName
    try {
        Invoke-WebRequest -Uri $url -OutFile $destinationPath -ErrorAction Stop
        Write-Host "Imagem baixada: $fileName" -ForegroundColor Green
    } catch {
        Write-Host "Falha ao baixar: $url" -ForegroundColor Red
    }
    $imageCounter++
}

# Ajustar DPI (ImageMagick) sequencialmente
Write-Host "`n🖼 Aumentando DPI..." -ForegroundColor Cyan
$imagens = Get-ChildItem -Path $downloadFolder -File |
    Where-Object { $_.Extension -match '^\.(png|jpg|jpeg|tif|tiff|bmp)$' } |
    Sort-Object {
        $num = $_.BaseName -replace '\D', ''
        if ([string]::IsNullOrEmpty($num)) { 0 } else { [int]$num }
    }

foreach ($img in $imagens) {
    $nomeBase = [System.IO.Path]::GetFileNameWithoutExtension($img.Name)
    $tempImage = Join-Path $outputImageDpi "$nomeBase.png"
    magick $img.FullName -density 300 -units PixelsPerInch -resize 300% $tempImage
    Write-Host "🔍 Processado: $($img.Name)" -ForegroundColor Yellow
}

Write-Host "`n🏁 Finalizado!" -ForegroundColor Green
