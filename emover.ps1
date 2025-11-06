#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Emover - Remove all emojis from your codebase

.DESCRIPTION
    Removes traditional emojis from text files while preserving Unicode symbols.
    Works with any file type - HTML, JavaScript, Python, CSS, YAML, JSON, and more.

.PARAMETER Directory
    Directory to process (default: current directory)

.PARAMETER Exclude
    File patterns to exclude (can be used multiple times)

.PARAMETER DryRun
    Show what would be changed without making changes

.PARAMETER Verbose
    Show detailed output

.PARAMETER SkipMarkdown
    Skip markdown files (*.md, *.markdown)

.PARAMETER Help
    Show help message

.PARAMETER Version
    Show version

.EXAMPLE
    .\emover.ps1
    Process current directory

.EXAMPLE
    .\emover.ps1 -Directory ./src -DryRun
    Preview changes in src directory

.EXAMPLE
    .\emover.ps1 -SkipMarkdown -Exclude "*.txt","*.json"
    Process with exclusions
#>

param(
    [Parameter(Position = 0)]
    [string]$Directory = ".",

    [Parameter()]
    [string[]]$Exclude = @(),

    [Parameter()]
    [switch]$DryRun,

    [Parameter()]
    [switch]$Verbose,

    [Parameter()]
    [switch]$SkipMarkdown,

    [Parameter()]
    [switch]$Help,

    [Parameter()]
    [switch]$Version
)

$VERSION = "1.0.0"

# Emoji regex pattern (traditional emojis only)
# Also removes one trailing space after emoji to avoid leftover spaces
$EMOJI_PATTERN = '([\x{1F600}-\x{1F64F}]|[\x{1F300}-\x{1F5FF}]|[\x{1F680}-\x{1F6FF}]|[\x{1F900}-\x{1F9FF}]|[\x{1FA70}-\x{1FAFF}]|[\x{1F1E0}-\x{1F1FF}]|[\x{1F004}]|[\x{1F0CF}]|[\x{1F170}-\x{1F251}]|[\x{FE00}-\x{FE0F}]|[\x{200D}]) ?'

# Stats
$script:FilesProcessed = 0
$script:FilesModified = 0
$script:EmojisRemoved = 0

function Show-Help {
    Write-Host @"
Emover v$VERSION - Remove all emojis from your codebase

Usage: emover.ps1 [OPTIONS] [DIRECTORY]

Arguments:
  DIRECTORY              Directory to process (default: current directory)

Options:
  -Exclude <patterns>    Exclude files matching pattern (can be used multiple times)
  -DryRun                Show what would be changed without making changes
  -Verbose               Show detailed output
  -SkipMarkdown          Skip markdown files (*.md, *.markdown)
  -Help                  Show this help message
  -Version               Show version

Examples:
  .\emover.ps1                                    # Process current directory
  .\emover.ps1 -Directory ./src                   # Process src directory
  .\emover.ps1 -DryRun ./src                      # Dry run on src directory
  .\emover.ps1 -SkipMarkdown ./docs               # Process docs, skip markdown
  .\emover.ps1 -Exclude "*.md","*.txt" ./code     # Exclude .md and .txt files
"@
}

function Test-BinaryFile {
    param([string]$FilePath)

    # Known text file extensions (always treat as text)
    $textExtensions = @(
        '.txt', '.md', '.markdown', '.html', '.htm', '.css', '.js', '.jsx', '.ts', '.tsx',
        '.json', '.xml', '.yml', '.yaml', '.toml', '.ini', '.cfg', '.conf', '.py', '.rb',
        '.java', '.c', '.cpp', '.h', '.hpp', '.cs', '.go', '.rs', '.sh', '.bash', '.zsh',
        '.fish', '.php', '.pl', '.lua', '.vim', '.sql', '.r', '.swift', '.kt', '.scala',
        '.clj', '.ex', '.exs', '.erl', '.hrl', '.hs', '.ml', '.fs', '.pas', '.vb',
        '.ps1', '.psm1', '.psd1'
    )

    $ext = [System.IO.Path]::GetExtension($FilePath).ToLower()
    if ($textExtensions -contains $ext) {
        return $false
    }

    # Check for null bytes (definitive binary indicator)
    try {
        $bytes = [System.IO.File]::ReadAllBytes($FilePath)
        $checkLength = [Math]::Min($bytes.Length, 8000)

        for ($i = 0; $i -lt $checkLength; $i++) {
            if ($bytes[$i] -eq 0) {
                return $true
            }
        }
        return $false
    }
    catch {
        # Default to text if uncertain
        return $false
    }
}

function Test-ShouldExclude {
    param(
        [string]$FilePath,
        [string[]]$ExcludePatterns
    )

    $fileName = [System.IO.Path]::GetFileName($FilePath)

    # Skip markdown if flag is set
    if ($SkipMarkdown -and ($fileName -match '\.(md|markdown)$')) {
        return $true
    }

    # Check custom exclude patterns
    foreach ($pattern in $ExcludePatterns) {
        $regexPattern = $pattern -replace '\*', '.*' -replace '\?', '.'
        if ($fileName -match $regexPattern -or $FilePath -match $regexPattern) {
            return $true
        }
    }

    return $false
}

function Remove-EmojisFromFile {
    param(
        [string]$FilePath,
        [bool]$IsDryRun,
        [bool]$IsVerbose
    )

    $script:FilesProcessed++

    # Check if should be excluded
    if (Test-ShouldExclude -FilePath $FilePath -ExcludePatterns $Exclude) {
        if ($IsVerbose) {
            Write-Host "⏭ Excluding: $FilePath" -ForegroundColor Yellow
        }
        return
    }

    # Check if binary
    if (Test-BinaryFile -FilePath $FilePath) {
        if ($IsVerbose) {
            Write-Host "⏭ Skipping binary file: $FilePath" -ForegroundColor Yellow
        }
        return
    }

    try {
        $content = Get-Content -Path $FilePath -Raw -Encoding UTF8

        # Count emojis
        $matches = [regex]::Matches($content, $EMOJI_PATTERN)
        $emojiCount = $matches.Count

        if ($emojiCount -eq 0) {
            if ($IsVerbose) {
                Write-Host "✓ No emojis found: $FilePath" -ForegroundColor Green
            }
            return
        }

        # Remove emojis
        $newContent = [regex]::Replace($content, $EMOJI_PATTERN, '')

        if ($IsDryRun) {
            Write-Host "Would remove $emojiCount emoji(s) from: $FilePath" -ForegroundColor Cyan
        }
        else {
            Set-Content -Path $FilePath -Value $newContent -Encoding UTF8 -NoNewline
            Write-Host "✓ Removed $emojiCount emoji(s) from: $FilePath" -ForegroundColor Green
        }

        $script:FilesModified++
        $script:EmojisRemoved += $emojiCount
    }
    catch {
        Write-Host "❌ Error processing ${FilePath}: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Show help
if ($Help) {
    Show-Help
    exit 0
}

# Show version
if ($Version) {
    Write-Host "Emover v$VERSION"
    exit 0
}

# Verify directory exists
if (-not (Test-Path -Path $Directory -PathType Container)) {
    Write-Host "Error: Directory not found: $Directory" -ForegroundColor Red
    exit 1
}

# Print header
Write-Host "Emover - Emoji Removal Tool"
Write-Host ""
Write-Host "Target directory: $(Resolve-Path $Directory)"
Write-Host "Dry run: $DryRun"

if ($SkipMarkdown) {
    Write-Host "Skipping markdown files: Yes"
}

if ($Exclude.Count -gt 0) {
    Write-Host "Excluding patterns: $($Exclude -join ', ')"
}

Write-Host ""

# Directories to exclude
$excludeDirs = @(
    '.git',
    'node_modules',
    '.svn',
    '.hg',
    'dist',
    'build',
    '.DS_Store'
)

# Get all files
$files = Get-ChildItem -Path $Directory -Recurse -File | Where-Object {
    $file = $_
    $shouldInclude = $true

    # Check if in excluded directory
    foreach ($dir in $excludeDirs) {
        if ($file.FullName -match [regex]::Escape($dir)) {
            $shouldInclude = $false
            break
        }
    }

    $shouldInclude
}

# Process files
foreach ($file in $files) {
    Remove-EmojisFromFile -FilePath $file.FullName -IsDryRun $DryRun -IsVerbose $Verbose
}

# Print summary
Write-Host ""
Write-Host "✅ Done!" -ForegroundColor Green
Write-Host "Files processed: $script:FilesProcessed"
Write-Host "Files modified: $script:FilesModified"
Write-Host "Emojis removed: $script:EmojisRemoved"

if ($DryRun) {
    Write-Host ""
    Write-Host "⚠ This was a dry run. No files were actually modified." -ForegroundColor Yellow
}
