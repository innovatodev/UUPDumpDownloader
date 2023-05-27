@{
    RootModule        = 'UUPDumpDownloader.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = '97f8effe-9152-4f55-b1d0-78c8aebb740d'
    Author            = 'innovatodev'
    CompanyName       = 'innovatodev'
    Copyright         = '(c) innovatodev. All rights reserved.'
    Description       = 'Script to download any version of Windows on https://uupdump.net/.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'Get-UUPDumpLatest'
        'Get-UUPDumpMedia'
    )
    CmdletsToExport   = @()
    VariablesToExport = '*'
    AliasesToExport   = @()
    PrivateData       = @{
        PSData = @{
            Tags         = @('Windows', 'ISO', 'UUP')
            LicenseUri   = 'https://raw.githubusercontent.com/innovatodev/UUPDumpDownloader/main/LICENSE'
            ProjectUri   = 'https://github.com/innovatodev/UUPDumpDownloader'
            IconUri      = 'https://raw.githubusercontent.com/innovatodev/UUPDumpDownloader/main/media/icon.png'
            ReleaseNotes = 'https://raw.githubusercontent.com/innovatodev/UUPDumpDownloader/main/CHANGELOG.md'
        }
    }
}
