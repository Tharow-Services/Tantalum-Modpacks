$block = {
# Setup Php Eviroment #
$toreplace = 762,915,918,919,925,931,927,933,936,937;
$ProgressPreference = 'SilentlyContinue'
Write-Host "Downloading PHP 8.1 Zip"
$name = -join ((65..90) + (97..122) | Get-Random -Count 10 | % {[char]$_})
$file = "{0}\{1}.zip" -f $Env:TMP,$name;
#echo $file;
Invoke-RestMethod -Method GET -Uri "https://windows.php.net/downloads/releases/php-8.1.4-nts-Win32-vs16-x64.zip" -OutFile $file;
Write-Host "Expanding Arkive";
$installdir = "{0}\programs\PHP-8.1" -f $env:LOCALAPPDATA;
Expand-Archive -Path $file -DestinationPath $installdir -Force;
#setx.exe PATH ("{0};{1}" -f $ENV:PATH,$installdir);
$pathString = "{0};{1}" -f [Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User),$installdir;
[Environment]::SetEnvironmentVariable("Path", $pathString, [System.EnvironmentVariableTarget]::User);
Write-Host "Path Updated";
Write-Host "Setup Php Config"
Move-Item -Path "$installdir\php.ini-development" -Destination "$installdir\php.ini";
Write-Host "Gettting Config Map: ENV: DEV | VERSION: STABLE 8.1.4-nts-Windows-vs16-x64"
$content = Get-Content ("{0}\php.ini" -f $installdir);
foreach ($i in $toreplace) {
    $temp = $content[$i];
    Write-Host ("Maping Found: [UNCOMMENT]: LINE_NUMBER: {0} | LINE: {1}" -f $i,$temp)
    $content[$i] = $temp.Replace(";","");
    #Write-Host("Uncommenting Line: {0}, {1}" -f ($i-1),$content[($i-1)])
}
$content | Set-Content ("{0}\php.ini" -f $installdir);
Read-Host "Press Enter To Exit"
exit(0);
}.ToString();

$encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($block))
$startcmd = ('@start powershell -enc "{0}" '-f$encoded);
New-Item -Path "~\Desktop\phpInstall.bat" -ItemType file -Value $startcmd

#powershell -EncodedCommand 