
---
layout: post
title: Mac GitHub Protocol
date: '2026-01-19'
categories: Protocols
tags: Mac,GitHub,Network
---

# Protocol: Connecting a Mac Computer to GitHub via Terminal (SSH Method)

### Author: Boaz Abramson
### Laboratory: Mass Lab
### Date: January 19 2026

## Purpose:
This protocol provides a step-by-step guide for setting up and using Git on a Mac to connect to GitHub using SSH. It is designed for lab members who need to track and share their research code, analysis, and documentation on GitHub without relying on the GitHub Desktop application.

## 1. Prerequisites
1. You have a GitHub account.
2. You know the URL of your GitHub repository (e.g., https://github.com/Scuba-Bo/BAbramson_Lab_Notebook-Mass_Lab).
3. Your macOS is up to date and you have internet access.

## 2. Check for Git Installation
1. Open Terminal and run:
2. `git --version`
3. If not installed, install with:
4. `xcode-select --install`

## 3. Configure Git (First-Time Setup)
1. `git config --global user.name 'Your Name'`
2. `git config --global user.email 'your_email@example.com'`

## 4. Generate an SSH Key
1. `ssh-keygen -t ed25519 -C 'your_email@example.com'`
2. Press Enter to accept the default file path, and optionally set a passphrase.

## 5. Add the SSH Key to GitHub
1. Display your public key: `cat ~/.ssh/id_ed25519.pub`
2. Copy the full key (starts with ssh-ed25519).
3. Go to GitHub → Settings → SSH and GPG keys → New SSH key.
4. Paste the key and click Add SSH key.

## 6. Configure SSH to Use Port 443 (for Restricted Networks)
1. Create or edit the SSH config file: `nano ~/.ssh/config`
2. Add the following lines:
    ```
    Host github.com
      HostName ssh.github.com
      User git
      Port 443
      IdentityFile ~/.ssh/id_ed25519
    ```
3. Save and exit (Ctrl + O, Enter, Ctrl + X).

## 7. Test the SSH Connection
1. Run: `ssh -T git@github.com`
2. If successful, you’ll see: ‘Hi [YourGitHubUsername]! You’ve successfully authenticated, but GitHub does not provide shell access.’

## 8. Link a Local Folder to a GitHub Repository
1. Navigate to your project folder: `cd /Users/Boaz/Documents/GitHub/BAbramson_Lab_Notebook-Mass_Lab`
2. Initialize Git: `git init`
3. Connect to your GitHub repo: `git remote add origin git@github.com:Scuba-Bo/BAbramson_Lab_Notebook-Mass_Lab.git`
4. Verify: `git remote -v`

## 9. Upload Files to GitHub
1. If folder is empty, create a README file: `echo '# BAbramson Lab Notebook' > README.md`
2. Stage files: `git add .`
3. Commit files: `git commit -m 'Initial commit - add project files'`
4. Push to GitHub: `git branch -M master` then `git push -u origin master`

## 10. Verify Successful Upload
1. Visit your repository page on GitHub (e.g., https://github.com/Scuba-Bo/BAbramson_Lab_Notebook-Mass_Lab) to confirm files appear.