param (
    [string]$metaFileName = "meta.cpp"
)

"Meta file name: $metaFileName`n`n"
Push-Location

Set-Location "$PSScriptRoot\..\..\Vindicta-Addon"

"Setup temporary directories..."
if (Test-Path "..\_build\addon") {
    Remove-Item -Path "..\_build\addon" -Recurse -Force
}
New-Item -Path "..\_build" -ItemType Directory -Force > $null
New-Item -Path "..\_build\addon" -ItemType Directory -Force > $null
New-Item -Path "..\_build\addon\Vindicta" -ItemType Directory -Force > $null
New-Item -Path "..\_build\addon\Vindicta\addons" -ItemType Directory -Force > $null
New-Item -Path "..\_build\addon\Vindicta\keys" -ItemType Directory -Force > $null

$buildLocation = "$PSScriptRoot\..\..\_build"
$addonLocation = "." # We are here already
$addonOutLocation = "$PSScriptRoot\..\..\_build\addon\Vindicta"
$addonsOutLocation = "$addonOutLocation\addons"

"`nCopy mission pbo file..."
Copy-Item "..\_build\missions\vindicta_missions.pbo" $addonsOutLocation

"`nBuild addons..."
$modules = Get-Childitem "$addonLocation\addons" -Directory
foreach ($module in $modules) {
    $pboName = "vindicta_$($module.Name).pbo"
    #"Building $pboName...  $addonLocation\addons\$($module.Name)   -> $addonsOutLocation\$pboName"
    "Building $pboName ..."
    .$PSScriptRoot\hemtt armake build --force -i include  $module.fullName "$addonsOutLocation\$pboName" -w unquoted-string -w redefinition-wo-undef -w excessive-concatenation
}

"`nCopy extras..."
$extraFiles = Get-ChildItem -Path "extras" -File
foreach ($extraFile in $extraFiles) {
    "Copying extra file $($extraFile.Name) ..."
    Copy-Item $extraFile.fullName $addonOutLocation
}
if (Test-Path "$buildLocation\FOR_DEDICATED_SERVER_CFG.TXT") {
    Copy-Item "$buildLocation\FOR_DEDICATED_SERVER_CFG.TXT" $addonOutLocation
}

"`nCopy meta.cpp..."
Copy-Item "meta\$metaFileName" $addonOutLocation
Push-Location
Set-Location $addonOutLocation
Rename-Item $metaFileName "meta.cpp"
Pop-Location

"`nCreate key..."
Push-Location
Set-Location "$PSScriptRoot\..\..\_build\addon"

.$PSScriptRoot\..\DSSignFile\DSCreateKey "vindicta"
Copy-Item "vindicta.bikey" "$addonOutLocation\keys\vindicta.bikey" -Force

"`nSign PBO files..."
Push-Location
Set-Location $addonsOutLocation
$pboFiles = Get-ChildItem -Path $addonsOutLocation -Name "*.pbo"
forEach ($file in $pboFiles) {
    "Signing file $file ..."
    .$PSScriptRoot\..\DSSignFile\DSSignFile "..\..\vindicta.biprivatekey" $file
}
Pop-Location

Pop-Location

Pop-Location