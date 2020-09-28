from typing import List
import re

ansiEscapeRegex = re.compile(r'(?:\x1B[@-_]|[\x80-\x9F])[0-?]*[ -/]*[@-~]')


class Style:
    open: str
    close: str

    def __init__(self, open: str, close: str):
        self.open = open
        self.close = close

    def __call__(self, text: str):
        return AnsiStyle.RESET.open + self.open + text + AnsiStyle.RESET.open


class AnsiStyle:
    RESET = Style(open='\x1b[0m', close='\x1b[0m')
    BOLD = Style(open='\x1b[1m', close='\x1b[22m')
    DIM = Style(open='\x1b[2m', close='\x1b[22m')
    ITALIC = Style(open='\x1b[3m', close='\x1b[23m')
    UNDERLINE = Style(open='\x1b[4m', close='\x1b[24m')
    REVERSE = Style(open='\x1b[7m', close='\x1b[27m')
    HIDDEN = Style(open='\x1b[8m', close='\x1b[28m')
    STRIKETHROUGH = Style(open='\x1b[9m', close='\x1b[29m')
    BLACK = Style(open='\x1b[30m', close='\x1b[39m')
    RED = Style(open='\x1b[31m', close='\x1b[39m')
    GREEN = Style(open='\x1b[32m', close='\x1b[39m')
    YELLOW = Style(open='\x1b[33m', close='\x1b[39m')
    BLUE = Style(open='\x1b[34m', close='\x1b[39m')
    MAGENTA = Style(open='\x1b[35m', close='\x1b[39m')
    CYAN = Style(open='\x1b[36m', close='\x1b[39m')
    WHITE = Style(open='\x1b[37m', close='\x1b[39m')
    BLACK_BRIGHT = Style(open='\x1b[90m', close='\x1b[39m')
    RED_BRIGHT = Style(open='\x1b[91m', close='\x1b[39m')
    GREEN_BRIGHT = Style(open='\x1b[92m', close='\x1b[39m')
    YELLOW_BRIGHT = Style(open='\x1b[93m', close='\x1b[39m')
    BLUE_BRIGHT = Style(open='\x1b[94m', close='\x1b[39m')
    MAGENTA_BRIGHT = Style(open='\x1b[95m', close='\x1b[39m')
    CYAN_BRIGHT = Style(open='\x1b[96m', close='\x1b[39m')
    WHITE_BRIGHT = Style(open='\x1b[97m', close='\x1b[39m')
    GRAY = Style(open='\x1b[90m', close='\x1b[39m')
    GREY = Style(open='\x1b[90m', close='\x1b[39m')
    BG_BLACK = Style(open='\x1b[40m', close='\x1b[49m')
    BG_RED = Style(open='\x1b[41m', close='\x1b[49m')
    BG_GREEN = Style(open='\x1b[42m', close='\x1b[49m')
    BG_YELLOW = Style(open='\x1b[43m', close='\x1b[49m')
    BG_BLUE = Style(open='\x1b[44m', close='\x1b[49m')
    BG_MAGENTA = Style(open='\x1b[45m', close='\x1b[49m')
    BG_CYAN = Style(open='\x1b[46m', close='\x1b[49m')
    BG_WHITE = Style(open='\x1b[47m', close='\x1b[49m')
    BG_BLACK_BRIGHT = Style(open='\x1b[100m', close='\x1b[49m')
    BG_RED_BRIGHT = Style(open='\x1b[101m', close='\x1b[49m')
    BG_GREEN_BRIGHT = Style(open='\x1b[102m', close='\x1b[49m')
    BG_YELLOW_BRIGHT = Style(open='\x1b[103m', close='\x1b[49m')
    BG_BLUE_BRIGHT = Style(open='\x1b[104m', close='\x1b[49m')
    BG_MAGENTA_BRIGHT = Style(open='\x1b[105m', close='\x1b[49m')
    BG_CYAN_BRIGHT = Style(open='\x1b[106m', close='\x1b[49m')
    BG_WHITE_BRIGHT = Style(open='\x1b[107m', close='\x1b[49m')
    BG_GRAY = Style(open='\x1b[100m', close='\x1b[49m')
    BG_GREY = Style(open='\x1b[100m', close='\x1b[49m')


ANSI_CLOSERS: List[str] = [
    AnsiStyle.RESET.close,
    AnsiStyle.BOLD.close,
    AnsiStyle.ITALIC.close,
    AnsiStyle.UNDERLINE.close,
    AnsiStyle.REVERSE.close,
    AnsiStyle.HIDDEN.close,
    AnsiStyle.STRIKETHROUGH.close,
    AnsiStyle.BLACK.close,
    AnsiStyle.BG_BLACK.close
]


class Color:
    _styles: List[Style]

    def __init__(self):
        self._styles = []

    def __call__(self, text: str) -> str:
        openers: str = self._getOpeners()
        closers: str = self._getClosers()
        escapes = list(ansiEscapeRegex.finditer(text))
        escapes.reverse()
        for e in escapes:
            value = e.group()
            if value in ANSI_CLOSERS:
                text = text[:e.span()[1]] + openers + text[e.span()[1]:]
                break
        return openers + text + closers

    def _getOpeners(self) -> str:
        openers = ""
        for style in self._styles:
            openers += style.open
        return openers

    def _getClosers(self) -> str:
        closers = ""
        for style in self._styles:
            closers += style.close
        return closers

    def _clone(self, newStyle: Style):
        clone = Color()
        clone._styles = self._styles.copy()
        if newStyle is not None:
            clone._styles.append(newStyle)
        return clone

    def getAnsiCode(self) -> str:
        code = ""
        for style in self._styles:
            code += style.open
        return code

    def ansi(self, ansiCode: str) -> "Color":
        return self._clone(Style(ansiCode, AnsiStyle.RESET.open))

    def ansi16(self, n: int) -> "Color":
        code = u"\x1b[3" + str(n % 8)
        if n > 7:
            code += ";1"
        return self._clone(Style(code + "m", AnsiStyle.BLACK.close))

    def bgAnsi16(self, n: int) -> "Color":
        code = u"\x1b[4" + str(n % 8)
        if n > 7:
            code += ";1"
        return self._clone(Style(code + "m", AnsiStyle.BG_BLACK.close))

    def ansi256(self, n: int) -> "Color":
        return self._clone(Style(u"\x1b[38;5;" + str(n % 256) + "m", AnsiStyle.BLACK.close))

    def bgAnsi256(self, n: int) -> "Color":
        return self._clone(Style(u"\x1b[48;5;" + str(n % 256) + "m", AnsiStyle.BG_BLACK.close))

    def rgb(self, r: int, g: int, b: int) -> "Color":
        return self._clone(Style(u"\x1b[38;2;" + f"{r};{g};{b}m", AnsiStyle.BLACK.close))

    def bgRgb(self, r: int, g: int, b: int) -> "Color":
        return self._clone(Style(u"\x1b[48;2;" + f"{r};{g};{b}m", AnsiStyle.BG_BLACK.close))

    # --- TEXT ATTRIBUTES ---

    @property
    def bold(self) -> "Color":
        return self._clone(AnsiStyle.BOLD)

    @property
    def dim(self) -> "Color":
        return self._clone(AnsiStyle.DIM)

    @property
    def italic(self) -> "Color":
        return self._clone(AnsiStyle.ITALIC)

    @property
    def underline(self) -> "Color":
        return self._clone(AnsiStyle.UNDERLINE)

    @property
    def reversed(self) -> "Color":
        return self._clone(AnsiStyle.REVERSE)

    @property
    def strikethrough(self) -> "Color":
        return self._clone(AnsiStyle.STRIKETHROUGH)

    # --- FG8 ---

    @property
    def black(self) -> "Color":
        return self._clone(AnsiStyle.BLACK)

    @property
    def red(self) -> "Color":
        return self._clone(AnsiStyle.RED)

    @property
    def green(self) -> "Color":
        return self._clone(AnsiStyle.GREEN)

    @property
    def yellow(self) -> "Color":
        return self._clone(AnsiStyle.YELLOW)

    @property
    def blue(self) -> "Color":
        return self._clone(AnsiStyle.BLUE)

    @property
    def magenta(self) -> "Color":
        return self._clone(AnsiStyle.MAGENTA)

    @property
    def cyan(self) -> "Color":
        return self._clone(AnsiStyle.CYAN)

    @property
    def white(self) -> "Color":
        return self._clone(AnsiStyle.WHITE)

    # --- FG16 ---

    @property
    def blackBright(self) -> "Color":
        return self._clone(AnsiStyle.BLACK_BRIGHT)

    @property
    def redBright(self) -> "Color":
        return self._clone(AnsiStyle.RED_BRIGHT)

    @property
    def greenBright(self) -> "Color":
        return self._clone(AnsiStyle.GREEN_BRIGHT)

    @property
    def yellowBright(self) -> "Color":
        return self._clone(AnsiStyle.YELLOW_BRIGHT)

    @property
    def blueBright(self) -> "Color":
        return self._clone(AnsiStyle.BLUE_BRIGHT)

    @property
    def magentaBright(self) -> "Color":
        return self._clone(AnsiStyle.MAGENTA_BRIGHT)

    @property
    def cyanBright(self) -> "Color":
        return self._clone(AnsiStyle.CYAN_BRIGHT)

    @property
    def whiteBright(self) -> "Color":
        return self._clone(AnsiStyle.BLACK_BRIGHT)

    # --- BG8 ---

    @property
    def bgBlack(self) -> "Color":
        return self._clone(AnsiStyle.BG_BLACK)

    @property
    def bgRed(self) -> "Color":
        return self._clone(AnsiStyle.BG_RED)

    @property
    def bgGreen(self) -> "Color":
        return self._clone(AnsiStyle.BG_GREEN)

    @property
    def bgYellow(self) -> "Color":
        return self._clone(AnsiStyle.BG_YELLOW)

    @property
    def bgBlue(self) -> "Color":
        return self._clone(AnsiStyle.BG_BLUE)

    @property
    def bgMagenta(self) -> "Color":
        return self._clone(AnsiStyle.BG_MAGENTA)

    @property
    def bgCyan(self) -> "Color":
        return self._clone(AnsiStyle.BG_CYAN)

    @property
    def bgWhite(self) -> "Color":
        return self._clone(AnsiStyle.BG_WHITE)

    # --- BG16 ---

    @property
    def bgBlackBright(self) -> "Color":
        return self._clone(AnsiStyle.BG_BLACK_BRIGHT)

    @property
    def bgRedBright(self) -> "Color":
        return self._clone(AnsiStyle.BG_RED_BRIGHT)

    @property
    def bgGreenBright(self) -> "Color":
        return self._clone(AnsiStyle.BG_GREEN_BRIGHT)

    @property
    def bgYellowBright(self) -> "Color":
        return self._clone(AnsiStyle.BG_YELLOW_BRIGHT)

    @property
    def bgBlueBright(self) -> "Color":
        return self._clone(AnsiStyle.BG_BLUE_BRIGHT)

    @property
    def bgMagentaBright(self) -> "Color":
        return self._clone(AnsiStyle.BG_MAGENTA_BRIGHT)

    @property
    def bgCyanBright(self) -> "Color":
        return self._clone(AnsiStyle.BG_CYAN_BRIGHT)

    @property
    def bgWhiteBright(self) -> "Color":
        return self._clone(AnsiStyle.BG_BLACK_BRIGHT)


color = Color()

if __name__ == "__main__":
    # Test nesting
    print(color.green(
        "I am a green line " +
        color.blue.underline.bold("with a blue substring") +
        " that becomes green again!"
    ))

    print(color.yellow(
        "<lvl1>" +
        color.blue.bold(
            "<lvl2>" +
            color.magenta.italic("<lvl3></lvl3>") +
            "</lvl2>"
        ) +
        "</lvl1>"
    ))
