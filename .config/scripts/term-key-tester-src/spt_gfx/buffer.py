import re
from os import get_terminal_size
from typing import List, Callable, Tuple

from .color import AnsiStyle, ANSI_CLOSERS
from .event_handler import EventHandler


ansiEscapeRegex = re.compile(r'(?:\x1B[@-_]|[\x80-\x9F])[0-?]*[ -/]*[@-~]')
wordChunkRegex = re.compile(r'[\w\"\'&%/(\[]*[-,.!?:;\])]*')


class Buffer:

    _eventHandler: EventHandler
    _data: List[str]
    _screenWidth: int
    _screenHeight: int
    _width: int
    _height: int
    _z: int
    update: Callable = lambda *args: args

    def __init__(self):
        self._eventHandler = EventHandler()
        self._data = []
        size = get_terminal_size()
        self._width = size.columns
        self._height = size.lines
        self._screenWidth = size.columns
        self._screenHeight = size.lines
        self._z = 0

    def resize(self, newWidth: int, newHeight: int):
        self._screenWidth = newWidth
        self._screenHeight = newHeight
        self._width = newWidth
        self._height = newHeight
        return

    def clear(self):
        self._data = []
        return

    def _setCurPos(self, x: int, y: int):
        self._data.append(f"\x1b[{y};{x}H")
        return

    def _processLine(self, x: int, maxWidth: int, data: str) -> Tuple[str, int]:
        escapes = list(ansiEscapeRegex.finditer(data))
        nextEscape = escapes.pop(0) if escapes else None
        preStyles = ""
        postStyles = ""
        line = ""
        limit = min(maxWidth, maxWidth - x + 1)
        start = abs(min(x - 1, 0))
        xOffset = 0
        currentIndex = 0
        while currentIndex < len(data):

            if nextEscape:
                span = nextEscape.span()
                if span[0] <= currentIndex <= span[1] - 1:
                    value = nextEscape.group()
                    if xOffset < start:
                        preStyles += value
                    elif xOffset > limit:
                        postStyles += value
                    else:
                        line += value
                    currentIndex = span[1]
                    nextEscape = escapes.pop(0) if escapes else None
                    continue

            if xOffset - start < limit:
                char = data[currentIndex]
                if char in ["\n", "\r"]:
                    currentIndex += 1
                    continue
                if start <= xOffset:
                    line += char
                xOffset += 1

            currentIndex += 1

        return preStyles + line + postStyles, xOffset - start

    def setString(self, x: int, y: int, data: str):
        if len(data) == 0:
            return
        if 0 <= x + len(data) and x <= self._width and 1 <= y <= self._height:
            line, realLen = self._processLine(x, self._width, data)
            if len(line) > 0:
                self._setCurPos(max(x, 1), min(y, self._height))
                self._data.append(line)
        return

    def setText(self, x: int, y: int, data: str):
        if x <= self._width and y <= self._height:
            lines: List[str] = data.split("\n")
            for i in range(len(lines)):
                if len(lines[i]) > 0:
                    self.setString(x, y + i, lines[i])
        return

    def setTextWrap(self, x: int, y: int, data: str):
        if len(data) == 0:
            return
        escapes = list(ansiEscapeRegex.finditer(data))
        nextEscape = escapes.pop(0) if escapes else None
        currentEscapes = ""
        limit: int = self.getWidth() - x + 1
        currentIndex = 0
        xOffset = 0
        lineOffset = 0
        line = ""
        while currentIndex < len(data):

            if nextEscape:
                span = nextEscape.span()
                if span[0] <= currentIndex <= span[1] - 1:
                    value = nextEscape.group()
                    if value in ANSI_CLOSERS:
                        line = currentEscapes + line + value
                        currentEscapes = ""
                    else:
                        currentEscapes += value
                    currentIndex = span[1]
                    nextEscape = escapes.pop(0) if escapes else None
                    continue

            char: str = data[currentIndex]
            currentIndex += 1
            if char == "\r":
                continue
            xOffset += 1
            if xOffset > limit or char == "\n":
                self.setString(x, y + lineOffset, currentEscapes + line + AnsiStyle.RESET.open)
                lineOffset += 1
                xOffset = 1
                line = char
                continue

            line += char
        if len(line) > 0:
            self.setString(x, y + lineOffset, currentEscapes + line)
        return

    def setTextWrapWords(self, x: int, y: int, data: str):
        if len(data) == 0:
            return

        escapes = list(ansiEscapeRegex.finditer(data))
        nextEscape = escapes.pop(0) if escapes else None
        currentEscapes = ""
        words = list(wordChunkRegex.finditer(data))

        def getNextWord():
            w = words.pop(0) if words else None
            while w and w.span()[0] == w.span()[1]:
                w = words.pop(0) if words else None
            return w

        nextWord = getNextWord()
        limit: int = self.getWidth() - x + 1
        currentIndex = 0
        xOffset = 0
        lineOffset = 0
        line = ""

        while currentIndex < len(data):

            if nextEscape:
                span = nextEscape.span()
                if span[0] <= currentIndex <= span[1] - 1:
                    value = nextEscape.group()
                    if value in ANSI_CLOSERS:
                        line = currentEscapes + line + value
                        currentEscapes = ""
                    else:
                        currentEscapes += value
                    currentIndex = span[1]
                    nextEscape = escapes.pop(0) if escapes else None
                    if nextWord.span()[1] <= currentIndex:
                        nextWord = getNextWord()
                    continue

            if nextWord:
                span = nextWord.span()
                if span[0] <= currentIndex <= span[1] - 1:
                    word = data[currentIndex:span[1]]
                    xOffset += len(word)
                    if xOffset > limit:
                        self.setString(x, y + lineOffset, currentEscapes + line + AnsiStyle.RESET.open)
                        lineOffset += 1
                        xOffset = len(word)
                        line = word
                    else:
                        line += word
                    currentIndex = span[1]
                    nextWord = getNextWord()
                    continue

            char: str = data[currentIndex]
            currentIndex += 1
            if char == "\r":
                continue
            xOffset += 1
            if xOffset > limit or char == "\n":
                self.setString(x, y + lineOffset, currentEscapes + line + AnsiStyle.RESET.open)
                lineOffset += 1
                if char != " ":
                    line = char
                    xOffset = 1
                else:
                    line = ""
                    xOffset = 0
                continue

            line += char

        if len(line) > 0:
            self.setString(x, y + lineOffset, currentEscapes + line)

        return

    def getData(self) -> List[str]:
        return self._data

    def getWidth(self) -> int:
        return self._width

    def getHeight(self) -> int:
        return self._height

    def getZ(self) -> int:
        return self._z

    def setZ(self, value: int):
        self._z = value
        return
