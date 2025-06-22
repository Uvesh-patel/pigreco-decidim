import requests
import os
import getpass

# Repository details
repo_owner = "Uvesh-patel"
repo_name = "pigreco-decidim"

def delete_github_repository():
    print(f"\nPreparing to delete the GitHub repository: {repo_owner}/{repo_name}")
    
    # Get GitHub personal access token securely
    github_token = getpass.getpass("Enter your GitHub Personal Access Token (input will be hidden): ")
    
    # Set up the request headers
    headers = {
        "Authorization": f"token {github_token}",
        "Accept": "application/vnd.github.v3+json"
    }
    
    # Delete repository API endpoint
    url = f"https://api.github.com/repos/{repo_owner}/{repo_name}"
    
    # Double confirmation
    confirm = input(f"\nWARNING: You are about to delete the repository '{repo_owner}/{repo_name}'.\nThis action cannot be undone. Type 'DELETE' to confirm: ")
    
    if confirm != "DELETE":
        print("Deletion cancelled.")
        return
    
    # Send the delete request
    print(f"Deleting repository {repo_owner}/{repo_name}...")
    response = requests.delete(url, headers=headers)
    
    # Check response
    if response.status_code == 204:
        print(f"Repository {repo_owner}/{repo_name} has been successfully deleted.")
    else:
        print(f"Error deleting repository. Status code: {response.status_code}")
        print(f"Response: {response.text}")

if __name__ == "__main__":
    delete_github_repository()
