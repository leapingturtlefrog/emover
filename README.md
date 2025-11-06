# Emover

Remove all emojis from your codebase. Works with any file type.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/leapingturtlefrog/emover/main/install.sh | bash
```

## Usage

```bash
# Remove emojis from current directory
emover

# Remove emojis from specific directory
emover ./src

# Preview changes without modifying files
emover --dry-run ./code

# Skip markdown files
emover --skip-markdown ./docs

# Exclude specific file patterns
emover -e "*.md" -e "*.txt" ./project

# Verbose output
emover -v ./code
```

## Options

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

## What it does

- Finds all text files in a directory
- Removes all emojis using Unicode regex patterns
- Skips binary files automatically
- Excludes common directories (node_modules, .git, etc.)

## Requirements

- Bash 4.0+
- Perl (optional, for better emoji detection)

## Examples

```bash
# Clean entire project, keep markdown emojis
emover --skip-markdown .

# See what would change
emover --dry-run ./src

# Clean with exclusions
emover -e "*.md" -e "package.json" ./app
```

## License

MIT
