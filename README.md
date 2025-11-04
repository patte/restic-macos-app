# restic backup macOS (keychain, TouchID, scoped FDA)

Bundle a restic backup script into a ".app" on macOS. Use TouchID to unlock the repo password stored in the macOS Keychain and only requires Full-Disk-Access for this app not for Terminal.

Uses the installed restic binary on the system, making it easy to update restic without rebuilding the app. Currently backs up the user's home directory (excluding [many things](./exclude.txt)) not the entire disk.

<img width="191" height="185.5" alt="Screenshot 2025-11-04 at 23 59 17" src="https://github.com/user-attachments/assets/a299b651-fa0c-46a5-809d-9f5273135809" />

## Create restic-backup.app

1. Prepare
- Install restic: `brew install restic`
- Download [`keymaster.swift`](https://github.com/johnthethird/keymaster/blob/master/keymaster.swift)
- Build `swiftc keymaster.swift`
- Install Platypus: `brew install --cask platypus`

2. adapt [`exclude.txt`](./exclude.txt) to your needs

3. `cp .env.example .env` and adapt it to your needs

4. Create entry in keychain: ` ./keymaster set restic-backup PASSWORD`. Make sure to back this up somewhere! If you need to make a disaster recovery of your mac and you don't have this password stored somewhere else you'll have a bad time.

5. Create the `.app` with Platypus
- Open Platypus.app
- App Name: `restic-backup`
- Script Type: `sh`
- Select Script: select [`backup.sh`](./backup.sh)
- Drag and drop the files into the bundle: `exclude.txt`, `keymaster` and `.env`
- Click `Create App`, save to to the Applications folder.

6. Give Full-Disk-Access to the created `restic-backup.app` in System Settings -> Security & Privacy -> Privacy -> Full Disk Access

7. First time run: `./init.sh` manually to create the repository

8. To avoid that macOS asks for permissions (`“restic-backup.app” would like to access files in your Desktop folder.`, `“restic-backup.app” Would Like to Access Your Photo Library`) every run, sign the app:
```
codesign --force --deep -s - /Applications/restic-backup.app
```

9. Run the backup by double-clicking the `restic-backup.app` and authenticate with TouchID when prompted.


## Automate with launchd

To run the backup automatically on a schedule, use `launchd`. This will run the backup every day at 20:00, which will asks for TouchID and show the app in the Dock while running.

1. Copy [`com.user.restic-backup.plist`](./com.user.restic-backup.plist) to `~/Library/LaunchAgents/com.USERNAME.restic-backup.plist` and replace `USERNAME` with your macOS username.
```
cp com.user.restic-backup.plist ~/Library/LaunchAgents/com.$USER.restic-backup.plist
sed -i '' 's/USERNAME/$USER/g' ~/Library/LaunchAgents/com.$USER.restic-backup.plist
```
2. Load the job: `launchctl load ~/Library/LaunchAgents/com.$USER.restic-backup.plist`
3. Check the logs in Console.app by filtering for `restic-backup`

