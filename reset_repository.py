import os
import subprocess

def run_git_command(command, print_output=True):
    """Run a git command and print the output"""
    print(f"Running: git {command}")
    result = subprocess.run(f"git {command}", shell=True, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Error: {result.stderr}")
    elif print_output and result.stdout:
        print(f"Output: {result.stdout}")
    return result

# Reset the repository
def reset_repository():
    print("Resetting repository to prepare for clean upload...")
    
    # Create empty .gitignore file with key temp exclusions
    with open('.gitignore', 'w') as f:
        f.write("""# Ignore temp directory completely
/temp/
/temp/**/*

# Ignore database files
*.db
*.sqlite
*.sqlite3
/db/*.sqlite3
/db/*.sqlite3-journal

# Ignore environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Ignore logs
/log/*
!/log/.keep

# Ignore Docker volumes
docker-volumes/

# Ignore system files
.DS_Store
Thumbs.db
""")
    
    # Create a basic README
    with open('README.md', 'w') as f:
        f.write("""# PIGRECO Risk Governance Platform

This repository is being reset for a clean upload. Please wait for the complete project to be uploaded.
""")
    
    # Add and commit these files
    run_git_command("add .gitignore README.md")
    run_git_command("commit -m \"Reset repository for clean project upload\"")
    
    print("Now you can replace your local directory with your working project and run:")
    print("git add .")
    print("git commit -m \"Upload complete working project\"")
    print("git push -f origin master")

if __name__ == "__main__":
    reset_repository()
