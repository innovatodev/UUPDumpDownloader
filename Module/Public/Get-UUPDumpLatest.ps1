<#
.SYNOPSIS
Get the latest Windows builds information from https://uupdump.net/

.DESCRIPTION
The Get-UUPDumpLatest function retrieves the latest Windows retail build information from https://uupdump.net/ and returns it as a hashtable.

.PARAMETER OS
Desired OS (server, 10, 11, canary, dev)

.EXAMPLE
Get-UUPDumpLatest -OS 11

Retrieves the latest Windows 11 retail build information from https://uupdump.net/

.OUTPUTS
A hashtable containing the Build ID and Build Number.

.NOTES
The function uses Invoke-WebRequest to retrieve the information from UUPDump.net.

.LINK
https://github.com/innovatodev/UUPDumpDownloader
#>
function Get-UUPDumpLatest {
    [CmdletBinding()]
    param (
        # Desired OS (server, 10, 11, canary, dev)
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet('server', '10', '11', 'canary', 'dev')]
        [String]
        $OS
    )
    switch ($OS) {
        'server' { $Search = 'Feature update to Microsoft server operating system, version' }
        '10' { $Search = 'Windows 10, version' }
        '11' { $Search = 'Windows 11, version' }
        'canary' {
            $response = Invoke-WebRequest -UseBasicParsing -Uri "https://uupdump.net" | Select-Object Links
            $selected = $response.Links | Where-Object { $_.outerHTML -like "*known.php?q=*" } | Select-Object -Index 0
            $replaced = $selected.href.replace("known.php?q=", "")
            $Search = $replaced
        }
        'dev' {
            $response = Invoke-WebRequest -UseBasicParsing -Uri "https://uupdump.net" | Select-Object Links
            $selected = $response.Links | Where-Object { $_.outerHTML -like "*known.php?q=*" } | Select-Object -Index 1
            $replaced = $selected.href.replace("known.php?q=", "")
            $Search = $replaced
        }
    }

    Write-Host "Searching UUPDump for Windows $OS" -ForegroundColor DarkMagenta
    $encoded = [System.Web.HttpUtility]::UrlEncode($Search)
    $response = Invoke-WebRequest -UseBasicParsing -Uri "https://uupdump.net/known.php?q=$encoded" | Select-Object Links

    # Filter first AMD64 (x64) link
    $selected = $response.Links | Where-Object { $_.outerHTML -like "*AMD64*" } | Select-Object -First 1

    # Build ID
    $BuildID = $null
    $BuildID = $selected.href.Replace("./selectlang.php?id=", "")
    if ($null -eq $BuildID ) { Write-Error "An error occurred, Build ID was not found." }
    if ($OS -in ("server", "10", "11") ) {
        # Build Number
        $BuildNumber = $null
        $r = [regex] "\(([^\[]*)\)"
        $match = $r.match($selected.outerHTML)
        $BuildNumber = $match.groups[1].value
        if ($null -eq $BuildNumber ) { Write-Error "An error occurred, Build Number was not found." }
    } else {
        # Build Number
        $BuildNumber = $null
        $BuildNumber = ($selected.outerHTML | Select-String -AllMatches "(?<=Preview\s)(.+?)(?=\s\()").Matches.Value
        if ($null -eq $BuildNumber ) { Write-Error "An error occurred, Build Number was not found." }
    }
    [hashtable]$hash = @{
        ID     = $BuildID
        Number = $BuildNumber
    }
    Write-Host "ID = $BuildID" -ForegroundColor Green
    Write-Host "Number = $BuildNumber" -ForegroundColor Green
    Start-Sleep 1
    return $hash
}
