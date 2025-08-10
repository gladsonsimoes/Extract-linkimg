# Caminho para o executável do Ghostscript
$ghostscriptPath = "..\modules\gs\gs10.05.1\bin\gswin64c.exe"

# Pasta onde estão os PDFs originais
$inputFolder = "..\output\Files_create\pdf-Mesclado"

# Pasta onde serão salvos os PDFs comprimidos
$outputFolder = "..\output\Files_create\pdfComprimed"

# Cria a pasta de saída se não existir
if (-not (Test-Path $outputFolder)) {
    New-Item -ItemType Directory -Path $outputFolder | Out-Null
}

# Pega todos os arquivos PDF na pasta de entrada
$pdfFiles = Get-ChildItem -Path $inputFolder -Filter *.pdf

foreach ($pdf in $pdfFiles) {
    $inputPdfPath = $pdf.FullName
    $outputPdfPath = Join-Path $outputFolder $pdf.Name

    $args = @(
        "-sDEVICE=pdfwrite"
        "-dCompatibilityLevel=1.4"
        "-dPDFSETTINGS=/ebook"  # ajusta aqui pra /screen, /ebook, etc.
        "-dNOPAUSE"
        "-dQUIET"
        "-dBATCH"
        "-sOutputFile=$outputPdfPath"
        $inputPdfPath
    )

    Write-Host "Comprimindo $($pdf.Name)..."
    & $ghostscriptPath $args
}

Write-Host "Processo finalizado. PDFs comprimidos em $outputFolder"
Pause
