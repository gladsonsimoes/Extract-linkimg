# Define as pastas e arquivos
$inputFolder = ".\html_files"        # Pasta onde estão os arquivos .html
$outputFile = ".\Extract_links.txt" # Arquivo para salvar os links extraídos
$downloadFolder = ".\Files_create\download_imgs"  # Pasta para salvar as imagens baixadas

# Verifica se a pasta de entrada existe
if (-not (Test-Path $inputFolder)) {
    Write-Host "A pasta '$inputFolder' não existe. Crie-a e adicione os arquivos .html." -ForegroundColor Red
    exit
}

# Cria a pasta de downloads, se não existir
if (-not (Test-Path $downloadFolder)) {
    New-Item -Path $downloadFolder -ItemType Directory | Out-Null
}

# Limpa a pasta de imagens antigas
Write-Host "Limpando imagens antigas..." -ForegroundColor Magenta
Get-ChildItem -Path $downloadFolder -Filter "*.jpg" -Recurse | Remove-Item -Force

# Limpa o arquivo de saída, se existir
if (Test-Path $outputFile) {
    Clear-Content $outputFile
} else {
    New-Item -Path $outputFile -ItemType File | Out-Null
}

# Processa todos os arquivos .html na pasta
Get-ChildItem -Path $inputFolder -Filter "*.html" | ForEach-Object {
    $htmlFile = $_.FullName
    Write-Host "Processando arquivo: $htmlFile" -ForegroundColor Green

    # Lê cada linha do arquivo e encontra links com 'linkimg='
    Get-Content $htmlFile | ForEach-Object {
        $line = $_
        if ($line -match 'linkimg="([^"]+)"') {
            $link = $matches[1]
            Write-Host "Link encontrado: $link" -ForegroundColor Yellow
            Add-Content -Path $outputFile -Value $link
        }
    }
}

# Exibe os links extraídos
Write-Host "`nLinks extraídos:" -ForegroundColor Cyan
Get-Content $outputFile | ForEach-Object { Write-Host $_ }

# Baixa as imagens dos links com nomes numéricos crescentes
Write-Host "`nBaixando imagens..." -ForegroundColor Green
$imageCounter = 1
Get-Content $outputFile | ForEach-Object {
    $url = $_
    $fileName = "arquivo_$imageCounter.jpg"
    $destinationPath = Join-Path $downloadFolder $fileName

    try {
        Invoke-WebRequest -Uri $url -OutFile $destinationPath
        Write-Host "Imagem baixada: $fileName" -ForegroundColor Green
        $imageCounter++
    } catch {
        Write-Host "Falha ao baixar: $url" -ForegroundColor Red
    }
}