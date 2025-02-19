:: Copyright (c) 2023 Un.33k (www.github.com/UNdot33K) 

:: Permission is hereby granted, free of charge, to any person obtaining a copy 
:: of this software and associated documentation files (the "Software"), to deal 
:: in the Software without restriction, including without limitation the rights 
:: to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
:: of the Software, and to permit persons to whom the Software is furnished to do so, 
:: subject to the following conditions:

:: The above copyright notice and this permission notice shall be included in all 
:: copies or substantial portions of the Software.

:: THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
:: INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
:: PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
:: HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
:: OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
:: SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

@echo off

ECHO ********************************************************
ECHO [SC_AV] v0.95.4b Is Running, Please Wait...
ECHO Copyright (c) 2022 --Un.33K--
ECHO ********************************************************

set "file_types=exe dll bat sys ini"
set "dest=%userprofile%\Desktop\SC_AV\Hashes"
set "hmf=%userprofile%\Desktop\SC_AV\"
set "logs=%userprofile%\Desktop\SC_AV\Logs"
set "crc=%userprofile%\Desktop\SC_AV\HMF.exe"
set "comp=cscript //NoLogo %userprofile%\Desktop\SC_AV\cmp.vbs"

:: Check if there are any installation issues

cd %hmf%

if not exist HMF.exe goto err
if not exist cmp.vbs goto err
if not exist "%userprofile%\Desktop\SC_AV\Hashes" goto err
if not exist "%userprofile%\Desktop\SC_AV\Logs" goto err

if not exist initial ( 
   if not exist "%dest%\Hashes_exe.txt" (
:err
    echo.
    echo Please run install.bat using administrative privileges.
    pause
    goto end
    )
)

:: Main code

for %%f in (%file_types%) do ( 
    echo.
    echo Checking: %%f
    %crc% /wildcard "C:\*.%%f" 3 /CRC32 1 /stext "%dest%\Hashes_%%f0" 
    type "%dest%\Hashes_%%f0" > "%dest%\Hashes_%%f0.txt" 
    del "%dest%\Hashes_%%f0" 
    if not exist initial (
:: to troubleshoot an issue in some weird cases.    
       set %errorlevel%=1 
       %comp% "%dest%\Hashes_%%f.txt" "%dest%\Hashes_%%f0.txt" "%logs%\log_%%f.txt"
       call :res
    )
)


cd %dest%\
del Hashes_reg0.txt 2>nul


:: Loop through each specified registry key and export it to a temporary file

for %%a in (
     Classes\cmdfile 
     Classes\comfile 
     Classes\exefile 
     Classes\piffile 
     Classes\AllFilesystemObjects 
     Classes\Directory 
     Classes\Folder 
     Classes\Protocols 
     Policies
) do (
    reg export "HKEY_LOCAL_MACHINE\Software\%%a" temp.tmp /y >nul
    type temp.tmp >> Hashes_reg0.txt
)

for %%a in (
     "Explorer\Shell Folders"
     "Explorer\User Shell Folders" 
     Run 
     RunOnce
) do (
    reg export "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\%%~a" temp.tmp /y >nul
    type temp.tmp >> Hashes_reg0.txt
)
  

for %%a in (
     "Windows NT\CurrentVersion\IniFileMapping\SYSTEM.ini\boot" 
     "Windows NT\CurrentVersion\Windows" 
     "Windows NT\CurrentVersion\Winlogon" 
     "Windows\CurrentVersion\Explorer\Shell Folders" 
     "Windows\CurrentVersion\Explorer\User Shell Folders" 
     "Windows\CurrentVersion\Run" 
     "Windows\CurrentVersion\RunOnce" 
) do (
      reg export "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\%%~a" temp.tmp /y >nul
      type temp.tmp >> Hashes_reg0.txt
)


for %%a in (
     hivelist 
     "Session Manager\KnownDLLs" 
) do (
    reg export "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\%%~a" temp.tmp /y >nul
    type temp.tmp >> Hashes_reg0.txt
)


for %%a in (
     DomainProfile 
     PublicProfile
     StandardProfile
      
) do (
    reg export "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\%%a" temp.tmp /y >nul
    type temp.tmp >> Hashes_reg0.txt
)

del temp.tmp

:: Compare the exported registry keys

echo.
echo Checking: Registry

cd %hmf%

if not exist initial (
    %comp% "%dest%\Hashes_reg.txt" "%dest%\Hashes_reg0.txt" "%Logs%\log_reg.txt"
    call :res
    )


if exist initial (
  del initial
  goto MRT
)


echo.				
echo File integrity check, successfully completed.

timeout /t 5 > nul

:: Get the current local date and time using the wmic command

for /F "skip=1 tokens=2 delims==" %%a in ('wmic os get localdatetime /format:list') do set datetime=%%a
set day=%datetime:~6,2%

if /I "%day%" == "03" goto MRT
if /I "%day%" == "06" goto MRT
if /I "%day%" == "09" goto MRT
if /I "%day%" == "12" goto MRT
if /I "%day%" == "15" goto MRT
if /I "%day%" == "18" goto MRT
if /I "%day%" == "21" goto MRT
if /I "%day%" == "24" goto MRT
if /I "%day%" == "27" goto MRT
if /I "%day%" == "30" goto MRT
goto LoFlag

:MRT

if not exist flag (

  cd %dest%\

  for %%a in (Hashes_exe.txt Hashes_dll.txt Hashes_bat.txt Hashes_sys.txt Hashes_ini.txt Hashes_reg.txt) do (
    del %%a 2> nul
  )

  for %%b in (exe dll bat sys ini reg) do (
    ren Hashes_%%b0.txt Hashes_%%b.txt 2>nul
  )

  MRT.EXE /F:Y
  cd %hmf%
  echo > flag
  goto end

) else (
  goto end
)

:LoFlag
cd %hmf%
del flag 2>nul
goto end

:res
:: echo %errorlevel%
if %errorlevel% equ 0 (
   echo [Integrity] - The Files Are Identical.
   exit /b

) else (
    goto noid
)

:noid
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set "DEL=%%a"
)

call :colorEcho 70 "[Integrity] - The Files Are Not Identical,"
echo.
echo differences written to: %logs%"
echo.
exit /b

:colorEcho
<nul set /p ".=%DEL%" > "%~2"
findstr /v /a:%1 /R "^$" "%~2" nul
del "%~2" > nul
exit /b

:end
