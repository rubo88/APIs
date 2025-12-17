import os
import re

# Configuration
LANGUAGES = ['python', 'R', 'matlab', 'stata']
OUTPUT_FILE = 'repository_codes.md'

def get_code_block_lang(lang):
    """Returns the markdown code block language identifier."""
    if lang == 'python': return 'python'
    if lang == 'R': return 'R'
    if lang == 'matlab': return 'matlab'
    if lang == 'stata': return 'stata'
    return ''

def get_valid_extensions(lang):
    """Returns valid file extensions for the given language."""
    if lang == 'python': return ['.py']
    if lang == 'R': return ['.R']
    if lang == 'matlab': return ['.m']
    if lang == 'stata': return ['.do']
    return []

def is_readme(filename):
    """Checks if a file is a readme file."""
    return filename.lower().endswith('readme.md')

def adjust_header_level(text, increment=2):
    """
    Increases the level of markdown headers in the text by 'increment'.
    Skips headers inside code blocks fenced by ```.
    """
    # Split by code fence, capturing the fence itself
    parts = re.split(r'(```)', text)
    
    in_code_block = False
    processed_parts = []
    
    for part in parts:
        if part == '```':
            in_code_block = not in_code_block
            processed_parts.append(part)
        elif in_code_block:
            processed_parts.append(part)
        else:
            # Adjust headers in this part
            # Replace ^(#+) with '#' * increment + group(0)
            # Use MULTILINE to match start of lines
            adjusted_part = re.sub(r'^(#+)', lambda m: '#' * increment + m.group(1), part, flags=re.MULTILINE)
            processed_parts.append(adjusted_part)
            
    return ''.join(processed_parts)

def generate_documentation():
    print(f"Generating documentation to {OUTPUT_FILE}...")
    
    md_output = []
    
    # Add a title
    md_output.append("# Repository Codes Documentation\n")
    
    for lang in LANGUAGES:
        if not os.path.exists(lang):
            print(f"Warning: Directory {lang} not found.")
            continue
            
        # Section: Programming Language
        md_output.append(f"# {lang.capitalize()}\n")
        
        # Get sources (subdirectories)
        try:
            sources = sorted([d for d in os.listdir(lang) if os.path.isdir(os.path.join(lang, d))])
        except OSError as e:
            print(f"Error listing directory {lang}: {e}")
            continue
            
        for source in sources:
            # Skip hidden folders and cache
            if source.startswith('.') or source == '__pycache__':
                continue
                
            source_path = os.path.join(lang, source)
            
            # Subsection: Source
            md_output.append(f"## {source.upper()}\n")
            
            files = []
            try:
                files = sorted(os.listdir(source_path))
            except OSError as e:
                print(f"Error listing directory {source_path}: {e}")
                continue
            
            # 1. Find and copy Readme content
            readme_content = ""
            # Prioritize [source]_readme.md, then readme.md, then any *readme.md
            specific_readme = f"{source}_readme.md"
            generic_readme = "readme.md"
            
            target_readme = None
            if specific_readme in files:
                target_readme = specific_readme
            elif generic_readme in files:
                target_readme = generic_readme
            else:
                # Find any readme
                for f in files:
                    if is_readme(f):
                        target_readme = f
                        break
            
            if target_readme:
                try:
                    with open(os.path.join(source_path, target_readme), 'r', encoding='utf-8') as f:
                        readme_content = f.read()
                        # Adjust header levels
                        readme_content = adjust_header_level(readme_content, increment=2)
                        md_output.append(readme_content + "\n")
                except Exception as e:
                    print(f"Error reading {target_readme}: {e}")
                    md_output.append(f"> Error reading readme file: {e}\n")
            else:
                pass

            # 2. Stick code snippets
            valid_exts = get_valid_extensions(lang)
            code_files = [f for f in files if any(f.endswith(ext) for ext in valid_exts)]
            
            for code_file in code_files:
                md_output.append(f"### {code_file}\n")
                
                try:
                    with open(os.path.join(source_path, code_file), 'r', encoding='utf-8') as f:
                        code_content = f.read()
                    
                    md_output.append(f"```{get_code_block_lang(lang)}")
                    md_output.append(code_content)
                    md_output.append("```\n")
                except Exception as e:
                    print(f"Error reading code file {code_file}: {e}")
                    md_output.append(f"> Error reading code file: {e}\n")

    # Write the full content to file
    try:
        with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
            f.write('\n'.join(md_output))
        print(f"Successfully generated {OUTPUT_FILE}")
    except Exception as e:
        print(f"Error writing output file: {e}")

if __name__ == "__main__":
    generate_documentation()
