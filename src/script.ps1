Write-Host "Escolha uma op��o:"
Write-Host "1 - Baixar imagem do arquivo html"

$opcao = Read-Host "Digite o n�mero da op��o"

if ($opcao -eq "1") {
    Write-Host "Baixando imagens dos links do arquivo html..."
    & ".\scr\download_img_links.ps1"

    Write-Host "Deseja converter as imagens para PDF? "
    Write-Host "1 - converter com o modo OCR"
    Write-Host "2 - converter sem o modo OCR"

    $opcao = Read-Host "Digite o n�mero da op��o:"

    if ($opcao -eq "1") {
       Write-Host "Baixando imagens dos links do arquivo html..."
       & ".\scr\Com OCR\image-for-pdf-OCR.ps1"

       Write-Host "Deseja mesclar os pdf gerado? "
       Write-Host "1 - Mesclar PDFS"

        $opcao = Read-Host "Digite o n�mero da op��o:"

        if($opcao -eq "1"){
            Write-Host "Mesclando"
            & ".\scr\Com OCR\pdf-merged.ps1"
        } else {
            Write-Host "Op��o inv�lida!"
    }

} elseif ($opcao -eq "2") {
    Write-Host "Executando sem o modo OCR..."
    & ".\scr\Sem OCR\image-merged-pdf.ps1"
} else {
    Write-Host "Op��o inv�lida!"
}



} else {
    Write-Host "Op��o inv�lida!"
}

