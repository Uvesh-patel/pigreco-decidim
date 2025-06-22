import requests
import json
import os
import base64

# Use the same token from create_repo.py for consistency
github_token = None

# Try to read token from create_repo.py
try:
    with open('create_repo.py', 'r') as f:
        for line in f:
            if 'github_token =' in line and '#' not in line.split('github_token')[0]:
                token_line = line.strip()
                # Extract the token value from the line (handles both direct assignment and variable)
                if '"' in token_line or "'" in token_line:
                    # Token is directly in the code
                    start = max(token_line.find("'"), token_line.find('"'))
                    if start >= 0:
                        end = max(token_line.rfind("'"), token_line.rfind('"'))
                        if end > start:
                            github_token = token_line[start+1:end]
except Exception as e:
    print(f"Could not read token from create_repo.py: {e}")
    github_token = None

# If token not found, ask for it
if not github_token:
    print("\nINSTRUCTIONS:")
    print("1. Open create_repo.py and copy your GitHub token from there")
    print("2. Paste it below when prompted\n")
    github_token = input("Enter your GitHub Personal Access Token: ")

# Repository details
repo_owner = "Uvesh-patel"
repo_name = "pigreco-decidim"

headers = {
    "Authorization": f"token {github_token}",
    "Accept": "application/vnd.github.v3+json"
}

def get_default_branch():
    """Get the default branch of the repository"""
    url = f"https://api.github.com/repos/{repo_owner}/{repo_name}"
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        return response.json()["default_branch"]
    else:
        print(f"Error getting repository info: {response.status_code}, {response.text}")
        return None

def get_branch_sha(branch):
    """Get the SHA of the latest commit on the branch"""
    url = f"https://api.github.com/repos/{repo_owner}/{repo_name}/git/refs/heads/{branch}"
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        return response.json()["object"]["sha"]
    else:
        print(f"Error getting branch SHA: {response.status_code}, {response.text}")
        return None

def create_empty_tree(base_tree_sha):
    """Create an empty tree"""
    url = f"https://api.github.com/repos/{repo_owner}/{repo_name}/git/trees"
    payload = {
        "base_tree": base_tree_sha,
        "tree": []
    }
    response = requests.post(url, headers=headers, json=payload)
    if response.status_code == 201:
        return response.json()["sha"]
    else:
        print(f"Error creating empty tree: {response.status_code}, {response.text}")
        return None

def create_commit(message, tree_sha, parent_sha):
    """Create a commit with the empty tree"""
    url = f"https://api.github.com/repos/{repo_owner}/{repo_name}/git/commits"
    payload = {
        "message": message,
        "tree": tree_sha,
        "parents": [parent_sha]
    }
    response = requests.post(url, headers=headers, json=payload)
    if response.status_code == 201:
        return response.json()["sha"]
    else:
        print(f"Error creating commit: {response.status_code}, {response.text}")
        return None

def update_reference(branch, commit_sha):
    """Update the branch reference to point to the new commit"""
    url = f"https://api.github.com/repos/{repo_owner}/{repo_name}/git/refs/heads/{branch}"
    payload = {
        "sha": commit_sha,
        "force": True  # Force update the reference
    }
    response = requests.patch(url, headers=headers, json=payload)
    if response.status_code == 200:
        print(f"Branch {branch} successfully reset to an empty state")
    else:
        print(f"Error updating reference: {response.status_code}, {response.text}")

def delete_repo_content():
    """Delete all content in the repository by creating an empty commit"""
    branch = get_default_branch()
    if not branch:
        return
    
    parent_sha = get_branch_sha(branch)
    if not parent_sha:
        return
    
    tree_sha = create_empty_tree(None)  # Create a completely empty tree
    if not tree_sha:
        return
    
    commit_sha = create_commit("Empty the repository for fresh upload", tree_sha, parent_sha)
    if not commit_sha:
        return
    
    update_reference(branch, commit_sha)

if __name__ == "__main__":
    print(f"Emptying repository {repo_owner}/{repo_name}...")
    delete_repo_content()
    print("Done. Repository content has been deleted.")
