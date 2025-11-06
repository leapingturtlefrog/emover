# Emover - Emoji Remover

Remove emojis from your codebase. Blazingly fast, parallel, and cross-platform.

## Install

### Linux/macOS

```bash
curl -fsSL https://emover.sh/install.sh | bash
```

### Windows

```powershell
irm https://emover.sh/install.ps1 | iex
```

<sub>Alternatively: [install.sh](https://raw.githubusercontent.com/leapingturtlefrog/emover/main/install.sh) | [install.ps1](https://raw.githubusercontent.com/leapingturtlefrog/emover/main/install.ps1)</sub>

## Usage

```bash
emover                                              # Current directory
emover ./src                                        # Specific directory
emover --dry-run ./code                             # Preview changes
emover --skip ./docs                                # Skip markdown files
emover --exclude "*.md" --exclude "*.txt" ./project # Exclude patterns
```

## Options

```
-d, --dry-run          Preview changes only
-e, --exclude PATTERN  Exclude file pattern
--skip                 Skip markdown files
-h, --help             Show help
-V, --version          Show version
```

## What it does

- Scans all text files in parallel
- Removes Unicode emojis (preserves symbols like ✓ ★ ⚠)
- Skips binary files automatically
- Excludes .git and node_modules

## Performance

Written in Rust, uses all CPU cores. Processes thousands of files in milliseconds.

## Build from source

```bash
cd emover
cargo build --release
```

## License

MIT

