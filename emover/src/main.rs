use clap::Parser;
use rayon::prelude::*;
use regex::Regex;
use std::{fs, io::{self, Write}, path::PathBuf};
use walkdir::WalkDir;

#[derive(Parser)]
#[command(name = "emover", version = "1.0.0", about = "Emojie Remover - Remove emojis from files")]
struct Args {
    #[arg(default_value = ".")]
    paths: Vec<PathBuf>,
    #[arg(short, long, help = "Skip confirmation prompt")]
    yes: bool,
    #[arg(short, long, num_args = 0.., help = "Exclude patterns (e.g., -e '*.md' '*.txt')")]
    exclude: Vec<String>,
    #[arg(long, help = "Don't respect .gitignore")]
    no_gitignore: bool,
    #[arg(long, help = "Keep Unicode symbols (e.g., ✓ ★ ⚠)")]
    keep_symbols: bool,
    #[arg(short = 'v', long)]
    version: bool,
}

fn main() {
    let args = Args::parse();
    if args.version {
        println!("emover 1.0.0");
        return;
    }
    
    let emoji_re = if args.keep_symbols {
        Regex::new(r"[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F900}-\u{1F9FF}\u{1FA70}-\u{1FAFF}\u{1F1E0}-\u{1F1FF}]").unwrap()
    } else {
        Regex::new(r"[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F900}-\u{1F9FF}\u{1FA70}-\u{1FAFF}\u{1F1E0}-\u{1F1FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]").unwrap()
    };
    
    let mut files = Vec::new();
    let mut total_found = 0;
    
    for p in &args.paths {
        if p.is_file() {
            files.push(p.clone());
            total_found += 1;
        } else if p.is_dir() {
            let walker = WalkDir::new(p).into_iter()
                .filter_entry(|e| {
                    if args.no_gitignore {
                        return true;
                    }
                    let name = e.file_name().to_string_lossy();
                    !name.starts_with('.') || name == "." || e.depth() == 0
                });
            files.extend(
                walker
                    .filter_map(Result::ok)
                    .filter(|e| {
                        if e.file_type().is_file() {
                            total_found += 1;
                            !e.path().to_string_lossy().contains("/.git/") && !e.path().to_string_lossy().contains("/node_modules/")
                        } else {
                            false
                        }
                    })
                    .map(|e| e.path().to_path_buf())
            );
        }
    }
    
    let all_files_count = files.len();
    let files: Vec<_> = files.into_iter()
        .filter(|p| args.exclude.iter().all(|pat| !p.file_name().unwrap().to_string_lossy().contains(pat.trim_matches(|c| c == '\'' || c == '"'))))
        .collect();
    
    let changes: Vec<_> = files.par_iter()
        .filter_map(|path| {
            let content = fs::read_to_string(path).ok()?;
            if content.contains('\0') { return None; }
            let cleaned = emoji_re.replace_all(&content, "");
            (content != cleaned).then(|| (path.clone(), content.chars().count() - cleaned.chars().count()))
        })
        .collect();
    
    if changes.is_empty() {
        println!("No emojis found in {} files", files.len());
        return;
    }
    
    for (path, count) in &changes {
        println!("  {} ({} emojis)", path.display(), count);
    }
    
    if !args.yes {
        print!("\nRemove these emojis? This change is irreversible (y/N): ");
        io::stdout().flush().unwrap();
        let mut input = String::new();
        io::stdin().read_line(&mut input).unwrap();
        if !input.trim().eq_ignore_ascii_case("y") {
            println!("Cancelled");
            return;
        }
    }
    
    let modified: usize = changes.iter().filter(|(path, _)| {
        fs::read_to_string(path).ok().and_then(|content| {
            let cleaned = emoji_re.replace_all(&content, "");
            fs::write(path, cleaned.as_ref()).ok()
        }).is_some()
    }).count();
    
    let total: usize = changes.iter().map(|(_, c)| c).sum();
    let ignored = total_found - files.len();
    println!("\nFiles scanned: {}, Modified: {}, Ignored: {}, Emojis removed: {}", 
        files.len(), modified, ignored, total);
}
