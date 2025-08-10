# --- Script principal ---

# Pasta onde estão os PDFs individuais
$pdfPath = "..\output\Files_create\Pdf-ocr-create"

# Pasta onde o PDF final será salvo
$pdfFinalPath = "..\output\Files_create\pdf-Mesclado"

#caso a pasta não exista criar a pasta
if (-not (Test-Path $pdfFinalPath)) {
    New-Item -ItemType Directory -Path $pdfFinalPath | Out-Null  
}


function createMergePdf($pdfPath, $pdfFinalPath) {
    # Pega os arquivos PDF em ordem numérica (baseado nos números no nome do arquivo)
    $pdfs = Get-ChildItem $pdfPath -Filter *.pdf | Sort-Object {
        $num = $_.BaseName -replace '\D', ''
        if ([string]::IsNullOrEmpty($num)) { 0 } else { [int]$num }
    }

    if ($pdfs.Count -eq 0) {
        Write-Host "⚠ Nenhum PDF encontrado para mesclar em '$pdfPath'." -ForegroundColor Yellow
        return
    }

    # Lista os caminhos completos
    $pdfFiles = $pdfs | ForEach-Object { $_.FullName }

    # Gera um nome de arquivo disponível na pasta final
    $i = 1
    do {
        $mergedOutput = Join-Path $pdfFinalPath "merged_output_$i.pdf"
        $i++
    } while (Test-Path $mergedOutput)

    # Junta os PDFs com pdftk
    pdftk @pdfFiles cat output $mergedOutput

    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n📄 PDF final criado em: $mergedOutput" -ForegroundColor Green
    } else {
        Write-Host "`n❌ Falha ao criar o PDF final." -ForegroundColor Red
    }

    Read-Host "Pressione ENTER para continuar"
}

createMergePdf $pdfPath $pdfFinalPath

