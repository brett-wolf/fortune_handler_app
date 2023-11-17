# Create a zip file in the root of the deploy folder with the html app code
$WebAppFolder = -join((get-item $PSScriptRoot ).parent.FullName, "\fortune_website")

$ZipDestination = -join($PSScriptRoot, '\WebApp.zip')
$WebAppFilesToZip = Get-ChildItem -Path $WebAppFolder

Write-Output $WebAppFilesToZip
Compress-Archive -Path $WebAppFolder -DestinationPath $ZipDestination -CompressionLevel Fastest

Publish-AzWebapp -ResourceGroupName rg-fortune-handler -Name web-fortune-handler -ArchivePath $ZipDestination