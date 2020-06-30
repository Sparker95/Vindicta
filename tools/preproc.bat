@echo off
cd "%~dp0"
echo %1
.\SQF-VM\sqfvm.exe -a --no-execute-print --load . -E "%~1" --disable-macro-warnings >"%~1.preproc"
code "%~1.preproc"
