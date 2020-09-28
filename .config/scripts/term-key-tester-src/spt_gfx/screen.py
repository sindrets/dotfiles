from threading import Thread
from typing import Callable
import logging
import traceback

from .buffer import Buffer
from .event import Event
from .input import Input, Key, KeyEvent
from .output import Output
from .renderer import Renderer


class Screen(Buffer):

    _out: Output
    _renderer: Renderer
    _closeRequested: bool = False
    _thread: Thread

    def __init__(self):
        super().__init__()
        self._out = Output()
        self._renderer = Renderer(self._out, self._eventHandler)
        self._renderer.addBuffer(self)
        return

    def open(self):
        self._out.enterAltBuffer()
        self._out.enableAutoWrap(False)
        self._out.hideCursor()
        self._out.flush()
        self._thread = Thread(target=self._listen)
        self._thread.start()

    def close(self):
        self._out.exitAltBuffer()
        self._out.enableAutoWrap(True)
        self._out.showCursor()
        self._out.flush()
        self._closeRequested = True
        return

    def refresh(self):
        self._renderer.render()
        return

    def _listen(self):
        try:
            while not self._closeRequested:
                keyEvent = Input.getKey()
                self._eventHandler.trigger(Event.KEY_PRESSED, keyEvent)
                # Don't close on ctrl_c / ctrl_d if user has marked event as invalid.
                if keyEvent.valid and keyEvent.keys.intersection({Key.CTRL_C, Key.CTRL_D}):
                    self.close()
                    break
        except:
            self.close()
            logging.error(traceback.format_exc())

    def addBuffer(self, buffer: Buffer):
        self._renderer.addBuffer(buffer)
        return

    def removeBuffer(self, buffer: Buffer):
        self._renderer.removeBuffer(buffer)
        return

    def addKeyListener(self, callback: Callable[[KeyEvent], None]):
        self._eventHandler.on(Event.KEY_PRESSED, callback)
        return

    def addResizeListener(self, callback: Callable):
        self._eventHandler.on(Event.WIN_RESIZE, callback)
        return
