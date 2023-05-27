# UPPDumpDownloader

Script to download any version of Windows on https://uupdump.net/

## Install it

`Install-Module -Name UUPDumpDownloader`

Get-UUPDumpMedia needs administratives rights.

## Examples

Download latest retail Windows 10, all editions, english :

`Get-UUPDumpMedia -OS "10" -Editions "core", "professional", "enterprise" -Lang "en-us"`

Download latest retail Windows 11, professional, french :

`Get-UUPDumpMedia -OS "11" -Editions "professional" -Lang "fr-fr"`

Download latest retail Server 2022, standard, english :

`Get-UUPDumpMedia -OS "server" -Editions serverstandard -Lang "en-us"`

Download latest canary Windows 11, professional, french :

`Get-UUPDumpMedia -OS "canary" -Editions "professional" -Lang "fr-fr"`

Check latest Windows 11 retail build :

`Get-UUPDumpLatest -OS 11`

```markdown
Searching UUPDump for Windows 11
ID = 5aa4a1a2-8bd2-4b8b-b463-523d7c944ca3
Number = 22621.1778

Name                           Value
----                           -----
Number                         22621.1778
ID                             5aa4a1a2-8bd2-4b8b-b463-523d7c944ca3
```
