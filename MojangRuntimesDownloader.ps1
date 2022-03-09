# Download Mojang Runtimes # 
Set-Location ~\Documents\Tantalum-Mirror\temp\;
# This Script Downloads And Makes A Image From Dynmap
$httpClient = New-Object System.Net.Http.HttpClient
function Downloader {
    param ([String]$Url, [String]$File)
    #Write-Host("Downloader File: {0}" -f $File)
    # Create the HTTP client download request
    $response = $httpClient.GetAsync($Url)
    $response.Wait()
    # Create a file stream to pointed to the output file destination
    $outputFileStream = [System.IO.FileStream]::new($File, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)
    # Stream the download to the destination file stream
    $downloadTask = $response.Result.Content.CopyToAsync($outputFileStream)
    $downloadTask.Wait()
    # Close the file stream
    $outputFileStream.Close()   
}

# MainMenu;
Write-Host(" Welcome To The Mojang Runtime Downloader
Platform Options Are: 
    GameCore: gc
    Linux: lx
    Linux-I386: lx-I
    Mac-os: mac
    Windows-X64: x64
    Windows-X86: x86
Platform Default: x64
Version Options Are: 
    Alpha: a
    Beta: b
    Legacy: l 
    Minecraft-Exe: m
Version Default: b
")
# Platform Selection #
$PlatRead = (Read-Host -Prompt "Platform").ToLower();
$PlatformNames = @{
    "gc" = "gamecore"
    "lx" = "linux"
    "lx-i" = "linux-i386"
    "mac" = "mac-os"
    "x64" = "windows-x64"
    "x86" = "windows-x86"
};
if (-not($PlatformNames.Contains($PlatRead))) {
    Write-Host "Invalid Platform Defaulting"
    $PlatRead = "x64";
}
$Platform = $PlatformNames[$PlatRead];
# Version Selection #
$VerRead = (Read-Host -Prompt "Version").ToLower();
$VersionNames = @{
    "a" = "java-runtime-alpha"
    "b" = "java-runtime-beta"
    "l" = "jre-legacy"
    "m" = "minecraft-java-exe"
}
if (-not($VersionNames.Contains($VerRead))) {
    Write-Host "Invalid Version Defaulting"
    $VerRead = "b";
}
$Version = $VersionNames[$VerRead];
$LMZA = $false;
if ((Read-Host -Prompt "LMZA(False)").ToLower() -eq "true") {
    $LMZA = $true;
}
$CurrentLocation = Get-Location;
if ($LMZA) {
    $CurrentLocation = "{0}\LMZA-RAW\" -f (Get-Location);
}
$MojangRuntimesUrl = "https://launchermeta.mojang.com/v1/products/java-runtime/2ec0cc96c44e5a76b9c8b7c39df7210883d12871/all.json";
$MojangRuntimesFile = "{0}\all.json" -f (Get-Location);
$PlatformFolder = "{0}\{1}" -f $CurrentLocation,$Platform;
if (-not(Test-Path -Path $PlatformFolder -PathType Container)) {
    mkdir $PlatformFolder;
}
$RuntimeFolder = "{0}\{1}" -f $PlatformFolder,$Version;
if (-not(Test-Path -Path $RuntimeFolder -PathType Container)) {
    mkdir $RuntimeFolder;
}
$ManifestFile = "{0}\{1}.json" -f $PlatformFolder,$Version;
if ([System.IO.File]::Exists($ManifestFile)){
    Remove-Item($ManifestFile);
}
if ([System.IO.File]::Exists($MojangRuntimesFile)){
    Remove-Item($MojangRuntimesFile);
}
Downloader -Url $MojangRuntimesUrl -File $MojangRuntimesFile;
$MojangRuntimes = (Get-Content($MojangRuntimesFile) | ConvertFrom-Json -Depth 800 -AsHashtable)

$TimeitToke = Measure-Command {
    Write-Host "Starting Download System";
    Write-Host "Getting Java Runtime Manifest"
    $MInfo = $MojangRuntimes[$Platform][$Version][0];
    Write-Host ($MInfo | ConvertTo-Json);
    Write-Host("Selected Platform: {0}"-f $Platform)
    Write-Host("Selected Version: {0}"-f $Version) 
    Write-Host "Manifest Information:"
    Write-Host "    Availability:"
    Write-Host("        Group: {0}"-f$MInfo['availability']['group']);
    Write-Host("        Progress: {0}"-f$MInfo['availability']['progress']);
    Write-Host("    Manifest:");
    Write-Host("        SHA-1: {0}"-f$MInfo['manifest']['sha1']);
    Write-Host("        Size: {0}"-f$MInfo['manifest']['size']);
    Write-Host("        Url: {0}"-f$MInfo['manifest']['url']);
    Write-Host("    Version:");
    Write-Host("        Name: {0}"-f$MInfo['version']['name'])
    Write-Host("        Released: {0}"-f$MInfo['version']['released']);
    Downloader -Url $MInfo['manifest']['url'] -File $ManifestFile;
    Write-Host "Checking Size: " -NoNewline;
    if ((Get-Item $ManifestFile).Length -eq $MInfo['manifest']['size']) {
        Write-Host "Passed" -ForegroundColor Green;
    } else {
        Write-Host "Failed" -ForegroundColor Red;
    }
    Write-Host "Checking Hash: " -NoNewline;
    if ((Get-FileHash -Path $ManifestFile -Algorithm SHA1).Hash -eq $MInfo['manifest']['sha1'].ToUpper()) {
        Write-Host "Passed" -ForegroundColor Green;
    } else {Write-Host "Failed" -ForegroundColor Red;}
    $Manifest = (Get-Content $ManifestFile | ConvertFrom-Json -Depth 800 -AsHashtable )['files'];
    foreach ($FileN in $Manifest.Keys) {
        $FileD = $Manifest.$FileN;
        Write-Host("Grabing: {0}"-f$FileN);
        if ($FileD['type'] -eq "file") {
            $FilePath = Join-Path -Path $RuntimeFolder -ChildPath $FileN;
            $FileParent = Split-Path $FilePath;
            if (-not [System.IO.File]::Exists($FilePath)){
                if (-not (Test-Path -Path $FileParent)) {
                    New-Item -Path $FileParent -ItemType Directory;
                }
                Downloader -Url $FileD['downloads']['raw']['url'] -File $FilePath;
            } else {Write-Host "Already Exstits"}
            Write-Host("Relative: {0}"-f(Resolve-Path -Path $FilePath -Relative))
        } else {
            Write-Host "Not A File";
        }
    }
}
Write-Host("Downloading Required Files Took: {0}"-f $TimeitToke);