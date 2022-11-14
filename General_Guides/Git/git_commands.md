# Install Git
https://git-scm.com/book/en/v2/Getting-Started-Installing-Git

### Debian-based distribution
```sudo apt install git-all```

### RPM-based distribution
```sudo dnf install git-all```

### Show Git version
```git --version```

# Tell Git who you are
### Configure the author name and email address to be used with your commits.	
```git config --global user.name "Sam Smith"```

### Note that Git strips some characters (for example trailing periods) from user.name.
```git config --global user.email sam@example.com```

# Create a new local repository 
```git init```
		
# Check out a repository
Create a working copy of a local repository
```git clone /path/to/repository```

### For a remote server, use:
```git clone username@host:/path/to/repository```
		
# Add files
### Add one or more files to staging (index):	
```git add <filename>```
```git add *```
		
# Commit
### Commit changes to head (but not yet to the remote repository):	
```git commit -m "Commit message"```
		
### Commit any files you've added with git add, and also commit any files you've changed since then:
```git commit -A```
		
# Push
### Send changes to the master branch of your remote repository:
```git push origin master```
		
# Status
### List the files you've changed and those you still need to add or commit:
```git status```

# Connect to a remote repository
### If you haven't connected your local repository to a remote server, add the server to be able to push to it:
```git remote add origin <server> (e.g. git@github.com:boxops/network_config_guides.git)```

### List all currently configured remote repositories:
```git remote -v```

# Branches
### Create a new branch and switch to it:
```git checkout -b <branchname>```
		
### Switch from one branch to another:
```git checkout <branchname>```
		
### List all the branches in your repo, and also tell you what branch you're currently in:
```git branch```
		
### Delete the feature branch:
```git branch -d <branchname>```
		
### Push the branch to your remote repository, so others can use it:
```git push origin <branchname>```
		
### Push all branches to your remote repository:
```git push --all origin```
		
### Delete a branch on your remote repository:
```git push origin :<branchname>```
		
# Update from the remote repository
### Fetch and merge changes on the remote server to your working directory:
```git pull```

### To merge a different branch into your active branch:
```git merge <branchname>```
		
### View all the merge conflicts:
```git diff```
		
### View the conflicts against the base file:
```git diff --base <filename>```
		
### Preview changes, before merging:
```git diff <sourcebranch> <targetbranch>```
		
### After you have manually resolved any conflicts, you mark the changed file:
```git add <filename>```
		
# Tags
### You can use tagging to mark a significant changeset, such as a release:
```git tag 1.0.0 <commitID>```
		
### CommitId is the leading characters of the changeset ID, up to 10, but must be unique. Get the ID using:
```git log```
		
### Push all tags to remote repository:
```git push --tags origin```
		
# Undo local changes
### If you mess up, you can replace the changes in your working tree with the last content in head:
```git checkout -- <filename>```
		
### Changes already added to the index, as well as new files, will be kept.	
### Instead, to drop all your local changes and commits, fetch the latest history from the server and point your local master branch at it, do this:
```git fetch origin```
```git reset --hard origin/main```
		
# Search
### Search the working directory for foo():
```git grep "foo()"```


# Generating a new SSH key and adding it to the ssh-agent
### https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
### 1. Open Terminal, Paste the text below, substituting in your GitHub email address:
```ssh-keygen -t ed25519 -C "your_email@example.com"```
### 2. Start the ssh-agent in the background:
```eval "$(ssh-agent -s)"```
### 3. Add your SSH private key to the ssh-agent:
```ssh-add ~/.ssh/id_ed25519```
### 4. Add the SSH key to your account on GitHub:
https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account
### 5. Testing your SSH connection:
```ssh -T git@github.com```

# Managing remote repositories
### https://docs.github.com/en/get-started/getting-started-with-git/managing-remote-repositories?platform=linux
### 1. Configure the author name and email address to be used with your commits.	
```git config --global user.name "Sam Smith"```
### 2. Note that Git strips some characters (for example trailing periods) from user.name.
```git config --global user.email sam@example.com```
### 3. Adding a remote repository:
```git remote add origin https://github.com/USER/REPO>.git```
### 4. Verify new remote:
```git remote -v```

# Changing a remote repository's URL

## 1. Switching remote URLs from SSH to HTTPS:
### List your existing remotes in order to get the name of the remote you want to change.
```git remote -v```
### Change your remote's URL from SSH to HTTPS with the git remote set-url command.
```git remote set-url origin https://github.com/USERNAME/REPOSITORY.git```
### Verify that the remote URL has changed. 
```git remote -v```

## 2. Switching remote URLs from HTTPS to SSH
### List your existing remotes in order to get the name of the remote you want to change.
```git remote -v```
### Change your remote's URL from HTTPS to SSH with the git remote set-url command. 
```git remote set-url origin git@github.com:USERNAME/REPOSITORY.git```
### Verify that the remote URL has changed. 
```git remote -v```
