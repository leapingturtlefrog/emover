# Emover

Remove all emojis from your codebase. Works with any file type.

## Install

### Mac/Linux
```bash
curl -fsSL https://raw.githubusercontent.com/leapingturtlefrog/emover/main/install.sh | bash
```

### Windows
```powershell
iwr -useb https://raw.githubusercontent.com/leapingturtlefrog/emover/main/install.ps1 | iex
```

## Usage

### Mac/Linux
```bash
emover                      # Process current directory
emover ./src                # Process specific directory
emover --dry-run ./code     # Preview changes
emover --skip-markdown .    # Skip markdown files
emover -e "*.md" ./project  # Exclude patterns
emover -v ./code            # Verbose output
```

### Windows
```powershell
emover.ps1                          # Process current directory
emover.ps1 -Directory ./src         # Process specific directory
emover.ps1 -DryRun                  # Preview changes
emover.ps1 -SkipMarkdown            # Skip markdown files
emover.ps1 -Exclude "*.md","*.txt"  # Exclude patterns
emover.ps1 -Verbose                 # Verbose output
```

## Options

### Mac/Linux
```
emover [OPTIONS] [DIRECTORY]

Options:
  -d, --dry-run          Preview changes only
  -v, --verbose          Detailed output
  --skip-markdown        Skip .md files
  -e, --exclude PATTERN  Exclude pattern (can use multiple times)
  -h, --help             Show help
  --version              Show version
```

### Windows
```
emover.ps1 [OPTIONS] [DIRECTORY]

Options:
  -DryRun                Preview changes only
  -Verbose               Detailed output
  -SkipMarkdown          Skip .md files
  -Exclude <patterns>    Exclude patterns (comma-separated)
  -Help                  Show help
  -Version               Show version
```

## What it does

- Finds all text files in a directory
- Removes traditional emojis () using Unicode regex
- Keeps Unicode symbols (✓ ★ ⚠ © →)
- Skips binary files automatically
- Excludes common directories (node_modules, .git, etc.)

## Requirements

**Mac/Linux:** Bash 4.0+, Perl (optional, for better detection)

**Windows:** PowerShell 5.1+ or PowerShell Core 7+

## License

MIT
