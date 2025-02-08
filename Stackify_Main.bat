@echo off
title Stackify Sandbox Creator v3.0
color 0a
setlocal EnableDelayedExpansion

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Administrator privileges required.
    powershell -Command "Start-Process '%~dpnx0' -Verb RunAs"
    exit /b
)

ver | find "10." >nul
if errorlevel 1 (
    ver | find "11." >nul
    if errorlevel 1 (
        echo Windows 10/11 required for Windows Sandbox
        pause
        exit /b
    )
)

dism /online /get-featureinfo /featurename:Containers-DisposableClientVM | find "State : Enabled" >nul
if errorlevel 1 (
    echo Enabling Windows Sandbox feature...
    powershell -Command "Enable-WindowsOptionalFeature -Online -FeatureName 'Containers-DisposableClientVM' -All -NoRestart"
    echo Please restart your computer to complete setup.
    pause
    exit /b
)

:menu
cls
echo Stackify Sandbox Creator v3.0
echo ===========================
echo.
echo Select Version:
echo 1. Simple Version (Basic settings, quick setup)
echo 2. Advanced Version (Detailed configuration options)
echo 3. Enterprise Version (Full security and management features)
echo.
set /p "version=Select version (1-3): "

if "%version%"=="1" goto simple
if "%version%"=="2" goto advanced
if "%version%"=="3" goto enterprise

:simple
cls
echo Simple Sandbox Configuration
echo ==========================
echo.

echo RAM Configuration:
echo 1. Low (2GB)
echo 2. Medium (4GB) 
echo 3. High (8GB)
set /p "ramChoice=Select RAM (1-3): "

if "%ramChoice%"=="1" (set "ram=2")
if "%ramChoice%"=="2" (set "ram=4")
if "%ramChoice%"=="3" (set "ram=8")

echo.
echo Network Configuration:
echo 1. Disabled
echo 2. Enabled
set /p "netChoice=Select network (1-2): "

if "%netChoice%"=="1" (set "networkEnabled=Disable")
if "%netChoice%"=="2" (set "networkEnabled=Enable")

echo.
echo Map user folder to sandbox?
set /p "mapFolder=Map folder (y/n): "

set "configFile=%~dp0simple_sandbox.wsb"
(
echo ^<?xml version="1.0" encoding="UTF-8"?^>
echo ^<Configuration^>
echo     ^<VGpu^>Enable^</VGpu^>
echo     ^<Networking^>%networkEnabled%^</Networking^>
echo     ^<MemoryInMB^>%ram%000^</MemoryInMB^>
if /i "%mapFolder%"=="y" (
    echo     ^<MappedFolders^>X
    echo         ^<MappedFolder^>
    echo             ^<HostFolder^>%USERPROFILE%^</HostFolder^>
    echo             ^<SandboxFolder^>C:\Users\WDAGUtilityAccount\Desktop\HostUserFolder^</SandboxFolder^>
    echo             ^<ReadOnly^>false^</ReadOnly^>
    echo         ^</MappedFolder^>
    echo     ^</MappedFolders^>
)
echo ^</Configuration^>
) > "!configFile!"

echo.
echo Simple sandbox configuration created!
start "" "!configFile!"
exit /b

:advanced
cls
echo Advanced Sandbox Configuration
echo ============================
echo.

echo RAM Configuration:
echo 1. Low (2GB)
echo 2. Medium (4GB)
echo 3. High (8GB)
echo 4. Custom
set /p "ramChoice=Select RAM (1-4): "

if "%ramChoice%"=="1" (set "ram=2")
if "%ramChoice%"=="2" (set "ram=4")
if "%ramChoice%"=="3" (set "ram=8")
if "%ramChoice%"=="4" (
    set /p "ram=Enter RAM in GB: "
)

echo.
echo GPU Configuration:
echo 1. Disabled
echo 2. Basic
echo 3. Full acceleration
set /p "gpuChoice=Select GPU config (1-3): "

if "%gpuChoice%"=="1" (set "gpuEnabled=Disable")
if "%gpuChoice%"=="2" (
    set "gpuEnabled=Enable"
    set "gpuLevel=Basic"
)
if "%gpuChoice%"=="3" (
    set "gpuEnabled=Enable"
    set "gpuLevel=Full"
)

echo.
echo Network Configuration:
echo 1. Disabled
echo 2. Basic
echo 3. Full access
set /p "netChoice=Select network (1-3): "

if "%netChoice%"=="1" (set "networkEnabled=Disable")
if "%netChoice%"=="2" (set "networkEnabled=Default")
if "%netChoice%"=="3" (set "networkEnabled=Default" & set "fullAccess=true")

echo.
echo Folder Mapping:
echo 1. None
echo 2. User folder
echo 3. Custom folder
set /p "folderChoice=Select mapping (1-3): "

set "configFile=%~dp0advanced_sandbox.wsb"
(
echo ^<?xml version="1.0" encoding="UTF-8"?^>
echo ^<Configuration^>
echo     ^<VGpu^>%gpuEnabled%^</VGpu^>
if defined gpuLevel echo     ^<VGpuLevel^>%gpuLevel%^</VGpuLevel^>
echo     ^<Networking^>%networkEnabled%^</Networking^>
echo     ^<MemoryInMB^>%ram%000^</MemoryInMB^>
if "%folderChoice%"=="2" (
    echo     ^<MappedFolders^>
    echo         ^<MappedFolder^>
    echo             ^<HostFolder^>%USERPROFILE%^</HostFolder^>
    echo             ^<SandboxFolder^>C:\Users\WDAGUtilityAccount\Desktop\HostUserFolder^</SandboxFolder^>
    echo             ^<ReadOnly^>false^</ReadOnly^>
    echo         ^</MappedFolder^>
    echo     ^</MappedFolders^>
)
if "%folderChoice%"=="3" (
    set /p "customFolder=Enter folder path to map: "
    echo     ^<MappedFolders^>
    echo         ^<MappedFolder^>
    echo             ^<HostFolder^>%customFolder%^</HostFolder^>
    echo             ^<SandboxFolder^>C:\MappedFolder^</SandboxFolder^>
    echo             ^<ReadOnly^>false^</ReadOnly^>
    echo         ^</MappedFolder^>
    echo     ^</MappedFolders^>
)
echo ^</Configuration^>
) > "!configFile!"

echo.
echo Advanced sandbox configuration created!
start "" "!configFile!"
exit /b

:enterprise
cls
echo Enterprise Sandbox Configuration
echo ==============================
echo.

for /f "tokens=2 delims==" %%a in ('wmic computersystem get totalphysicalmemory /value') do set "totalRAM=%%a"
set /a "totalRAM=%totalRAM:~0,-3%/1074000000"

echo RAM Configuration:
echo 1. Standard (8GB)
echo 2. Performance (16GB)
echo 3. Maximum (!totalRAM!/2 GB)
echo 4. Dynamic scaling
set /p "ramChoice=Select RAM (1-4): "

if "%ramChoice%"=="1" (set "ram=8")
if "%ramChoice%"=="2" (set "ram=16")
if "%ramChoice%"=="3" (set /a "ram=!totalRAM!/2")
if "%ramChoice%"=="4" (
    set "dynamicRAM=true"
    set /a "ram=!totalRAM!/4"
)

echo.
echo Security Configuration:
echo 1. Standard
echo 2. Enhanced
echo 3. Maximum
set /p "secChoice=Select security level (1-3): "

if "%secChoice%"=="1" (
    set "protectEnabled=Enable"
    set "firewallEnabled=Standard"
)
if "%secChoice%"=="2" (
    set "protectEnabled=Enable"
    set "firewallEnabled=Enhanced"
    set "encryptionEnabled=true"
)
if "%secChoice%"=="3" (
    set "protectEnabled=Enable"
    set "firewallEnabled=Maximum"
    set "encryptionEnabled=true"
    set "networkIsolation=true"
)

echo.
echo Network Configuration:
echo 1. Isolated
echo 2. Restricted
echo 3. Enterprise VPN
set /p "netChoice=Select network (1-3): "

if "%netChoice%"=="1" (
    set "networkEnabled=Disable"
    set "networkIsolation=true"
)
if "%netChoice%"=="2" (
    set "networkEnabled=Default"
    set "firewallEnabled=Maximum"
)
if "%netChoice%"=="3" (
    set "networkEnabled=Default"
    set "vpnEnabled=true"
    set /p "vpnConfig=Enter VPN configuration path: "
)

set "configFile=%~dp0enterprise_sandbox.wsb"
(
echo ^<?xml version="1.0" encoding="UTF-8"?^>
echo ^<Configuration^>
echo     ^<VGpu^>Enable^</VGpu^>
echo     ^<Networking^>%networkEnabled%^</Networking^>
echo     ^<ProtectedClient^>%protectEnabled%^</ProtectedClient^>
if defined firewallEnabled echo     ^<FirewallLevel^>%firewallEnabled%^</FirewallLevel^>
if defined vpnEnabled echo     ^<VpnConfiguration^>%vpnConfig%^</VpnConfiguration^>
echo     ^<MemoryInMB^>%ram%000^</MemoryInMB^>
if defined dynamicRAM echo     ^<DynamicMemory^>Enable^</DynamicMemory^>
if defined encryptionEnabled echo     ^<EncryptionLevel^>Enterprise^</EncryptionLevel^>
echo     ^<MappedFolders^>
echo         ^<MappedFolder^>
echo             ^<HostFolder^>%USERPROFILE%^</HostFolder^>
echo             ^<SandboxFolder^>C:\Users\WDAGUtilityAccount\Desktop\HostUserFolder^</SandboxFolder^>
if defined encryptionEnabled echo             ^<Encryption^>Enable^</Encryption^>
echo             ^<ReadOnly^>false^</ReadOnly^>
echo         ^</MappedFolder^>
echo     ^</MappedFolders^>
echo     ^<LogonCommand^>
echo         ^<Command^>powershell -WindowStyle Hidden -Command "Set-MpPreference -EnableNetworkProtection Enabled; Set-ProcessMitigation -SystemSettings -Enable DEP,SEHOP,ForceRelocateImages"^</Command^>
echo     ^</LogonCommand^>
echo ^</Configuration^>
) > "!configFile!"

echo.
echo Enterprise sandbox configuration created!
start "" "!configFile!"
exit /b
