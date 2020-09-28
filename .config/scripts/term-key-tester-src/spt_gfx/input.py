import os
import sys
import termios
import tty
from enum import Enum
from typing import Union, Dict, Set


class Key(Enum):
    UNKNOWN = 0
    ENTER = 1
    CTRL_AT = 2
    CTRL_A = 3
    CTRL_B = 4
    CTRL_C = 5
    CTRL_D = 6
    CTRL_E = 7
    CTRL_F = 8
    CTRL_G = 9
    CTRL_H = 10
    CTRL_I = 11
    CTRL_J = 12
    CTRL_K = 13
    CTRL_L = 14
    CTRL_M = 15
    CTRL_N = 16
    CTRL_O = 17
    CTRL_P = 18
    CTRL_Q = 19
    CTRL_R = 20
    CTRL_S = 21
    CTRL_T = 22
    CTRL_U = 23
    CTRL_V = 24
    CTRL_W = 25
    CTRL_X = 26
    CTRL_Y = 27
    CTRL_Z = 28
    ESC = 29
    CTRL_BACKSLASH = 30
    CTRL_BRACKET_CLOSE = 31
    CTRL_CIRCUMFLEX = 32
    CTRL_UNDERSCORE = 33
    UP = 34
    DOWN = 35
    LEFT = 36
    RIGHT = 37
    CTRL_UP = 38
    CTRL_DOWN = 39
    CTRL_LEFT = 40
    CTRL_RIGHT = 41
    SHIFT_UP = 42
    SHIFT_DOWN = 43
    SHIFT_LEFT = 44
    SHIFT_RIGHT = 45
    INSERT = 46
    DELETE = 47
    HOME = 48
    END = 49
    PGUP = 50
    PGDOWN = 51
    CTRL_DELETE = 52
    SHIFT_DELETE = 53
    TAB = 54
    SHIFT_TAB = 55
    F1 = 56
    F2 = 57
    F3 = 58
    F4 = 59
    F5 = 60
    F6 = 61
    F7 = 62
    F8 = 63
    F9 = 64
    F10 = 65
    F11 = 66
    F12 = 67
    F13 = 68
    F14 = 69
    F15 = 70
    F16 = 71
    F17 = 72
    F18 = 73
    F19 = 74
    F20 = 75
    F21 = 76
    F22 = 77
    F23 = 78
    F24 = 79
    SCROLL_UP = 80
    SCROLL_DOWN = 81
    BRACKETED_PASTE = 82
    BACKSPACE = 83
    IGNORE = 84
    CTRL_BRACKET_START = 85
    CTRL_SPACE = 86


# Mapping of vt100 escape codes to Key.
ANSI_TO_KEY: Dict[bytes, Set[Key]] = {
    b"\x00": {Key.CTRL_AT, Key.CTRL_SPACE},  # CTRL_-At (Also for Ctrl-Space)
    b"\x01": {Key.CTRL_A},  # CTRL_-A (home)
    b"\x02": {Key.CTRL_B},  # CTRL_-B (emacs cursor left)
    b"\x03": {Key.CTRL_C},  # CTRL_-C (interrupt)
    b"\x04": {Key.CTRL_D},  # CTRL_-D (exit)
    b"\x05": {Key.CTRL_E},  # CTRL_-E (end)
    b"\x06": {Key.CTRL_F},  # CTRL_-F (cursor forward)
    b"\x07": {Key.CTRL_G},  # CTRL_-G
    b"\x08": {Key.CTRL_H, Key.BACKSPACE},  # CTRL_-H (8) (Identical to '\b')
    b"\x09": {Key.CTRL_I, Key.TAB},  # CTRL_-I (9) (Identical to '\t')
    b"\x0a": {Key.CTRL_J},  # CTRL_-J (10) (Identical to '\n')
    b"\x0b": {Key.CTRL_K},  # CTRL_-K (delete until end of line; vertical tab)
    b"\x0c": {Key.CTRL_L},  # CTRL_-L (clear; form feed)
    b"\x0d": {Key.CTRL_M, Key.ENTER},  # CTRL_-M (13) (Identical to '\r')
    b"\x0e": {Key.CTRL_N},  # CTRL_-N (14) (history forward)
    b"\x0f": {Key.CTRL_O},  # CTRL_-O (15)
    b"\x10": {Key.CTRL_P},  # CTRL_-P (16) (history back)
    b"\x11": {Key.CTRL_Q},  # CTRL_-Q
    b"\x12": {Key.CTRL_R},  # CTRL_-R (18) (reverse search)
    b"\x13": {Key.CTRL_S},  # CTRL_-S (19) (forward search)
    b"\x14": {Key.CTRL_T},  # CTRL_-T
    b"\x15": {Key.CTRL_U},  # CTRL_-U
    b"\x16": {Key.CTRL_V},  # CTRL_-V
    b"\x17": {Key.CTRL_W},  # CTRL_-W
    b"\x18": {Key.CTRL_X},  # CTRL_-X
    b"\x19": {Key.CTRL_Y},  # CTRL_-Y (25)
    b"\x1a": {Key.CTRL_Z},  # CTRL_-Z

    b"\x1b": {Key.ESC, Key.CTRL_BRACKET_START},            # Also CTRL_-[
    b"\x1c": {Key.CTRL_BACKSLASH},  # Both CTRL_-\ (also Ctrl-| )
    b"\x1d": {Key.CTRL_BRACKET_CLOSE},  # CTRL_-]
    b"\x1e": {Key.CTRL_CIRCUMFLEX},  # CTRL_-^
    b"\x1f": {Key.CTRL_UNDERSCORE},  # CTRL_-underscore (Also for Ctrl-hyphen.)

    b"\x7f": {Key.CTRL_H, Key.BACKSPACE},  # ASCII Delete (0x7f)

    b"\x1b[A": {Key.UP},
    b"\x1b[B": {Key.DOWN},
    b"\x1b[C": {Key.RIGHT},
    b"\x1b[D": {Key.LEFT},
    b"\x1b[H": {Key.HOME},
    b"\x1bOH": {Key.HOME},
    b"\x1b[F": {Key.END},
    b"\x1bOF": {Key.END},
    b"\x1b[3~": {Key.DELETE},
    b"\x1b[3;2~": {Key.SHIFT_DELETE},  # xterm, gnome-terminal.
    b"\x1b[3;5~": {Key.CTRL_DELETE},  # xterm, gnome-terminal.
    b"\x1b[1~": {Key.HOME},  # tmux
    b"\x1b[4~": {Key.END},  # tmux
    b"\x1b[5~": {Key.PGUP},
    b"\x1b[6~": {Key.PGDOWN},
    b"\x1b[7~": {Key.HOME},  # xrvt
    b"\x1b[8~": {Key.END},  # xrvt
    b"\x1b[Z": {Key.SHIFT_TAB},  # shift + tab
    b"\x1b[2~": {Key.INSERT},

    b"\x1bOP": {Key.F1},
    b"\x1bOQ": {Key.F2},
    b"\x1bOR": {Key.F3},
    b"\x1bOS": {Key.F4},
    b"\x1b[[A": {Key.F1},  # Linux console.
    b"\x1b[[B": {Key.F2},  # Linux console.
    b"\x1b[[C": {Key.F3},  # Linux console.
    b"\x1b[[D": {Key.F4},  # Linux console.
    b"\x1b[[E": {Key.F5},  # Linux console.
    b"\x1b[11~": {Key.F1},  # rxvt-unicode
    b"\x1b[12~": {Key.F2},  # rxvt-unicode
    b"\x1b[13~": {Key.F3},  # rxvt-unicode
    b"\x1b[14~": {Key.F4},  # rxvt-unicode
    b"\x1b[15~": {Key.F5},
    b"\x1b[17~": {Key.F6},
    b"\x1b[18~": {Key.F7},
    b"\x1b[19~": {Key.F8},
    b"\x1b[20~": {Key.F9},
    b"\x1b[21~": {Key.F10},
    b"\x1b[23~": {Key.F11},
    b"\x1b[24~": {Key.F12},
    b"\x1b[25~": {Key.F13},
    b"\x1b[26~": {Key.F14},
    b"\x1b[28~": {Key.F15},
    b"\x1b[29~": {Key.F16},
    b"\x1b[31~": {Key.F17},
    b"\x1b[32~": {Key.F18},
    b"\x1b[33~": {Key.F19},
    b"\x1b[34~": {Key.F20},

    # Xterm
    b"\x1b[1;2P": {Key.F13},
    b"\x1b[1;2Q": {Key.F14},
    # b"\x1b[1;2R": Key.F15,  # Conflicts with CPR response.
    b"\x1b[1;2S": {Key.F16},
    b"\x1b[15;2~": {Key.F17},
    b"\x1b[17;2~": {Key.F18},
    b"\x1b[18;2~": {Key.F19},
    b"\x1b[19;2~": {Key.F20},
    b"\x1b[20;2~": {Key.F21},
    b"\x1b[21;2~": {Key.F22},
    b"\x1b[23;2~": {Key.F23},
    b"\x1b[24;2~": {Key.F24},

    b"\x1b[1;5A": {Key.CTRL_UP},     # Cursor Mode
    b"\x1b[1;5B": {Key.CTRL_DOWN},   # Cursor Mode
    b"\x1b[1;5C": {Key.CTRL_RIGHT},  # Cursor Mode
    b"\x1b[1;5D": {Key.CTRL_LEFT},   # Cursor Mode

    b"\x1b[1;2A": {Key.SHIFT_UP},
    b"\x1b[1;2B": {Key.SHIFT_DOWN},
    b"\x1b[1;2C": {Key.SHIFT_RIGHT},
    b"\x1b[1;2D": {Key.SHIFT_LEFT},

    b"\x1bOA": {Key.UP},
    b"\x1bOB": {Key.DOWN},
    b"\x1bOC": {Key.RIGHT},
    b"\x1bOD": {Key.LEFT},

    b"\x1b[5A": {Key.CTRL_UP},
    b"\x1b[5B": {Key.CTRL_DOWN},
    b"\x1b[5C": {Key.CTRL_RIGHT},
    b"\x1b[5D": {Key.CTRL_LEFT},

    b"\x1bOc": {Key.CTRL_RIGHT},  # rxvt
    b"\x1bOd": {Key.CTRL_LEFT},  # rxvt

    # Tmux (Win32 subsystem) sends the following scroll events.
    b"\x1b[62~": {Key.SCROLL_UP},
    b"\x1b[63~": {Key.SCROLL_DOWN},

    b"\x1b[200~": {Key.BRACKETED_PASTE},  # Start of bracketed paste.

    b"\x1b[E": {Key.IGNORE},  # Numpad 5 Xterm.
    b"\x1b[G": {Key.IGNORE},  # Numpad 5 Linux console.
}


class KeyEvent:

    keyBytes: bytes
    value: str
    keys: Set[Key]  # defaults to Key.UNKNOWN if there's no match in ANSI_TO_KEY
    ascii: Union[int, None] = None  # only defined if the keypress value is 1 char long
    valid: bool = True

    def __init__(self, keyBytes: bytes, value: str):
        self.keyBytes = keyBytes
        self.value = value
        if len(value) == 1:
            self.ascii = ord(value)
        try:
            self.keys = ANSI_TO_KEY[keyBytes]
        except KeyError:
            self.keys = {Key.UNKNOWN}
        return

    def invalidate(self):
        self.valid = False

    def setValid(self, flag: bool):
        self.valid = flag

    def __str__(self):
        return (
            f"<KeyPress: "
            f"bytes={self.keyBytes} "
            f"ascii={self.ascii} "
            f"keys={set(map(lambda k: k.name, self.keys))} "
            f"value='{self.value}'"
            ">"
        )


class Input:

    @staticmethod
    def getKey() -> KeyEvent:
        ch = Input.read()
        value = ch.decode("utf-8", errors="surrogateescape")
        keyPress = KeyEvent(ch, value)
        return keyPress

    @staticmethod
    def read(n: int = 1024) -> bytes:
        fd = sys.stdin.fileno()
        oldSettings = termios.tcgetattr(fd)
        try:
            tty.setraw(fd)
            ch = os.read(fd, n)
            # while select([fd], [], [], 0)[0]:
            #     ch += os.read(fd, 1)
        finally:
            termios.tcsetattr(fd, termios.TCSADRAIN, oldSettings)
        return ch
