# Operation Comeback — Phone-Only Setup Guide

You will download a zip of this project, push it to GitHub using Termux
(a terminal app for Android), and let GitHub build the APK for you.
No laptop needed.

## Step 1 — Create a GitHub account
Go to github.com in Chrome, sign up (free). Remember your username.

## Step 2 — Create a Personal Access Token (so Termux can push code)
1. On github.com → tap your profile picture → **Settings**
2. Scroll to **Developer settings** → **Personal access tokens** → **Tokens (classic)**
3. **Generate new token (classic)** → check the **repo** box → Generate
4. **Copy the token immediately** and save it somewhere safe (Google Keep, notes app).
   You will not be able to see it again.

## Step 3 — Create an empty repository
1. github.com → **+** → **New repository**
2. Name it `operation-comeback`
3. Keep it **Public** (private repos have limited free Actions minutes)
4. Do NOT add a README/gitignore — leave it empty
5. Create repository

## Step 4 — Install Termux
Install **Termux** from F-Droid (recommended, more up to date) or Play Store.

## Step 5 — Get the zip file onto your phone
Download the `operation_comeback.zip` file I shared with you — it will land
in your phone's **Downloads** folder.

## Step 6 — In Termux, run these commands one by one

```bash
pkg update -y
pkg install -y git unzip

# Give Termux permission to see your Downloads folder
termux-setup-storage

# Go to your Downloads folder and unzip the project
cd ~/storage/downloads
unzip operation_comeback.zip -d operation_comeback
cd operation_comeback

# Set up git identity (use your GitHub email/username)
git config --global user.email "youremail@example.com"
git config --global user.name "YourGitHubUsername"

# Initialize and push
git init
git add .
git commit -m "Initial commit - Operation Comeback core"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/operation-comeback.git
git push -u origin main
```

When it asks for a **username**, type your GitHub username.
When it asks for a **password**, paste the **Personal Access Token** from Step 2
(not your GitHub password — GitHub no longer accepts passwords here).

## Step 7 — Watch it build
1. Go to your repo on github.com → **Actions** tab
2. You'll see "Build APK" running (takes ~3-5 minutes)
3. When it's green ✅, tap into that run → scroll down to **Artifacts**
4. Download **operation-comeback-apk** — this is a zip containing your `.apk`

## Step 8 — Install on your phone
1. Unzip the artifact download → you'll get `app-release.apk`
2. Tap it to install
3. Android will warn about "unknown sources" the first time — allow it, this
   is normal for apps not from the Play Store
4. Open **Operation Comeback** 🎉

## Making future updates
Whenever I give you new code/modules, repeat Step 6's `git add / commit / push`
commands from inside the `operation_comeback` folder (you can skip `git init`
and `git remote add` the second time — only needed once). Every push triggers
a fresh automatic build.

## What's inside this version
- **Dashboard** — today's habit progress, journal/notes counts, last mood
- **Habits** — add habits, daily check-off, streak tracking, categories
- **Journal** — daily/gratitude/anger/reflection entries with mood tags
- **Notes** — folders, tags, pinning, search
- All data stored locally in SQLite — nothing leaves your phone, no login required

## Coming in future rounds
AI Coach, Academics, DSA, Development, Placement, Fitness, Finance, Calendar,
Goals, Reminders, Analytics, PIN/fingerprint lock, backup/export.
