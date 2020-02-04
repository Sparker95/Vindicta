..\tools\setup_and_build.bat
$verDir = (Get-ChildItem -Path ..\_build -Filter "vindicta_v*").Name
$verStr = $verDir -replace "vindicta_v",""

"Building Vindicta v$($verStr)"

# echo "::set-env name=version::$($verStr)"
# (Get-Content -path hemtt.json -Raw) -replace '0.0.0',$verStr | Set-Content -Path hemtt.json
# .\tools\hemtt.exe build --release --force --nowarn

"Creating key..."
.\tools\DSCreateKey "vindicta"
$privateKey = "vindicta.biprivatekey"
New-Item ".\release\@vindicta\keys" -ItemType "directory"
New-Item ".\release\@vindicta\addons" -ItemType "directory"
Copy-Item "vindicta.bikey" ".\release\@vindicta\keys\vindicta.bikey"
"Building mission pbo..."
.\tools\armake_w64 build -i include "..\_build\$($verDir)" ".\release\@vindicta\addons\vindicta_v$($verStr).pbo" -w unquoted-string -w redefinition-wo-undef -w excessive-concatenation
"Signing mission pbo..."
.\tools\DSSignFile $privateKey ".\release\@vindicta\addons\vindicta_v$($verStr).pbo"

# .\tools\armake_w64 sign "vindicta_v$($verStr).biprivatekey" ".\release\@vindicta\addons\vindicta_v$($verStr).pbo"

$modules = Get-ChildItem -Path "addons" -Directory

foreach ($module in $modules) {
    $pboName = ".\release\@vindicta\addons\vindicta_$($module.Name).pbo"
    "Building $($pboName)..."
    .\tools\armake_w64 build -i include  "addons\$($module.Name)" $pboName -w unquoted-string -w redefinition-wo-undef -w excessive-concatenation
    "Signing $($pboName)..."
    .\tools\DSSignFile $privateKey $pboName
    # .\tools\armake_w64 sign "vindicta_v$($verStr).biprivatekey" $pboName
}

$extraFiles = @(
    "mod.cpp",
    "README.md",
    "AUTHORS.txt",
    "LICENSE",
    "logo_vindicta.paa"
)

foreach ($extraFile in $extraFiles) {
    "Copying extra file $($extraFile) ..."
    Copy-Item $extraFile ".\release\@vindicta\$($extraFile)"
}

# Make the standalone pbos as well
New-Item ".\dev" -ItemType "directory"
ls ..\_build

"..\_build\Vindicta_Altis_$($verStr).Altis"
".\dev\vindicta_altis_$($verStr).altis.pbo"

"Building standalone mission vindicta_altis_$($verStr).altis.pbo..."
.\tools\armake_w64 build -i include "..\_build\Vindicta_Altis_$($verStr).Altis" ".\dev\vindicta_altis_$($verStr).altis.pbo" -w unquoted-string -w redefinition-wo-undef -w excessive-concatenation
"Building standalone mission vindicta_enoch_$($verStr).enoch.pbo..."
.\tools\armake_w64 build -i include "..\_build\Vindicta_Enoch_$($verStr).Enoch" ".\dev\vindicta_enoch_$($verStr).enoch.pbo" -w unquoted-string -w redefinition-wo-undef -w excessive-concatenation
