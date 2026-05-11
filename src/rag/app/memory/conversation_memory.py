"""
memory.py — Production conversation store with TTL eviction.
Keeps the last N turns per session so "why?" follow-ups work correctly.
Evicts sessions older than TTL and caps total sessions to prevent OOM.
"""

import time
import threading
from collections import OrderedDict, deque
from dataclasses import dataclass
from typing import Literal
import os

from app.core.config import settings
from app.core.logging_setup import get_logger

logger = get_logger(__name__)
@dataclass
class Turn:
    role: Literal["user", "assistant"]
    content: str


class ConversationMemory:
    """
    Stores the last `max_turns` exchanges for a single chat session.
    Each session is identified by a session_id string.

    Production safeguards:
      - TTL eviction: sessions older than `ttl_seconds` are auto-removed.
      - Max sessions cap: LRU eviction when `max_sessions` is reached.
      - Thread-safe: all mutations guarded by a lock.
    """

    def __init__(
        self,
        max_turns: int = 6,
        max_sessions: int = 200,
        ttl_seconds: int = 3600,  # 1 hour
    ):
        # max_turns pairs of (user, assistant) = max_turns * 2 messages
        self.max_turns = max_turns
        self.max_sessions = max_sessions
        self.ttl_seconds = ttl_seconds
        self._sessions: OrderedDict[str, deque[Turn]] = OrderedDict()
        self._timestamps: dict[str, float] = {}
        self._lock = threading.Lock()

    def _evict_expired(self):
        """Remove sessions older than TTL. Must be called under lock."""
        now = time.time()
        expired = [
            sid for sid, ts in self._timestamps.items()
            if now - ts > self.ttl_seconds
        ]
        for sid in expired:
            self._sessions.pop(sid, None)
            self._timestamps.pop(sid, None)

    def _get(self, session_id: str) -> deque[Turn]:
        with self._lock:
            self._evict_expired()
            if session_id not in self._sessions:
                # Enforce max sessions (LRU eviction — oldest first)
                while len(self._sessions) >= self.max_sessions:
                    oldest_sid, _ = self._sessions.popitem(last=False)
                    self._timestamps.pop(oldest_sid, None)
                self._sessions[session_id] = deque(maxlen=self.max_turns * 2)
            # Move to end (most recently used)
            self._sessions.move_to_end(session_id)
            self._timestamps[session_id] = time.time()
            return self._sessions[session_id]

    def add(self, session_id: str, role: Literal["user", "assistant"], content: str):
        self._get(session_id).append(Turn(role=role, content=content))

    def get_history(self, session_id: str) -> list[dict]:
        """
        Return history as list of {"role": ..., "content": ...} dicts for Ollama.

        Bug #36 fix: does NOT create a new session if the ID is unknown.
        The old implementation called _get() which always created a session on
        first access — causing every new session_id to silently spawn an empty
        entry, refreshing TTL and wasting the LRU slot.
        """
        with self._lock:
            self._evict_expired()
            if session_id not in self._sessions:
                return []          # unknown session → return empty history, don't create
            # Touch LRU order and TTL only for sessions that already exist
            self._sessions.move_to_end(session_id)
            self._timestamps[session_id] = time.time()
            return [
                {"role": t.role, "content": t.content}
                for t in self._sessions[session_id]
            ]

    def clear(self, session_id: str):
        with self._lock:
            self._sessions.pop(session_id, None)
            self._timestamps.pop(session_id, None)

    def list_sessions(self) -> list[str]:
        with self._lock:
            return list(self._sessions.keys())

    @property
    def session_count(self) -> int:
        return len(self._sessions)


# Global singleton shared across all requests
MAX_TURNS    = int(os.getenv("MAX_TURNS", "6"))
MAX_SESSIONS = int(os.getenv("MAX_SESSIONS", "200"))
SESSION_TTL  = int(os.getenv("SESSION_TTL", "3600"))
memory = ConversationMemory(
    max_turns=MAX_TURNS,
    max_sessions=MAX_SESSIONS,
    ttl_seconds=SESSION_TTL,
)
