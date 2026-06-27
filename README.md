# 🐍 Snake Suite — Linux Edition

A Bash port of the [Snake_Windows_PS](https://github.com/Ligrys111/Snake_Windows_PS) script collection for Linux.

> **Note:** the original `Snake-Downloader` function (downloading from YouTube via an API that bypasses the platform's protections) was **not ported**. Everything else is fully functional.

## ⚡ One-line install

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main/snake.sh -o ~/.snake_suite.sh && echo '[ -f ~/.snake_suite.sh ] && source ~/.snake_suite.sh' >> ~/.bashrc && source ~/.bashrc
```

This downloads `snake.sh`, adds it to `~/.bashrc`, and loads the functions into your current session. It will work the same way every time you open a new terminal.

### Try it without installing (current session only)

```bash
source <(curl -fsSL https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main/snake.sh)
```

## 🚀 Commands

| Command | Alias | Description |
|---|---|---|
| `snake` | `s-n` | Animated retro snake in the terminal |
| `snake-info` | — | System specs + ASCII art |
| `snake-matrix` | `s-m` | Matrix digital rain effect |
| `snake-weather [city] [-Reset]` | `s-w` | Live weather (Open-Meteo + Nominatim) |
| `snake-help` | `s-h` | Help menu |

To exit the animated loops (`snake`, `snake-matrix`): **Ctrl+C**.

## 🔒 Requirements

- Bash 4+ (tested on Bash 5.2)
- `curl` (for `snake-weather`)
- `jq` optional (better JSON parsing; falls back to `grep`/`sed` without it)
- `tput`, `lscpu`/`/proc/cpuinfo`, `lspci` (optional, used by `snake-info`)
