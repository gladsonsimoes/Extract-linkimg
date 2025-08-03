# Define as pastas e arquivos
$inputFolder = ".\html_files"        # Pasta onde estão os arquivos .html
$outputFile = "..\config\temporary_files\links_extracted.txt" # Arquivo para salvar os links extraídos
$downloadFolder = ".\downloaded_images"  # Pasta para salvar as imagens baixadas

# Verifica se a pasta de entrada existe
if (-not (Test-Path $inputFolder)) {
    Write-Host "A pasta '$inputFolder' não existe. Crie-a e adicione os arquivos .html." -ForegroundColor Red
    exit
}

# Cria a pasta de downloads, se não existir
if (-not (Test-Path $downloadFolder)) {
    New-Item -Path $downloadFolder -ItemType Directory | Out-Null
}

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


#------------------------------------------------

# Caminho do arquivo PDF e pasta de imagens
$outputPdf = ".\output.pdf"
$downloadFolder = ".\downloaded_images"

# Verifica se a biblioteca iTextSharp está carregada
try {
    Add-Type -Path ".\packages\itextsharp.dll"
    Write-Host "Biblioteca iTextSharp carregada com sucesso!" -ForegroundColor Green
} catch {
    Write-Host "Erro ao carregar a biblioteca iTextSharp: $_" -ForegroundColor Red
    exit
}

# Inicializa o documento PDF
try {
    $writer = New-Object iTextSharp.text.Document
    $pdfWriter = [iTextSharp.text.pdf.PdfWriter]::GetInstance($writer, [System.IO.File]::Create($outputPdf))
    $writer.Open()
    Write-Host "Documento PDF iniciado com sucesso." -ForegroundColor Green
} catch {
    Write-Host "Erro ao inicializar o documento PDF: $_" -ForegroundColor Red
    exit
}

# Adiciona imagens ao PDF
try {
    Get-ChildItem -Path $downloadFolder -Filter "*.jpg" | Sort-Object Name | ForEach-Object {
        $imagePath = $_.FullName
        Write-Host "Adicionando imagem ao PDF: $imagePath" -ForegroundColor Green

        if (Test-Path $imagePath) {
            try {
                # Carrega a imagem
                $image = [iTextSharp.text.Image]::GetInstance($imagePath)

                # Configura a escala e posicionamento da imagem
                $image.ScaleToFit($writer.PageSize.Width - 20, $writer.PageSize.Height - 20)
                $image.SetAbsolutePosition(10, ($writer.PageSize.Height - $image.ScaledHeight - 10))

                # Adiciona a imagem ao PDF
                $writer.Add($image)
                $writer.NewPage() # Nova página para cada imagem
            } catch {
                Write-Host "Erro ao adicionar a imagem ao PDF: $imagePath. Detalhes: $_" -ForegroundColor Red
            }
        } else {
            Write-Host "Imagem não encontrada: $imagePath" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "Erro ao processar as imagens: $_" -ForegroundColor Red
}

# Finaliza o PDF
try {
    $writer.Close()
    Write-Host "PDF concluído com sucesso e salvo como '$outputPdf'." -ForegroundColor Green
} catch {
    Write-Host "Erro ao finalizar o PDF: $_" -ForegroundColor Red
}

pause

