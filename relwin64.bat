for /f "tokens=3 usebackq" %%G in (include\config\confver.hpp) do set VE_VER=%%G
echo %VE_VER%
set VE_VER_PHASE=release
mkdir VeoLink-CE-%VE_VER%-win64-%VE_VER_PHASE%
REM copy dir from client and vecvr
xcopy /y /e client\prj_win32\x64\Release  VeoLink-CE-%VE_VER%-win64-%VE_VER_PHASE%
xcopy /y /e vecvr\prj_win32\x64\Release  VeoLink-CE-%VE_VER%-win64-%VE_VER_PHASE%

REM cooy service file
xcopy /y /e output\windows\nssm\win64\nssm.exe  VeoLink-CE-%VE_VER%-win64-%VE_VER_PHASE%
xcopy /y output\windows\gencertificate.bat  VeoLink-CE-%VE_VER%-win64-%VE_VER_PHASE%
xcopy /y output\windows\regservice64.bat  VeoLink-CE-%VE_VER%-win64-%VE_VER_PHASE%
xcopy /y output\windows\unregservice64.bat  VeoLink-CE-%VE_VER%-win64-%VE_VER_PHASE%

del  VeoLink-CE-%VE_VER%-win64-%VE_VER_PHASE%\*.pdb /f /s /q
del  VeoLink-CE-%VE_VER%-win64-%VE_VER_PHASE%\*.lik /f /s /q
del  VeoLink-CE-%VE_VER%-win64-%VE_VER_PHASE%\*.lib /f /s /q
del  VeoLink-CE-%VE_VER%-win64-%VE_VER_PHASE%\*.exp /f /s /q

