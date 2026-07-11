
$downloadimg   = Join-Path $PSScriptRoot "1.download_img_links.ps1"
$convertPdf    = Join-Path $PSScriptRoot "2.image-for-pdf-OCR.ps1"
$mergeCompress = Join-Path $PSScriptRoot "3.merge-compress.ps1"

#Menu 

Write-Host "===== MENU ====="
Write-Host "1 - Executar tudo em sequência (dependendo da quantidade esse processo pode demorar)"
Write-Host "2 - Baixar imagens do arquivo html files"
Write-Host "3 - Converter imagem para PDF ( com tecnologia OCR )"
Write-Host "4 - Mesclar e Comprimir PDFs"
Write-Host "0 - Sair"

#código de execução

$opcao = Read-Host "Digite o numero da opcao"

switch ($opcao)
{
    "1" {
        Write-Host "Baixando imagens..."
        & $downloadimg

        Write-Host "Executando OCR..."
        & $convertPdf

        Write-Host "Mesclando e Comprimindo PDFs..."
        & $mergeCompress

        Write-Host "Processo concluido!"
    }

    "2" {
        Write-Host "Baixando imagens..."
        & $downloadimg
    }

    "3" {
        Write-Host "Executando OCR..."
        & $convertPdf
    }

    "4" {
    Write-Host "Mesclando e Comprimindo PDF..."
    & $mergeCompress
    }


    "0" {
        exit
    }
}