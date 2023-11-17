

# Create a zip file in the root of the deploy folder with the function app code
$FunctionAppFolder = -join((get-item $PSScriptRoot ).parent.FullName, "\fortune_handler_function")
$ZipDestination = -join($PSScriptRoot, '\Function.zip')
$FilesToExclude = @(".funcignore",".gitignore")
$FunctionFilesToZip = Get-ChildItem -Path $FunctionAppFolder -Exclude $FilesToExclude
Compress-Archive -Path $FunctionFilesToZip -DestinationPath $ZipDestination -CompressionLevel Fastest

#Connect to azure account and deploy zipped function code
Connect-AzAccount
Publish-AzWebapp -ResourceGroupName rg-fortune-handler -Name func-fortune-handler -ArchivePath $ZipDestination



