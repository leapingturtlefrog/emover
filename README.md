# Emover - Emoji Remover

Remove emojis from your codebase. Blazingly fast, parallel, and cross-platform.

## Install

### Linux/macOS

```bash
curl -fsSL https://emover.sh/install.sh | bash
```

### Windows

```bash
irm https://emover.sh/install.ps1 | iex
```

## Usage

```bash
emover                             # Current directory (asks for confirmation)
emover -y ./src ./lib              # Auto-confirm, multiple directories
emover file.txt src/ lib/test.rs   # Specific files + directories
emover -e "*.md" "*.txt" .         # Exclude patterns
```

## Options

```
-y, --yes              Skip confirmation prompt
-e, --exclude [PATTERNS]...  Exclude file patterns (e.g., -e "*.md" "*.txt")
--no-gitignore         Don't respect .gitignore
--keep-symbols         Keep Unicode symbols (e.g., ✓ ★ ⚠)
-v, --version          Show version
-h, --help             Show help
```

## What it does

- Scans all text files in parallel
- Respects .gitignore by default
- Asks for confirmation before modifying
- Removes Unicode emojis and symbols
- Skips binary files automatically

## Performance

Written in Rust, uses all CPU cores. Processes thousands of files in milliseconds.

## Build from source

```bash
cd emover
cargo build --release
```

## License

MIT

