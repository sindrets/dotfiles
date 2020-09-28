from shutil import get_terminal_size
from signal import signal, SIGWINCH
from typing import List

from .buffer import Buffer
from .output import Output
from .event_handler import EventHandler
from .event import Event


class Renderer:

    _out: Output
    _eventHandler: EventHandler
    _buffers: List[Buffer]

    def __init__(self, output: Output, eventHandler: EventHandler):
        self._out = output
        self._eventHandler = eventHandler
        self._buffers = []
        signal(SIGWINCH, self._onResize)

    def _sortBuffers(self):
        self._buffers = sorted(self._buffers, key=lambda buffer: buffer.getZ())
        return

    def _onResize(self, *args):
        size = get_terminal_size()
        for buffer in self._buffers:
            buffer.resize(size.columns, size.lines)
        self._eventHandler.trigger(Event.WIN_RESIZE)
        self.render()
        return

    def render(self):
        self._sortBuffers()
        self._out.clearScreen()
        for buffer in self._buffers:
            buffer.update(buffer)
            self._out.write("".join(buffer.getData()))
        self._out.setCurPos(1, 1)
        self._out.flush()
        return

    def addBuffer(self, buffer: Buffer):
        self._buffers.append(buffer)
        return

    def removeBuffer(self, buffer: Buffer):
        self._buffers.remove(buffer)
        return
