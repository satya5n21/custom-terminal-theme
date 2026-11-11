# Custom Terminal Theme - v1

A small, dependency-free terminal theme that looks the same on **Windows, macOS and Linux**.

Every time you open a terminal you get:

- a cyan -> purple gradient greeting banner (*Good morning / afternoon / evening, <name>*)
- today's date and time
- a random one-line dev quote
- a two-line prompt that shows the time, the current folder and the **git branch**

```
+==============================================+
   >>>  Good evening, Satya
+==============================================+
  DATE: Thursday, 12 Nov 2026   TIME: 21:04
  "Ship it. Then make it better."

+-- 21:04 ~/projects/my-app (git:main)
'-> _
```

| Your OS | Shell it customises | Folder |
| --- | --- | --- |
| Windows 10/11 | PowerShell | [`windows/`](windows) |
| macOS | zsh (default) or bash | [`macos/`](macos) |
| Linux (and WSL) | bash (default) or zsh | [`linux/`](linux) |

Everything is plain ASCII, so **no special font is needed**.

---

## Quick start

First get the files onto your machine (pick one):

```bash
git clone <this-repo-url>
cd custom-terminal-theme/v1
```

...or download the repo as a ZIP from GitHub and unzip it. Then follow the section for your OS.

### Windows (PowerShell)

Open **PowerShell** in the `v1` folder and run:

```powershell
# 1. Create your profile file if it doesn't exist yet (also creates its folder)
if (!(Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force | Out-Null }

# 2. Back up whatever you had before
Copy-Item $PROFILE "$PROFILE.bak" -Force

# 3. Install the theme
Copy-Item .\windows\Microsoft.PowerShell_profile.ps1 $PROFILE -Force
```

Close the window and open a new PowerShell. Done.

> **Heads-up:** this *replaces* your profile. If you already had one, your old copy is saved as `$PROFILE.bak` - merge anything you still need.

If you see *"running scripts is disabled on this system"*, allow local profiles once and open a new window:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

`$PROFILE` points at a different file for Windows PowerShell 5.1 (`Documents\WindowsPowerShell\...`) and PowerShell 7 (`Documents\PowerShell\...`). Run the three commands above from the PowerShell you actually use (or run them in both).

**Uninstall:** `Copy-Item "$PROFILE.bak" $PROFILE -Force` (or just delete `$PROFILE`).

### macOS

Open **Terminal** (or iTerm2) in the `v1` folder and run:

```bash
bash macos/install.sh
```

Open a new terminal window. Done.

- macOS uses **zsh** by default, so the installer edits `~/.zshrc`. If you switched to bash, it edits `~/.bash_profile`. Force a choice with `--shell zsh` or `--shell bash`.
- Apple's built-in **Terminal.app** doesn't support 24-bit colour, so the gradient is drawn with the nearest 256 colours (a bit more "stepped"). **iTerm2, WezTerm, Ghostty, Warp and VS Code** show the full smooth gradient.

**Uninstall:** `bash macos/install.sh --uninstall`

### Linux (and WSL)

Open a terminal in the `v1` folder and run:

```bash
bash linux/install.sh
```

Open a new terminal. Done.

- The installer edits `~/.bashrc` for bash or `~/.zshrc` for zsh, based on the shell you're using. Force a choice with `--shell bash` or `--shell zsh`.
- `git` is only needed for the branch display - without it the prompt simply shows no branch.
- fish and other shells are not supported in v1.

**Uninstall:** `bash linux/install.sh --uninstall`

---

## Customise it

### Change the name in the greeting

| OS | How |
| --- | --- |
| macOS / Linux | Re-run the installer with a name: `bash macos/install.sh --name "Ada"` (or `linux/install.sh`). Default is your login name. |
| Windows | Open `$PROFILE` (`notepad $PROFILE`) and change `Satya` in the `>>>  $greet, Satya` line. |

### Change the quotes

- **Windows:** edit the `$quotes` list in the profile.
- **macOS / Linux:** edit the `case $((RANDOM % 5))` block in `~/.config/custom-terminal-theme/terminal-theme.sh`. To add a quote, add a branch and bump the `5`.

### Show host / uptime line (macOS & Linux)

The theme ships with an extra info line you can switch on: in `~/.config/custom-terminal-theme/terminal-theme.sh`, remove the `#` at the start of the line that begins `# printf '  \033[90mHOST:`. Windows has the same thing as the commented `PC:` line in the profile.

### Colours on macOS / Linux

The theme auto-detects 24-bit colour via the `COLORTERM` variable. Override it by setting this before the theme loads (for example in the installer block in your rc file):

```bash
export THEME_TRUECOLOR=1   # force the smooth 24-bit gradient
export THEME_TRUECOLOR=0   # force the 256-colour fallback
```

### Editing the installed theme

On macOS/Linux the installer **copies** the theme to `~/.config/custom-terminal-theme/terminal-theme.sh`. Edit that copy to tweak it, or edit the repo copy and re-run the installer to update it.

---

## Troubleshooting

| Problem | Fix |
| --- | --- |
| Nothing changed | Open a **new** terminal window (or `source ~/.zshrc` / `source ~/.bashrc`). |
| Garbled text like `←[38;2;...m` or `\033[...` | Your terminal doesn't understand ANSI colours. Use Windows Terminal, iTerm2, GNOME Terminal, Konsole, etc. (legacy `cmd.exe`/old consoles won't work). |
| Gradient looks blocky | Your terminal lacks 24-bit colour (e.g. Terminal.app). Expected - see the colour notes above. |
| macOS/Linux: prompt didn't change but banner did (or vice versa) | Another prompt framework (oh-my-zsh theme, starship, powerlevel10k...) is overriding `PROMPT`/`PS1`. Move the `custom-terminal-theme` block to the **very end** of your rc file, or disable the other theme. |
| macOS: nothing happens in bash | Terminal.app reads `~/.bash_profile`, not `~/.bashrc`; the installer already handles this - re-run it with `--shell bash`. |
| Windows: red error on startup | Run `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`, then reopen PowerShell. |

## What the installer actually changes (macOS / Linux)

Nothing outside your home folder. It:

1. copies `terminal-theme.sh` to `~/.config/custom-terminal-theme/` (respects `$XDG_CONFIG_HOME`);
2. appends one clearly marked block to your rc file, between `# >>> custom-terminal-theme >>>` and `# <<< custom-terminal-theme <<<`;
3. saves a timestamped backup of the rc file next to it (`.ctt-backup-<date>`).

Re-running it updates the block instead of duplicating it, and `--uninstall` removes it cleanly. The theme does nothing in non-interactive shells, so it can't break `scp`, `ssh host command`, or scripts.

## Folder layout

```
v1/
├── README.md
├── windows/
│   └── Microsoft.PowerShell_profile.ps1
├── macos/
│   ├── install.sh
│   └── terminal-theme.sh
└── linux/
    ├── install.sh
    └── terminal-theme.sh
```
