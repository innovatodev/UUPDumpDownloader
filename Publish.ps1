New-Item "$env:UserProfile\Documents\WindowsPowerShell\Modules\UUPDumpDownloader" -ItemType Directory
Copy-Item -Path ".\Module\*" -Destination "$env:UserProfile\Documents\WindowsPowerShell\Modules\UUPDumpDownloader" -Recurse
Import-Module "$env:UserProfile\Documents\WindowsPowerShell\Modules\UUPDumpDownloader\UUPDumpDownloader.psd1"
Publish-Module -Name UUPDumpDownloader -NuGetApiKey $env:PSGALLERY_KEY
