# Pasta onde estão os PDFs individuais
$pdfPath = ".\Files-Create\pdfCreate"

# Pasta onde o PDF final será salvo
$pdfFinalPath = ".\Files-Create\pdf-Mesclado"
New-Item -ItemType Directory -Path $pdfFinalPath -Force | Out-Null

# Pega os arquivos PDF em ordem numérica (baseado nos números no nome do arquivo)
$pdfs = Get-ChildItem $pdfPath -Filter *.pdf | Sort-Object {
    [int]($_.BaseName -replace '\D','')  # extrai os números
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

Write-Host "`n📄 PDF final criado em: $mergedOutput" -ForegroundColor Green
pause
