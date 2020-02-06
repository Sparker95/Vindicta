Remove-Item release -Recurse -Force -ErrorAction Ignore | Out-Null
Remove-Item dev -Recurse -Force -ErrorAction Ignore | Out-Null
Remove-Item *.bikey -Force -ErrorAction Ignore | Out-Null
Remove-Item *.biprivatekey -Force -ErrorAction Ignore | Out-Null
Remove-Item ..\_build -Recurse -Force -ErrorAction Ignore | Out-Null

