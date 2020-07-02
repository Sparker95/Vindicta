@echo off
if not exist src\config\user_local_config.hpp copy src\config\user_local_config.hpp.template src\config\user_local_config.hpp
if not exist Vindicta.Malden\src mklink /D /J Vindicta.Malden\src src
POPD
