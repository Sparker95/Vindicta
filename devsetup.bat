@echo off
PUSHD "%~dp0"
copy Vindicta.Altis\config\user_local_config.hpp.template Vindicta.Altis\config\user_local_config.hpp
call tools\copy_sqm_from_github.bat
POPD