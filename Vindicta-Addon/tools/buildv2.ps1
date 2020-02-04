..\tools\setup_and_build.bat
$verDir = (Get-ChildItem -Path ..\_build -Filter "vindicta_v*").Name
$verStr = $verDir -replace "vindicta_v",""
# echo "::set-env name=version::$($verStr)"
# (Get-Content -path hemtt.json -Raw) -replace '0.0.0',$verStr | Set-Content -Path hemtt.json
# .\tools\hemtt.exe build --release --force --nowarn

.\tools\DSCreateKey "vindicta"
$privateKey = "vindicta.biprivatekey"
New-Item ".\release\@vindicta\keys" -ItemType "directory"
New-Item ".\release\@vindicta\addons" -ItemType "directory"
Copy-Item "vindicta.bikey" ".\release\@vindicta\keys\vindicta.bikey"
.\tools\armake_w64 build -i include "..\_build\$($verDir)" ".\release\@vindicta\addons\vindicta_v$($verStr).pbo" -w unquoted-string -w redefinition-wo-undef -w excessive-concatenation
.\tools\DSSignFile $privateKey ".\release\@vindicta\addons\vindicta_v$($verStr).pbo"

# .\tools\armake_w64 sign "vindicta_v$($verStr).biprivatekey" ".\release\@vindicta\addons\vindicta_v$($verStr).pbo"

$modules = Get-ChildItem -Path "addons" -Directory

foreach ($module in $modules) {
    $pboName = ".\release\@vindicta\addons\vindicta_$($module.Name).pbo"
    .\tools\armake_w64 build -i include  "addons\$($module.Name)" $pboName -w unquoted-string -w redefinition-wo-undef -w excessive-concatenation
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
    Copy-Item $extraFile ".\release\@vindicta\$($extraFile)"
}
