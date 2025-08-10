$downloadimg = ".\1.download_img_links.ps1"
$convertPdf = ".\2.image-for-pdf-OCR.ps1"
$pdfMerge = ".\3.pdf-merged.ps1"
$compressedPdf = ".\4.pdf-comprimed.ps1"


Write-Host "Escolha uma opcao:"
Write-Host "1 - Baixar imagem do arquivo html"

$opcao = Read-Host "Digite o numero da opcao"

if ($opcao -eq "1") 
{
    Write-Host "Baixando imagens dos links do arquivo html..."
    & $downloadimg

    Write-Host "Deseja converter as imagens para PDF? "
    Write-Host "1 - converter com o modo OCR"
    

    $opcao = Read-Host "Digite o n�mero da op��o:"

    if ($opcao -eq "1") 
    {
       Write-Host "Baixando imagens dos links do arquivo html..."
       & $convertPdf

       Write-Host "Deseja mesclar os pdf gerado? "
       Write-Host "1 - Mesclar PDFS"

        $opcao = Read-Host "Digite o numero invalida:"

        if($opcao -eq "1"){
            Write-Host "Mesclando"
            & $pdfMerge
            
            Write-Host "Deseja reduzir o tamanho do arquivo"
            Write-Host "1 - reduzir tamanho do PDF"

            $opcao = Read-Host "Digite o numero da opcao"

            if ($opcao -eq "1") {
            Write-Host "Reduzindo o tamanho do arquivo" 
            & $compressedPdf
            } else {
               exit
            } 

        } else {
            Write-Host "Opcao invalida!"
        }
    }
} 
else {
    Write-Host "Op��o inv�lida!"
}

