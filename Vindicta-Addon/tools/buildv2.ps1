..\tools\setup_and_build.bat
$verDir = (Get-ChildItem -Path ..\_build -Filter "vindicta_v*").Name
$verStr = $verDir -replace "vindicta_v",""
# echo "::set-env name=version::$($verStr)"
# (Get-Content -path hemtt.json -Raw) -replace '0.0.0',$verStr | Set-Content -Path hemtt.json
# .\tools\hemtt.exe build --release --force --nowarn

.\tools\armake_w64 keygen "vindicta_v$($verStr)"
$privateKey = "vindicta_v$($verStr).biprivatekey"
New-Item ".\release\@vindicta\keys" -ItemType "directory"
New-Item ".\release\@vindicta\addons" -ItemType "directory"
Copy-Item "vindicta_v$($verStr).bikey" ".\release\@vindicta\keys\vindicta_v$($verStr).bikey"
.\tools\armake_w64 build -i include -k $privateKey "..\_build\$($verDir)" ".\release\@vindicta\addons\vindicta_v$($verStr).pbo" -w unquoted-string -w redefinition-wo-undef -w excessive-concatenation
# .\tools\armake_w64 sign "vindicta_v$($verStr).biprivatekey" ".\release\@vindicta\addons\vindicta_v$($verStr).pbo"

$modules = Get-ChildItem -Path "addons" -Directory

foreach ($module in $modules) {
    $pboName = ".\release\@vindicta\addons\vindicta_$($module.Name).pbo"
    .\tools\armake_w64 build -i include -k $privateKey "addons\$($module.Name)" $pboName -w unquoted-string -w redefinition-wo-undef -w excessive-concatenation
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
