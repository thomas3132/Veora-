param(
    [Parameter(Mandatory = $true)]
    [string]$SourcePath,

    [Parameter(Mandatory = $true)]
    [string]$ModRootPath,

    [Parameter(Mandatory = $false)]
    [string]$PackName = "Skyfall 2.0 - Full Texture Overhaul",

    [Parameter(Mandatory = $false)]
    [string]$ProfileName = "testing",

    [Parameter(Mandatory = $false)]
    [switch]$CreateArchive
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "[Build-SkyrimTexturePack] $Message"
}

if (-not (Test-Path -LiteralPath $SourcePath)) {
    throw "SourcePath not found: $SourcePath"
}

if (-not (Test-Path -LiteralPath $ModRootPath)) {
    Write-Step "Mod root does not exist. Creating: $ModRootPath"
    New-Item -Path $ModRootPath -ItemType Directory -Force | Out-Null
}

$targetModPath = Join-Path $ModRootPath $PackName
$stagePath = Join-Path $env:TEMP ("skyrim-pack-stage-" + [guid]::NewGuid().ToString())

Write-Step "Source      : $SourcePath"
Write-Step "MO2 mods    : $ModRootPath"
Write-Step "Pack name   : $PackName"
Write-Step "MO2 profile : $ProfileName"
Write-Step "Stage       : $stagePath"

New-Item -Path $stagePath -ItemType Directory -Force | Out-Null

# Build standard mod layout
$stageTextures = Join-Path $stagePath "textures"
New-Item -Path $stageTextures -ItemType Directory -Force | Out-Null

$sourceTextures = Join-Path $SourcePath "textures"
$sourceMeshes = Join-Path $SourcePath "meshes"

if (Test-Path -LiteralPath $sourceTextures) {
    Write-Step "Copying existing textures folder"
    Copy-Item -Path (Join-Path $sourceTextures "*") -Destination $stageTextures -Recurse -Force
}
else {
    Write-Step "No top-level textures folder found. Copying all source assets into textures/"
    Copy-Item -Path (Join-Path $SourcePath "*") -Destination $stageTextures -Recurse -Force
}

if (Test-Path -LiteralPath $sourceMeshes) {
    $stageMeshes = Join-Path $stagePath "meshes"
    New-Item -Path $stageMeshes -ItemType Directory -Force | Out-Null
    Write-Step "Copying meshes folder"
    Copy-Item -Path (Join-Path $sourceMeshes "*") -Destination $stageMeshes -Recurse -Force
}

# Add MO2 metadata
$metaIni = @"
[General]
Name=$PackName
Version=1.0
InstallationFile=
Repository=
"@
Set-Content -LiteralPath (Join-Path $stagePath "meta.ini") -Value $metaIni -Encoding UTF8

# Replace old build and copy staged content
if (Test-Path -LiteralPath $targetModPath) {
    Write-Step "Removing old pack at: $targetModPath"
    Remove-Item -LiteralPath $targetModPath -Recurse -Force
}

Write-Step "Copying staged pack to MO2 mods directory"
Copy-Item -Path $stagePath -Destination $targetModPath -Recurse -Force

if ($CreateArchive) {
    $archiveBase = Join-Path $ModRootPath ($PackName -replace '[\\/:*?"<>|]', '_')
    $zipPath = "$archiveBase.zip"

    if (Test-Path -LiteralPath $zipPath) {
        Remove-Item -LiteralPath $zipPath -Force
    }

    Write-Step "Creating zip archive: $zipPath"
    Compress-Archive -Path (Join-Path $stagePath "*") -DestinationPath $zipPath -Force
}

Write-Step "Done. Pack created at: $targetModPath"
Write-Step "Next: open MO2, select profile '$ProfileName', and enable '$PackName'."

Remove-Item -LiteralPath $stagePath -Recurse -Force
