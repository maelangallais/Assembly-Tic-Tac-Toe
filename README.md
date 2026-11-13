# ❌⭕ Assembly Tic-Tac-Toe

A terminal-based **Tic-Tac-Toe** game written in **x86-64 GNU Assembly (AT&T syntax)** for Windows, where the entire game state—board cells, cursor coordinates, and active player—is bit-packed into a single 32-bit register (`%r15d`).

## 📂 Files Included

- **`ticTacToe.s`** — Main x86-64 assembly source for the Tic-Tac-Toe game.
- **`ticTacToe.exe`** — Pre-compiled Windows executable of `ticTacToe.s`.
- **`inputs/inputs.s`** *(Created August 12, 2025)* — Accompanying key-code inspection utility written to identify ASCII and extended (`0` / `0xE0` prefix) scan codes returned by `getch` on Windows. It reads 5 keystrokes and prints their numeric codes.
- **`inputs/inputs.exe`** — Pre-compiled Windows executable of `inputs/inputs.s`.

## ✨ How It Works

- **Bit-Packed State (`%r15d`)**:
  - **Bits 0–1**: Cursor `Y` position (`0`–`2`).
  - **Bits 2–3**: Cursor `X` position (`0`–`2`).
  - **Bits 4–7**: Previous cursor `Y` / `X` coordinates.
  - **Bit 8**: Active player (`0` = `X`, `1` = `O`), preserved across rounds.
  - **Bits 9–26**: 3×3 board stored as 9 cells × 2 bits (`00` = empty, `10` = `X`, `11` = `O`).
- **Console Rendering**: Uses the Windows Console API (`GetStdHandle`, `SetConsoleCursorPosition`) to move the terminal cursor directly over the 3×3 grid and update cells in place.

## ⌨️ Controls

| Key | Action |
| :--- | :--- |
| **Arrow Keys** (`↑` `↓` `←` `→`) or **`z` `q` `s` `d`** | Move cursor on the 3×3 grid |
| **`Enter`** or **`Space`** | Place `X` or `O` on the selected cell |
| **`Esc`** | Quit the game |
| **Any key** (end screen) | Start a new round |

## 🚀 Running & Building

### Run Pre-compiled Executables
Download the repository and run `ticTacToe.exe` (or `inputs/inputs.exe`) directly from a Windows terminal (Command Prompt or PowerShell).

### Compile from Source
Requires **MinGW-w64 (`gcc`)** on 64-bit Windows:

```powershell
# Compile Tic-Tac-Toe
gcc ticTacToe.s -o ticTacToe.exe

# Compile the accompanying input inspector
gcc inputs/inputs.s -o inputs/inputs.exe
```

## 🖥️ Requirements & Platform

- **OS**: 64-bit Windows (relies on `GetStdHandle`, `SetConsoleCursorPosition`, `printf`, and `getch`).
- **Assembler / Linker** *(only if building from source)*: MinGW-w64 `gcc` (x86-64).

## ⚠️ Known Limitations

- **AZERTY lowercase letters**: Letter movement keys (`z`, `q`, `s`, `d`) are mapped to lowercase ASCII codes (`122`, `113`, `115`, `100`); uppercase letters and `WASD` are not mapped (use the **Arrow Keys** on any keyboard layout).
- **CPU-dependent end-of-round delay**: The `wait` routine uses a busy-wait loop (`0x8fffffff` iterations), so the pause before displaying the win/tie screen varies with CPU speed.
- **`inputs.s` output language**: The diagnostic messages in `inputs/inputs.s` are printed in French (`Touche ASCII` / `Touche speciale`).

## 🛠️ Details

The project has been created the August 11th of 2025.
