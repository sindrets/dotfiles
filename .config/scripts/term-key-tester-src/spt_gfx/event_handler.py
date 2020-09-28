from typing import List, Union, Callable, Dict

from spt_gfx.event import Event


class EventHandler:
    _listeners: List[Dict[str, Union[Event, Callable]]] = []

    def on(self, event: Union[Event, str], callback: Callable):
        self._listeners.append({
            "event": event,
            "callback": callback
        })

    def once(self, event: Union[Event, str], callback: Callable):
        called: bool = False

        def wrapper(*args):
            nonlocal called
            if not called:
                callback(*args)
                called = True

        self.on(event, wrapper)

    def trigger(self, event: Union[Event, str], *args):
        for listener in self._listeners:
            if listener.get("event") == event:
                listener.get("callback")(*args)
