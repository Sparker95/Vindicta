param (
    [string]$patch = "666"
)

#$verStr = "$($major)_$($minor)_$($patch)"
#$verDir = "vindicta_v$($verStr)"
# Set-Content -Path ..\configs\majorVersion.hpp -Value $major -Force -NoNewline
# Set-Content -Path ..\configs\minorVersion.hpp -Value $minor -Force -NoNewline
if((Get-Content -Path ..\configs\majorVersion.hpp).Count -gt 1) {
    "ERROR: configs\majorVersion.hpp contains a newline, it must not!"
    Exit 100
}
if((Get-Content -Path ..\configs\minorVersion.hpp).Count -gt 1) {
    "ERROR: configs\minorVersion.hpp contains a newline, it must not!"
    Exit 100
}

Set-Content -Path ..\configs\buildVersion.hpp -Value $patch -Force -NoNewline

..\tools\setup_and_build.bat
$verDir = (Get-ChildItem -Path ..\_build -Filter "vindicta_v*").Name.Where{!$_.Contains('.')}
$verStr = $verDir -replace "vindicta_v",""

"Building Vindicta v$($verStr)"

# echo "::set-env name=version::$($verStr)"
# (Get-Content -path hemtt.json -Raw) -replace '0.0.0',$verStr | Set-Content -Path hemtt.json
# .\tools\hemtt.exe build --release --force --nowarn

"Creating key..."
.\tools\DSCreateKey "vindicta"
$privateKey = "vindicta.biprivatekey"
New-Item ".\release\@vindicta\keys" -ItemType "directory" -Force | Out-Null
New-Item ".\release\@vindicta\addons" -ItemType "directory" -Force | Out-Null
Copy-Item "vindicta.bikey" ".\release\@vindicta\keys\vindicta.bikey" -Force
"Building mission pbo..."
.\tools\hemtt armake build --force -i include "..\_build\$($verDir)" ".\release\@vindicta\addons\vindicta_v$($verStr).pbo" -w unquoted-string -w redefinition-wo-undef -w excessive-concatenation
"Signing mission pbo..."
.\tools\DSSignFile $privateKey ".\release\@vindicta\addons\vindicta_v$($verStr).pbo"

# .\tools\armake_w64 sign "vindicta_v$($verStr).biprivatekey" ".\release\@vindicta\addons\vindicta_v$($verStr).pbo"

$modules = Get-ChildItem -Path "addons" -Directory

foreach ($module in $modules) {
    $pboName = ".\release\@vindicta\addons\vindicta_$($module.Name).pbo"
    "Building $($pboName)..."
    .\tools\hemtt armake build --force -i include  "addons\$($module.Name)" $pboName -w unquoted-string -w redefinition-wo-undef -w excessive-concatenation
    "Signing $($pboName)..."
    .\tools\DSSignFile $privateKey $pboName
    # .\tools\hemtt armake sign "vindicta_v$($verStr).biprivatekey" $pboName
}

$extraFiles = Get-ChildItem -Path "extras" -File

foreach ($extraFile in $extraFiles) {
    "Copying extra file $($extraFile.Name) ..."
    Copy-Item ".\extras\$($extraFile.Name)" ".\release\@vindicta\$($extraFile.Name)"
}

# Make the standalone pbos as well
New-Item ".\dev" -ItemType "directory" -Force | Out-Null

$maps = @("Altis", "Enoch", "Malden", "Tembelan", "Takistan", "Beketov", "gm_weferlingen_summer", "Staszow", "cup_chernarus_A3")
foreach ($map in $maps) {
    $mapLower = $map.toLower();
    "Building standalone mission vindicta_$($mapLower)_v$($verStr).$($mapLower).pbo..."
    .\tools\hemtt armake build --force -i include "..\_build\Vindicta_$($map)_v$($verStr).$($map)" ".\dev\vindicta_$($mapLower)_v$($verStr).$($mapLower).pbo" -w unquoted-string -w redefinition-wo-undef -w excessive-concatenation
}