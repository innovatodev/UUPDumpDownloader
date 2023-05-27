<#
.SYNOPSIS
Download the latest Windows build from https://uupdump.net/

.DESCRIPTION
Get-UUPDumpMedia is a PowerShell function that allows users to download the latest build of desired Windows version. The function accepts parameters such as desired OS, desired edition(s), desired language, destination of ISO, and whether to download ESD instead of WIM.

.PARAMETER OS
Desired OS (server, 10, 11, canary, dev)

.PARAMETER Editions
Desired editions (core, professional, enterprise, serverstandard, serverstandardcore, serverdatacenter, serverdatacentercore)

.PARAMETER Lang
Desired Lang (en-us, fr-fr ...)

.PARAMETER Destination
Destination of the ISO (Default to user downloads directory)

.PARAMETER ESD
ESD instead of WIM

.EXAMPLE
Get-UUPDumpMedia -OS "10" -Editions "core","professional" -Lang "en-us"
Get-UUPDumpMedia -OS "11" -Editions "core", "professional", "enterprise" -Lang "en-us"
Get-UUPDumpMedia -OS "11" -Editions "enterprise" -Lang "en-us"
Get-UUPDumpMedia -OS "server" -Editions serverstandard -Lang "en-us"
Get-UUPDumpMedia -OS "canary" -Editions "professional" -Lang "en-us"

.NOTES
- OS, Editions, and Lang parameters are mandatory and must be specified.
- ESD is an optional parameter and is off by default.
- Destination is an optional parameter and is set to the user's downloads directory by default.

.LINK
https://github.com/innovatodev/UUPDumpDownloader
#>
function Get-UUPDumpMedia {
    [CmdletBinding()]
    param (
        # Desired OS (server, 10, 11)
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet('server', '10', '11', 'canary', 'dev')]
        [String]
        $OS,
        # Desired editions (core, professional, enterprise, serverstandard, serverstandardcore, serverdatacenter, serverdatacentercore)
        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateSet('core', 'professional', 'enterprise', 'serverstandard', 'serverstandardcore', 'serverdatacenter', 'serverdatacentercore')]
        [String[]]
        $Editions,
        # Desired Lang (en-us, fr-fr ...)
        [Parameter(Mandatory = $true, Position = 2)]
        [String]
        $Lang,
        # Destination of the ISO (Default to user downloads directory)
        [Parameter(Position = 3)]
        [System.IO.DirectoryInfo]
        $Destination = "$env:USERPROFILE\Downloads",
        # ESD instead of wim
        [Switch]$ESD
    )

    $ConvertConfig = '[convert-UUP]
AutoStart    =1
AddUpdates   =1
Cleanup      =1
ResetBase    =0
NetFx3       =1
StartVirtual =0
wim2esd      =0
wim2swm      =0
SkipISO      =0
SkipWinRE    =0
LCUwinre     =1
UpdtBootFiles=1
ForceDism    =0
RefESD       =0
SkipEdge     =0
AutoExit     =1

[Store_Apps]
SkipApps     =0
AppsLevel    =0
CustomList   =0

[create_virtual_editions]
vAutoStart   =1
vDeleteSource=0
vPreserve    =0
vwim2esd     =0
vwim2swm     =0
vSkipISO     =0
vAutoEditions=
'

    Write-Host "Downloading UUPDump for Edition : $Editions" -ForegroundColor DarkMagenta

    # Cleaning
    If (Test-Path "$env:TMP\uupdump.zip") { Remove-Item "$env:TMP\uupdump.zip" -Force -Confirm:$false | Out-Null }
    If (Test-Path "$env:TMP\uupdump") { Remove-Item "$env:TMP\uupdump" -Recurse -Force -Confirm:$false | Out-Null }

    # Editions check
    if ($OS -eq 'server') { if ($Editions -in ('core', 'professional', 'enterprise') ) { Write-Error "Wrong editions for $OS" } }
    else { if ($Editions -in ('serverstandard', 'serverstandardcore', 'serverdatacenter', 'serverdatacentercore') ) { Write-Error "Wrong editions for $OS" } }

    if ('enterprise' -notin ($Editions)) {
        # Not contain enterprise edition
        $EditionsJoinURL = ""
        foreach ($Edition in $Editions) { $EditionsJoinURL += "$Edition;" }
        $EditionsJoinURL = $EditionsJoinURL.TrimEnd(";")
        $Latest = Get-UUPDumpLatest -OS $OS

        # GET Request
        $null = Invoke-WebRequest -UseBasicParsing -Uri "https://uupdump.net/download.php?id=$($Latest.ID)&pack=$Lang&edition=$EditionsJoinURL" -SessionVariable session

        # POST Request with specific parameters
        $null = Invoke-WebRequest -UseBasicParsing -Uri "https://uupdump.net/get.php?id=$($Latest.ID)&pack=$Lang&edition=$EditionsJoinURL" `
            -Method "POST" `
            -SessionVariable session `
            -Body "autodl=2" `
            -OutFile "$env:TMP\uupdump.zip"

        # Extract ZIP
        Expand-Archive "$env:TMP\uupdump.zip" "$env:TMP\uupdump"
        Remove-Item "$env:TMP\uupdump.zip" -Force -Confirm:$false -ErrorAction SilentlyContinue | Out-Null

        # ConvertConfig.ini
        if ($ESD) {
            $ConvertConfig = $ConvertConfig -replace 'wim2esd      =0', 'wim2esd      =1'
            $ConvertConfig
        }
        Set-Content -Encoding ascii -Path "$env:TMP\uupdump\ConvertConfig.ini" -Value $ConvertConfig -Force
    } else {
        # ENTERPRISE
        $EditionsJoinURL = ""
        foreach ($Edition in $Editions) { if ($Edition -ne 'enterprise') { $EditionsJoinURL += "$Edition;" } }
        $EditionsJoinURL = $EditionsJoinURL.TrimEnd(";")
        if ('core' -notin ($Editions) -and 'professional' -notin ($Editions)) { $EditionsJoinURL = 'professional' ; $Mono = $true } else { $Mono = $false }
        $Latest = Get-UUPDumpLatest -OS $OS
        # GET Request
        $null = Invoke-WebRequest -UseBasicParsing -Uri "https://uupdump.net/download.php?id=$($Latest.ID)&pack=$Lang&edition=$EditionsJoinURL" -SessionVariable session

        # POST Request with specific parameters
        $null = Invoke-WebRequest -UseBasicParsing -Uri "https://uupdump.net/get.php?id=$($Latest.ID)&pack=$Lang&edition=$EditionsJoinURL" `
            -Method "POST" `
            -SessionVariable session `
            -Body "autodl=3&virtualEditions%5B%5D=Enterprise" `
            -OutFile "$env:TMP\uupdump.zip"

        # Extract ZIP
        Expand-Archive "$env:TMP\uupdump.zip" "$env:TMP\uupdump"
        Remove-Item "$env:TMP\uupdump.zip" -Force -Confirm:$false -ErrorAction SilentlyContinue | Out-Null

        # ConvertConfig.ini
        $ConvertConfig = $ConvertConfig -replace 'StartVirtual =0', 'StartVirtual =1'
        if ($ESD) {
            $ConvertConfig = $ConvertConfig -replace 'wim2esd      =0', 'wim2esd      =1'
            $ConvertConfig = $ConvertConfig -replace 'vwim2esd     =0', 'vwim2esd     =1'
        }
        if ($Mono) {
            # Only enterprise
            $ConvertConfig = $ConvertConfig -replace 'vDeleteSource=0', 'vDeleteSource=1'
        } else {
            # enterprise + others editions
            $ConvertConfig = $ConvertConfig -replace 'vPreserve    =0', 'vPreserve    =1'
        }
        $ConvertConfig = $ConvertConfig -replace 'vAutoEditions=', 'vAutoEditions=Enterprise'
        Set-Content -Encoding ascii -Path "$env:TMP\uupdump\ConvertConfig.ini" -Value $ConvertConfig -Force
    }

    # Launching uup_download_windows.cmd
    Write-Host "Launching uup_download_windows.cmd" -ForegroundColor DarkMagenta
    Write-Host "Waiting..." -ForegroundColor Cyan
    $null = Start-Process "cmd" `
        -ArgumentList "/c $env:TMP\uupdump\uup_download_windows.cmd" `
        -WorkingDirectory "$env:TMP\uupdump\" `
        -UseNewEnvironment `
        -Wait

    # ISO
    $EditionsJoinName = ""
    foreach ($Edition in $Editions) { $EditionsJoinName += "$Edition-" }
    $EditionsJoinName = $EditionsJoinName.TrimEnd("-").Replace('server', '')
    $OS = $OS.Replace("server", 'Server')
    if ($OS -eq 'canary') { $ISOName = "Windows11_Canary_$($Latest.Number)_$($Lang)_$EditionsJoinName.iso" }
    if ($OS -eq 'dev') { $ISOName = "Windows11_Dev_$($Latest.Number)_$($Lang)_$EditionsJoinName.iso" }
    else { $ISOName = "Windows$($OS)_$($Latest.Number)_$($Lang)_$EditionsJoinName.iso" }
    Write-Host "Checking for $ISOName" -ForegroundColor Cyan
    $ISO = Get-ChildItem "$env:TMP\uupdump" -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Extension -eq ".iso" } | Select-Object -First 1
    if (!$ISO) {
        Write-Host "An error occured, ISO cannot be found" -ForegroundColor Red
        Write-Host "Cleaning ..." -ForegroundColor Cyan
        Remove-Item "$env:TMP\uupdump" -Force -Recurse -Confirm:$false | Out-Null
        Exit 1
    } else {
        Move-Item -Path $ISO.FullName -Destination "$Destination\$ISOName" -Force -Confirm:$false
        Write-Host "Cleaning ..." -ForegroundColor Cyan
        Remove-Item "$env:TMP\uupdump" -Force -Recurse -Confirm:$false | Out-Null
    }
}
