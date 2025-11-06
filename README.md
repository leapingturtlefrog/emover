# Emover

Remove emojis from your codebase. Blazingly fast, parallel, cross-platform.

## Install

### Linux/macOS

```bash
curl -fsSL https://raw.githubusercontent.com/leapingturtlefrog/emover/main/install.sh | bash
```

### Windows

```powershell
irm https://raw.githubusercontent.com/leapingturtlefrog/emover/main/install.ps1 | iex
```

## Usage

```bash
emover
emover ./src
emover --dry-run ./code
emover --skip ./docs
emover -e "*.md" -e "*.txt" ./project
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

