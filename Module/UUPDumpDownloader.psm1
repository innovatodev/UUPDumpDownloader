foreach ($file in Get-ChildItem -Path "$PSScriptRoot/Public" -Filter *.ps1 -Recurse) {
    . $file.FullName
}
