#! /usr/bin/env python3
# from: https://github.com/Afillated/carbonflake/blob/main/system/desktop/scripts/elephant-bridge.py
import json
import os
import socket
import struct
import sys
import threading

QUERY, ACTIVATE, FMT_JSON = 0, 1, 1
DONE, EMPTY = 255, 254
lock = threading.Lock()


def sock_path():
    rd = os.environ.get("XDG_RUNTIME_DIR")
    if rd:
        return os.path.join(rd, "elephant", "elephant.sock")
    return "/tmp/elephant/elephant.sock"


def emit(obj):
    with lock:
        sys.stdout.write(json.dumps(obj) + "\n")
        sys.stdout.flush()


def send(conn, kind, payload):
    body = json.dumps(payload).encode()
    conn.sendall(bytes([kind, FMT_JSON]) + struct.pack(">I", len(body)) + body)


def recv_exact(conn, n):
    buf = b""
    while len(buf) < n:
        chunk = conn.recv(n - len(buf))
        if not chunk:
            raise EOFError
        buf += chunk
    return buf


def do_query(cmd):
    q = cmd["query"]
    try:
        with socket.socket(socket.AF_UNIX) as conn:
            conn.connect(sock_path())
            send(
                conn,
                QUERY,
                {
                    "providers": cmd["providers"],
                    "query": q,
                    "maxresults": cmd.get("max", 30),
                    "exactsearch": False,
                },
            )
            while True:
                prefix, length = struct.unpack(">BI", recv_exact(conn, 5))
                payload = recv_exact(conn, length) if length else b""
                if prefix == DONE:
                    break
                if prefix == EMPTY or not payload:
                    continue
                resp = json.loads(payload)
                emit({"type": "item", "query": q, "item": resp.get("item", {})})
    except (OSError, EOFError, ValueError) as e:
        emit({"type": "error", "message": str(e)})
    emit({"type": "done", "query": q})


def do_activate(cmd):
    try:
        with socket.socket(socket.AF_UNIX) as conn:
            conn.connect(sock_path())
            send(
                conn,
                ACTIVATE,
                {
                    "provider": cmd["provider"],
                    "identifier": cmd["identifier"],
                    "action": cmd["action"],
                    "query": cmd.get("query", ""),
                    "arguments": cmd.get("arguments", ""),
                },
            )
    except OSError as e:
        emit({"type": "error", "message": str(e)})


for line in sys.stdin:
    try:
        cmd = json.loads(line)
    except ValueError:
        continue
    target = {"query": do_query, "activate": do_activate}.get(cmd.get("op"))
    if target:
        threading.Thread(target=target, args=(cmd,)).start()
