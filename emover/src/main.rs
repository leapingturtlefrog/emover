use clap::Parser;
use rayon::prelude::*;
use regex::Regex;
use std::{fs, path::PathBuf};
use walkdir::WalkDir;

#[derive(Parser)]
#[command(name = "emover", version = "1.0.0", about = "Remove emojis from files")]
struct Args {
    #[arg(default_value = ".")]
    paths: Vec<PathBuf>,
    #[arg(short, long)]
    dry_run: bool,
    #[arg(short, long)]
    exclude: Vec<String>,
    #[arg(long)]
    skip: bool,
}

fn main() {
    let args = Args::parse();
    let emoji_re = Regex::new(r"[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F900}-\u{1F9FF}\u{1FA70}-\u{1FAFF}\u{1F1E0}-\u{1F1FF}]").unwrap();
    
    let files: Vec<_> = args.paths.iter()
        .flat_map(|p| WalkDir::new(p).into_iter().filter_map(Result::ok))
        .filter(|e| e.file_type().is_file())
        .filter(|e| !e.path().to_string_lossy().contains("/.git/") && !e.path().to_string_lossy().contains("/node_modules/"))
        .filter(|e| !args.skip || !e.path().extension().map_or(false, |x| x == "md"))
        .filter(|e| args.exclude.iter().all(|pat| !e.file_name().to_string_lossy().contains(pat)))
        .map(|e| e.path().to_path_buf())
        .collect();
    
    let (modified, total_emojis): (usize, usize) = files.par_iter()
        .filter_map(|path| {
            let content = fs::read_to_string(path).ok()?;
            if content.contains('\0') { return None; }
            let cleaned = emoji_re.replace_all(&content, "");
            if content != cleaned {
                let count = content.len() - cleaned.len();
                if !args.dry_run {
                    fs::write(path, cleaned.as_ref()).ok()?;
                }
                println!("{} {}", if args.dry_run { "Would clean:" } else { "Cleaned:" }, path.display());
                Some((1, count / 4))
            } else { None }
        })
        .reduce(|| (0, 0), |a, b| (a.0 + b.0, a.1 + b.1));
    
    println!("\nFiles scanned: {}, Modified: {}, Emojis removed: ~{}", files.len(), modified, total_emojis);
}
