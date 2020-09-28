import sys
from io import TextIOWrapper
from typing import List


class Output:

    _out: TextIOWrapper
    _buffer: List[str] = []
    _isAltBuffer: bool = False

    def __init__(self, out: TextIOWrapper = sys.stdout):
        self._out = out
        return

    def write(self, data: str):
        self._buffer.append(data)

    def writeSafe(self, data: str):
        """
        Escape ANSI escape codes.
        """
        self._buffer.append(data.replace("\x1b", "?"))

    def clearScreen(self):
        self.write("\x1b[2J")
        return

    def clearBuffer(self):
        self._buffer = []
        return

    def enterAltBuffer(self):
        self._isAltBuffer = True
        self.write("\x1b[?1049h\x1b[H")
        return

    def exitAltBuffer(self):
        self._isAltBuffer = False
        self.write("\x1b[?1049l")
        return

    def enableAutoWrap(self, flag: bool):
        if flag:
            self.write("\x1b[?7h")
        else:
            self.write("\x1b[?7l")

    def setCurPos(self, x: int, y: int):
        self.write(f"\x1b[{y};{x}H")

    def hideCursor(self):
        self.write("\x1b[?25l")

    def showCursor(self):
        self.write("\x1b[?12l\x1b[?25h")

    def flush(self):
        if not self._buffer:
            return

        data = "".join(self._buffer)
        try:
            self._out.buffer.write(data.encode(self._out.encoding or "utf-8", "replace"))
            self._out.flush()
        except (IOError, RuntimeError):
            pass

        self._buffer = []

