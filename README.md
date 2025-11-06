# Emover

A powerful command-line tool to remove all emojis from your codebase. Works with any file type - HTML, JavaScript, Python, CSS, YAML, JSON, and more!

## Features

- Removes all emojis from any text-based file
- Works across any file type (JS, HTML, CSS, Python, Ruby, Go, etc.)
- Configurable file exclusion patterns
- Option to skip Markdown files
- Dry-run mode to preview changes
- Verbose output for detailed information
- Automatically skips binary files
- Excludes common directories (node_modules, .git, etc.)

## Installation

### Quick Install

```bash
git clone https://github.com/yourusername/emover.git
cd emover
./install.sh
```

This will install `emover` to:
- `/usr/local/bin` if you run as root (system-wide)
- `~/.local/bin` if you run as a regular user

### Manual Installation

```bash
# Copy the script to a directory in your PATH
sudo cp emover /usr/local/bin/
sudo chmod +x /usr/local/bin/emover
```

### Requirements

- Bash 4.0 or higher
- Perl (recommended for comprehensive emoji removal)
- Standard Unix tools (find, sed, grep)

The tool will work without Perl but emoji detection will be less comprehensive.

## Usage

### Basic Usage

```bash
# Process current directory
emover

# Process specific directory
emover ./src

# Process with verbose output
emover -v ./code
```

### Dry Run Mode

Preview what would be changed without actually modifying files:

```bash
emover --dry-run ./src
```

### Skip Markdown Files

Keep emojis in documentation:

```bash
emover --skip-markdown ./docs
```

### Exclude Specific File Patterns

```bash
# Exclude single pattern
emover -e "*.md" ./code

# Exclude multiple patterns
emover -e "*.md" -e "*.txt" -e "*.json" ./code
```

### Combined Options

```bash
# Dry run, skip markdown, verbose output
emover --dry-run --skip-markdown -v ./project

# Exclude patterns with dry run
emover -d -e "*.yml" -e "*.txt" ./config
```

## Command-Line Options

```
Usage: emover [OPTIONS] [DIRECTORY]

Arguments:
  DIRECTORY              Directory to process (default: current directory)

Options:
  -e, --exclude PATTERN  Exclude files matching pattern (can be used multiple times)
  -d, --dry-run          Show what would be changed without making changes
  -v, --verbose          Show detailed output
  --skip-markdown        Skip markdown files (*.md, *.markdown)
  -h, --help             Show help message
  --version              Show version
```

## Examples

### Example 1: Clean a Web Project

```bash
cd my-web-project
emover --skip-markdown --dry-run .
# Review the output
emover --skip-markdown .
```

### Example 2: Clean Only Source Code

```bash
emover -e "*.md" -e "*.txt" -e "package.json" ./src
```

### Example 3: Audit Before Cleaning

```bash
# See what will be changed
emover --dry-run --verbose ./codebase > emoji-report.txt

# Review the report
less emoji-report.txt

# Apply changes
emover ./codebase
```

## What Files Are Processed?

### Included
- All text-based files in the target directory
- JavaScript, TypeScript, Python, Ruby, Go, Java, C, C++, etc.
- HTML, CSS, SCSS, LESS
- JSON, YAML, XML, TOML
- Shell scripts, Makefiles
- Any other text files

### Automatically Excluded
- Binary files (images, executables, archives)
- `node_modules/` directory
- `.git/` directory
- `.svn/`, `.hg/` directories
- `dist/`, `build/` directories
- `.DS_Store` files
- `package-lock.json`, `yarn.lock`

## How It Works

Emover uses comprehensive Unicode regex patterns to detect and remove emojis from files. It covers:

- Emoticons (😀-🙏)
- Objects & Symbols (🚀-🛿)
- Flags (🇦-🇿)
- Skin tone modifiers
- And many more Unicode emoji ranges

The tool safely handles:
- Multi-byte UTF-8 characters
- Files with mixed content
- Large codebases
- Nested directory structures

## Testing

The repository includes a test suite with synthetic codebases:

```bash
# Run tests
cd test-repos
../emover --dry-run webapp
```

Test files include emojis in:
- JavaScript comments and strings
- HTML content and attributes
- CSS comments
- Python docstrings and code
- YAML configuration
- Markdown documentation
- Plain text files

## Why Remove Emojis?

While emojis can make code comments and documentation more expressive, they can cause issues:

- **Compatibility**: Not all terminals and editors display emojis correctly
- **Professionalism**: Some coding standards prohibit emojis
- **Searchability**: Emojis can complicate code searches
- **Localization**: Emojis may not translate well across cultures
- **Version Control**: Emojis in diffs can cause rendering issues
- **Legacy Systems**: Older systems may not support emoji characters

## Performance

Emover is designed to be fast and efficient:

- Processes thousands of files quickly
- Skips binary files automatically
- Only modifies files that contain emojis
- Uses efficient pattern matching

## Troubleshooting

### "Perl not found" warning

If Perl is not installed, emoji detection will be less comprehensive. Install Perl:

```bash
# macOS
brew install perl

# Ubuntu/Debian
sudo apt-get install perl

# CentOS/RHEL
sudo yum install perl
```

### Some emojis not removed

The tool uses comprehensive patterns but new emojis are added to Unicode regularly. The regex patterns cover most common emojis but may miss very new or obscure ones.

### Files treated as binary

The tool uses the `file` command to detect binary files. If text files are incorrectly identified as binary, try updating your file utilities.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

MIT License - feel free to use this tool in any project!

## Credits

Created to help developers maintain clean, professional codebases across any platform.

---

**Note**: Always commit your changes or backup your code before running emover on your entire codebase. While the tool is designed to be safe, it's good practice to be able to revert changes if needed.
