import requests
import json
import os
import getpass
import subprocess

# Repository details
repo_owner = "Uvesh-patel"
repo_name = "pigreco-decidim"
repo_description = "PIGRECO Risk Governance Platform"
is_private = False  # Set to True for private repository, False for public

def create_github_repository(github_token):
    """Create a new GitHub repository using GitHub API"""
    headers = {
        "Authorization": f"token {github_token}",
        "Accept": "application/vnd.github.v3+json"
    }
    
    # Repository creation API endpoint
    url = "https://api.github.com/user/repos"
    
    # Request body
    data = {
        "name": repo_name,
        "description": repo_description,
        "private": is_private,
        "auto_init": False  # Don't initialize with README
    }
    
    # Send the create request
    print(f"Creating new repository: {repo_name}...")
    response = requests.post(url, headers=headers, data=json.dumps(data))
    
    # Check response
    if response.status_code in (201, 200):
        print(f"Repository {repo_name} successfully created!")
        return True
    else:
        print(f"Error creating repository. Status code: {response.status_code}")
        print(f"Response: {response.text}")
        return False

def setup_git_and_push(github_token):
    """Setup Git and push project to the new repository"""
    remote_url = f"https://{github_token}@github.com/{repo_owner}/{repo_name}.git"
    
    try:
        # Create a good .gitignore file
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

# Ignore node modules
node_modules/

# Other common exclusions
*.swp
*.swo
*.tmp
*.bak
*~
""")
        
        print("Setting up Git repository...")
        
        # Check if .git directory exists
        if os.path.exists(".git"):
            print("Git repository already initialized")
        else:
            subprocess.run("git init", shell=True, check=True)
        
        # Configure the remote
        subprocess.run("git remote remove origin", shell=True, stderr=subprocess.DEVNULL)
        subprocess.run(f"git remote add origin {remote_url}", shell=True, check=True)
        
        # Add and commit all files (except those in .gitignore)
        subprocess.run("git add .", shell=True, check=True)
        subprocess.run('git commit -m "Initial commit: Complete PIGRECO Project"', shell=True)
        
        # Push to GitHub
        print("Pushing to GitHub...")
        subprocess.run("git push -u -f origin master", shell=True, check=True)
        
        print("Project successfully uploaded to GitHub!")
        print(f"Repository URL: https://github.com/{repo_owner}/{repo_name}")
        return True
    
    except subprocess.CalledProcessError as e:
        print(f"Error during Git operations: {e}")
        return False

def main():
    print("===== GitHub Repository Creation and Project Upload =====")
    
    # Get GitHub personal access token securely
    github_token = getpass.getpass("Enter your GitHub Personal Access Token (input will be hidden): ")
    
    # Create GitHub repository
    if create_github_repository(github_token):
        # Setup Git and push project
        setup_git_and_push(github_token)

if __name__ == "__main__":
    main()
