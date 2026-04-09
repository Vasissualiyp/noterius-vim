# Logseq Sync Scheduling Guide

This guide provides examples for scheduling the Logseq sync script (`sync_logseq.sh`) to run automatically at regular intervals. The sync script keeps your Logseq journal entries in sync with your LaTeX notes, creating bidirectional links and adding handwritten notes references.

## Overview

The `sync_logseq.sh` script should be run periodically (e.g., daily) to:
- Create Logseq entries for new LaTeX notes
- Update PREV/NEXT navigation links
- Add LaTeX PDF links to Logseq entries
- Link handwritten SVG notes from the assets directory

## Prerequisites

Before setting up automated scheduling, ensure:
1. Logseq integration is enabled in your Vim/NeoVim configuration
2. The sync script is executable: `chmod +x ~/path/to/noterius/bin/sync_logseq.sh`
3. You have the correct paths configured for notes, Logseq journals, and assets

## Scheduling Methods

### 1. Cron (Linux/macOS)

Cron is the traditional Unix job scheduler. It's simple and reliable for periodic tasks.

#### Setup

1. Open your crontab:
   ```bash
   crontab -e
   ```

2. Add one of these entries:

   **Daily at 11:59 PM:**
   ```cron
   59 23 * * * /home/username/path/to/noterius/bin/sync_logseq.sh ~/research/notes ~/Documents/LogSeq/journals ~/Documents/LogSeq/assets/svg 0 >> /tmp/logseq_sync.log 2>&1
   ```

   **Every 6 hours:**
   ```cron
   0 */6 * * * /home/username/path/to/noterius/bin/sync_logseq.sh ~/research/notes ~/Documents/LogSeq/journals ~/Documents/LogSeq/assets/svg 0 >> /tmp/logseq_sync.log 2>&1
   ```

   **Every hour:**
   ```cron
   0 * * * * /home/username/path/to/noterius/bin/sync_logseq.sh ~/research/notes ~/Documents/LogSeq/journals ~/Documents/LogSeq/assets/svg 0 >> /tmp/logseq_sync.log 2>&1
   ```

3. Save and exit. Cron will automatically load the new schedule.

#### Cron Time Format

```
* * * * * command
│ │ │ │ │
│ │ │ │ └─── Day of week (0-7, 0 and 7 = Sunday)
│ │ │ └───── Month (1-12)
│ │ └─────── Day of month (1-31)
│ └───────── Hour (0-23)
└─────────── Minute (0-59)
```

#### Checking Cron Logs

View the sync log:
```bash
tail -f /tmp/logseq_sync.log
```

### 2. Systemd Timer (Linux)

Systemd timers are more flexible than cron and integrate better with modern Linux systems.

#### Setup

1. Create the service file:
   ```bash
   mkdir -p ~/.config/systemd/user
   nano ~/.config/systemd/user/noterius-logseq-sync.service
   ```

2. Add this content (adjust paths):
   ```ini
   [Unit]
   Description=Noterius Logseq Sync Service
   After=network.target

   [Service]
   Type=oneshot
   ExecStart=/home/username/path/to/noterius/bin/sync_logseq.sh /home/username/research/notes /home/username/Documents/LogSeq/journals /home/username/Documents/LogSeq/assets/svg 0
   StandardOutput=journal
   StandardError=journal

   [Install]
   WantedBy=default.target
   ```

3. Create the timer file:
   ```bash
   nano ~/.config/systemd/user/noterius-logseq-sync.timer
   ```

4. Add this content:
   ```ini
   [Unit]
   Description=Noterius Logseq Sync Timer
   Requires=noterius-logseq-sync.service

   [Timer]
   # Run daily at 11:59 PM
   OnCalendar=daily
   OnCalendar=23:59
   Persistent=true

   [Install]
   WantedBy=timers.target
   ```

5. Enable and start the timer:
   ```bash
   systemctl --user daemon-reload
   systemctl --user enable noterius-logseq-sync.timer
   systemctl --user start noterius-logseq-sync.timer
   ```

#### Systemd Timer Options

**Daily at specific time:**
```ini
OnCalendar=daily
OnCalendar=23:59
```

**Every 6 hours:**
```ini
OnCalendar=*-*-* 0/6:00:00
```

**Every hour:**
```ini
OnCalendar=hourly
```

**Weekdays at 6 PM:**
```ini
OnCalendar=Mon..Fri 18:00
```

#### Managing Systemd Timers

Check timer status:
```bash
systemctl --user status noterius-logseq-sync.timer
```

View timer list:
```bash
systemctl --user list-timers
```

View service logs:
```bash
journalctl --user -u noterius-logseq-sync.service -f
```

Stop timer:
```bash
systemctl --user stop noterius-logseq-sync.timer
```

Disable timer:
```bash
systemctl --user disable noterius-logseq-sync.timer
```

### 3. Nix Home Manager (NixOS)

If you use Nix Home Manager, you can declaratively configure the sync service.

#### Configuration

Add to your `home.nix`:

```nix
{
  # Logseq sync service
  systemd.user.services.noterius-logseq-sync = {
    Unit = {
      Description = "Noterius Logseq Sync Service";
      After = [ "network.target" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash ${config.home.homeDirectory}/path/to/noterius/bin/sync_logseq.sh ${config.home.homeDirectory}/research/notes ${config.home.homeDirectory}/Documents/LogSeq/journals ${config.home.homeDirectory}/Documents/LogSeq/assets/svg 0";
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };

  # Logseq sync timer
  systemd.user.timers.noterius-logseq-sync = {
    Unit = {
      Description = "Noterius Logseq Sync Timer";
      Requires = [ "noterius-logseq-sync.service" ];
    };

    Timer = {
      # Run daily at 11:59 PM
      OnCalendar = "23:59";
      Persistent = true;
    };

    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
```

Then apply the configuration:
```bash
home-manager switch
```

### 4. Launchd (macOS)

Launchd is macOS's native service management system.

#### Setup

1. Create a plist file:
   ```bash
   nano ~/Library/LaunchAgents/com.noterius.logseq-sync.plist
   ```

2. Add this content (adjust paths):
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>Label</key>
       <string>com.noterius.logseq-sync</string>

       <key>ProgramArguments</key>
       <array>
           <string>/Users/username/path/to/noterius/bin/sync_logseq.sh</string>
           <string>/Users/username/research/notes</string>
           <string>/Users/username/Documents/LogSeq/journals</string>
           <string>/Users/username/Documents/LogSeq/assets/svg</string>
           <string>0</string>
       </array>

       <key>StartCalendarInterval</key>
       <dict>
           <key>Hour</key>
           <integer>23</integer>
           <key>Minute</key>
           <integer>59</integer>
       </dict>

       <key>StandardOutPath</key>
       <string>/tmp/logseq_sync.log</string>

       <key>StandardErrorPath</key>
       <string>/tmp/logseq_sync_error.log</string>
   </dict>
   </plist>
   ```

3. Load the job:
   ```bash
   launchctl load ~/Library/LaunchAgents/com.noterius.logseq-sync.plist
   ```

#### Managing Launchd Jobs

Unload job:
```bash
launchctl unload ~/Library/LaunchAgents/com.noterius.logseq-sync.plist
```

Check job status:
```bash
launchctl list | grep noterius
```

View logs:
```bash
tail -f /tmp/logseq_sync.log
```

## Manual Execution

You can also run the sync script manually at any time:

```bash
~/path/to/noterius/bin/sync_logseq.sh ~/research/notes ~/Documents/LogSeq/journals ~/Documents/LogSeq/assets/svg 0
```

Parameters:
1. `notes_dir` - Path to LaTeX notes directory
2. `logseq_dir` - Path to Logseq journals directory
3. `assets_dir` - Path to handwritten notes SVG directory
4. `unified_mode` - Set to 0 for separate directories, 1 for unified mode

## Troubleshooting

### Script Not Running

1. Check script permissions:
   ```bash
   ls -l ~/path/to/noterius/bin/sync_logseq.sh
   ```
   Should show `-rwxr-xr-x` or similar. If not:
   ```bash
   chmod +x ~/path/to/noterius/bin/sync_logseq.sh
   ```

2. Check logs for error messages:
   - Cron: `/tmp/logseq_sync.log`
   - Systemd: `journalctl --user -u noterius-logseq-sync.service`
   - Launchd: `/tmp/logseq_sync_error.log`

3. Test manual execution:
   ```bash
   ~/path/to/noterius/bin/sync_logseq.sh ~/research/notes ~/Documents/LogSeq/journals ~/Documents/LogSeq/assets/svg 0
   ```

### Path Issues

If the script can't find directories, use absolute paths instead of `~`:
```bash
/home/username/research/notes
```

### Permission Denied

Ensure you have read/write permissions for all directories:
```bash
ls -ld ~/research/notes ~/Documents/LogSeq
```

## Recommendations

### Frequency

- **Daily sync (11:59 PM)**: Best for most users. Ensures links are updated once per day without overhead.
- **Hourly sync**: Useful if you frequently switch between LaTeX and Logseq throughout the day.
- **Manual sync**: Run `:NoteriusGitPush` in Vim to sync before committing notes.

### Best Practices

1. **Run before git commits**: The sync ensures all Logseq entries exist before pushing to remote repositories.

2. **Monitor logs initially**: Check logs for the first week to ensure sync runs successfully.

3. **Backup first**: Before enabling automated sync, backup your Logseq directory:
   ```bash
   cp -r ~/Documents/LogSeq ~/Documents/LogSeq.backup
   ```

4. **Test with unified mode**: If using unified mode, test manually first to ensure paths are correct.

5. **Combine with git sync**: Set up similar scheduling for git commits to keep remote repositories in sync.

## Integration with Noterius Git Push

The `:NoteriusGitPush` command automatically:
1. Runs cleanup on LaTeX notes
2. Commits LaTeX notes to git
3. If Logseq is enabled, commits Logseq notes to git

Consider scheduling both sync and git push together:

**Cron example:**
```cron
# Sync Logseq first
55 23 * * * /path/to/sync_logseq.sh ~/research/notes ~/Documents/LogSeq/journals ~/Documents/LogSeq/assets/svg 0
# Then commit everything
59 23 * * * cd ~/research/notes && /path/to/git_commit_notes.sh ~/research/notes 1 1 ~/Documents/LogSeq/journals
```

## See Also

- [Noterius Documentation](../README.md)
- [Logseq Integration Overview](./logseq_integration.md)
- [Cron Documentation](https://man7.org/linux/man-pages/man5/crontab.5.html)
- [Systemd Timer Documentation](https://www.freedesktop.org/software/systemd/man/systemd.timer.html)
