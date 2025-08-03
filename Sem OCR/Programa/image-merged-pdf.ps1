#------------------------------------------------

# Caminho do arquivo PDF e pasta de imagens
$destinationFolder = ".\pdfCreate"
$downloadFolder = ".\downloaded_images"

# Gera nome automático para o próximo arquivo PDF
$baseName = "merged-output"
$extension = ".pdf"
$counter = 1

do {
    $outputPdf = Join-Path $destinationFolder "$baseName`_$counter$extension"
    #$outputPdf = Join-Path $destinationFolder "$baseName" + "_$counter" + "$extension"
    $counter++
} while (Test-Path $outputPdf)


# Cria a pasta de saída se não existir
if (-not (Test-Path $destinationFolder)) {
    New-Item -ItemType Directory -Path $destinationFolder | Out-Null
}

# Verifica se a biblioteca iTextSharp está carregada
try {
    Add-Type -Path "..\config\packages\lib\net461\itextsharp.dll"
    Write-Host "Biblioteca iTextSharp carregada com sucesso!" -ForegroundColor Green
} catch {
    Write-Host "Erro ao carregar a biblioteca iTextSharp: $_" -ForegroundColor Red
    pause
}

# Inicializa o documento PDF
try {
    $writer = New-Object iTextSharp.text.Document
    $pdfWriter = [iTextSharp.text.pdf.PdfWriter]::GetInstance($writer, [System.IO.File]::Create($outputPdf))
    $writer.Open()
    Write-Host "Documento PDF iniciado com sucesso." -ForegroundColor Green
} catch {
    Write-Host "Erro ao inicializar o documento PDF: $_" -ForegroundColor Red
    pause
}

# Adiciona imagens ao PDF em ordem numérica
try {
    # Ordena os arquivos numericamente
    Get-ChildItem -Path $downloadFolder -Filter "*.jpg" | 
    Sort-Object { [int]($_.BaseName -replace 'arquivo_', '') } | ForEach-Object {
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
