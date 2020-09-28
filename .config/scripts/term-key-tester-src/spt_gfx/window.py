from typing import Union

from .buffer import Buffer
from .color import color, Color


class Window(Buffer):

    _x: int
    _y: int
    _preferredWidth: int
    _preferredHeight: int
    _bgChar: Union[str, None] = None
    _bgStyle: Color

    def __init__(
        self,
        x: int = 0,
        y: int = 0,
        preferredWidth: int = 2 ** 32 - 1,
        preferredHeight: int = 2 ** 32 - 1
    ):
        super().__init__()
        self._x = x
        self._y = y
        self._preferredWidth = preferredWidth
        self._preferredHeight = preferredHeight
        self._width = preferredWidth
        self._height = preferredHeight

    # @Override
    def resize(self, newWidth: int, newHeight: int):
        self._screenWidth = newWidth
        self._screenHeight = newHeight
        return

    def setString(self, x: int, y: int, data: str):
        if len(data) == 0:
            return
        if (
                0 <= x + len(data) and
                x <= self._width and
                1 <= y <= self._height and
                self._x + x - 1 <= self._screenWidth and
                1 <= self._y + y - 1 <= self._screenHeight
        ):
            # process line first within window bounds, then within screen bounds
            line, realLen = self._processLine(x, self._width, data)
            if self._bgChar is not None:
                line = self._bgStyle(line + (self._bgChar * (self._width - realLen)))
            line, realLen = self._processLine(self._x + x - 1, self._screenWidth, line)

            if len(line) > 0:
                self._setCurPos(max(self._x + x - 1, 1), min(self._y + y - 1, self._screenHeight))
                self._data.append(line)
        return

    def getX(self) -> int:
        return self._x

    def setX(self, value: int):
        self._x = value

    def modX(self, amount: int):
        self._x += amount

    def getY(self) -> int:
        return self._y

    def setY(self, value: int):
        self._y = value

    def modY(self, amount: int):
        self._y += amount

    def setWidth(self, value: int):
        self._width = value

    def modWidth(self, amount: int):
        self._width += amount

    def setHeight(self, value: int):
        self._height = value

    def modHeight(self, amount: int):
        self._height += amount

    def setBg(self, style: Color, char: str = " "):
        self._bgChar = char
        self._bgStyle = style
