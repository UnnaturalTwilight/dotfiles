#! /usr/bin/env python3
# Based on: https://github.com/Afillated/carbonflake/blob/main/system/desktop/scripts/elephant-bridge.py
"""Line-delimited JSON bridge to Elephant.

Every output echoes id when supplied. Query item/done/error outputs carry the
requested providers list and query (not the item's provider). State outputs carry
provider, query, states and actions; activation acknowledgements carry provider,
query, identifier and action. Errors carry the available request context and op.
Query errors are followed by done, as before. State has no separate done output.
Only wait:true activations emit activated, after Elephant's empty completion frame.
While waiting, item outputs carry the activation context and update (true for
QueryAsyncItem, false for QueryItem); state outputs are forwarded too. No done is
emitted for activation. Completion has no keep-open/refresh metadata: those are
client action policies (Walker's after setting), not Elephant protocol fields.
Items, including providerlist identifiers and Bluetooth action order, pass through
unchanged; provider selection and safe default actions belong to the caller.
"""
import json
import os
import socket
import struct
import sys
import threading

QUERY, ACTIVATE, STATE, FMT_JSON = 0, 1, 4, 1
ITEM, ASYNC_ITEM, ACTIVATION_FINISHED, PROVIDER_STATE = 0, 1, 2, 3
DONE, EMPTY, STATUS_DONE = 255, 254, 253
CONNECT_TIMEOUT = 5
RESPONSE_TIMEOUT = 60
ACTIVATION_TIMEOUT = 120
MAX_FRAME_SIZE = 16 * 1024 * 1024
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


def context(cmd):
    result = {key: cmd[key] for key in
              ("id", "op", "providers", "provider", "query", "identifier", "action")
              if key in cmd}
    if cmd.get("op") in ("activate", "state"):
        result.setdefault("query", "")
    return result


def output(cmd, kind, **fields):
    emit({**context(cmd), **fields, "type": kind})


def send(conn, kind, payload):
    body = json.dumps(payload).encode()
    conn.sendall(bytes([kind, FMT_JSON]) + struct.pack(">I", len(body)) + body)


def recv_exact(conn, n):
    buf = bytearray()
    while len(buf) < n:
        chunk = conn.recv(n - len(buf))
        if not chunk:
            raise EOFError("Elephant closed the socket before completing the response")
        buf.extend(chunk)
    return bytes(buf)


def recv_frame(conn):
    kind, length = struct.unpack(">BI", recv_exact(conn, 5))
    if length > MAX_FRAME_SIZE:
        raise ValueError("Elephant response frame is too large")
    return kind, recv_exact(conn, length)


def decode_object(payload):
    value = json.loads(payload)
    if not isinstance(value, dict):
        raise TypeError("Elephant response must be a JSON object")
    return value


def require_string(cmd, key, default=None):
    value = cmd.get(key, default)
    if not isinstance(value, str):
        raise TypeError(f"{key} must be a string")
    return value


def connect(conn, timeout=RESPONSE_TIMEOUT):
    conn.settimeout(CONNECT_TIMEOUT)
    conn.connect(sock_path())
    conn.settimeout(timeout)


def do_query(cmd):
    try:
        q = require_string(cmd, "query")
        providers = cmd.get("providers")
        if not isinstance(providers, list) or not all(
            isinstance(provider, str) and provider for provider in providers
        ):
            raise ValueError("providers must be a list of nonempty strings")
        maximum = cmd.get("max", 30)
        if type(maximum) is not int or maximum < 0:
            raise ValueError("max must be a nonnegative integer")
        with socket.socket(socket.AF_UNIX) as conn:
            connect(conn)
            send(conn, QUERY, {
                "providers": providers, "query": q, "maxresults": maximum,
                "exactsearch": False,
            })
            while True:
                kind, payload = recv_frame(conn)
                if kind == DONE:
                    break
                if kind == EMPTY:
                    continue
                if kind not in (ITEM, ASYNC_ITEM):
                    raise ValueError(f"Unexpected query response type: {kind}")
                resp = decode_object(payload)
                item = resp.get("item", {})
                if not isinstance(item, dict):
                    raise TypeError("Elephant query item must be a JSON object")
                output(cmd, "item", item=item)
    except (OSError, EOFError, ValueError, TypeError) as e:
        output(cmd, "error", message=str(e))
    output(cmd, "done")


def output_state(cmd, payload):
    resp = decode_object(payload)
    provider = cmd["provider"]
    if resp.get("provider", provider) != provider:
        raise ValueError("Elephant state provider does not match request")
    states = resp.get("states") or []
    actions = resp.get("actions") or []
    if not isinstance(states, list) or not isinstance(actions, list):
        raise TypeError("Elephant states and actions must be lists")
    output(cmd, "state", states=states, actions=actions)


def do_state(cmd):
    try:
        provider = require_string(cmd, "provider")
        require_string(cmd, "query", "")
        with socket.socket(socket.AF_UNIX) as conn:
            connect(conn)
            send(conn, STATE, {"provider": provider})
            while True:
                kind, payload = recv_frame(conn)
                # Current upstream uses StatusDone; also accept QueryDone.
                if kind in (STATUS_DONE, DONE):
                    break
                if kind != PROVIDER_STATE:
                    raise ValueError(f"Unexpected state response type: {kind}")
                output_state(cmd, payload)
    except (OSError, EOFError, ValueError, TypeError) as e:
        output(cmd, "error", message=str(e))


def do_activate(cmd):
    try:
        payload = {key: require_string(cmd, key)
                   for key in ("provider", "identifier", "action")}
        payload.update({key: require_string(cmd, key, "")
                        for key in ("query", "arguments")})
        wait = cmd.get("wait", False)
        if not isinstance(wait, bool):
            raise TypeError("wait must be a boolean")
        with socket.socket(socket.AF_UNIX) as conn:
            connect(conn, ACTIVATION_TIMEOUT)
            send(conn, ACTIVATE, payload)
            if wait:
                while True:
                    kind, body = recv_frame(conn)
                    if kind == ACTIVATION_FINISHED:
                        if body:
                            raise ValueError("Elephant activation completion must be empty")
                        output(cmd, "activated")
                        break
                    if kind in (ITEM, ASYNC_ITEM):
                        resp = decode_object(body)
                        item = resp.get("item")
                        # UpdateItem can receive nil when a player disappears.
                        if item is None:
                            continue
                        if not isinstance(item, dict):
                            raise ValueError("Elephant activation item must be a JSON object")
                        output(cmd, "item", item=item, update=kind == ASYNC_ITEM)
                        continue
                    if kind == PROVIDER_STATE:
                        output_state(cmd, body)
                        continue
                    raise ValueError(f"Unexpected activation response type: {kind}")
    except (OSError, EOFError, ValueError, TypeError) as e:
        output(cmd, "error", message=str(e))


def handle_line(line):
    cmd = {}
    try:
        value = json.loads(line)
        if not isinstance(value, dict):
            raise TypeError("Command must be a JSON object")
        cmd = value
        op = cmd.get("op")
        if not isinstance(op, str) or op not in ("query", "activate", "state"):
            raise ValueError("op must be query, activate or state")
    except (ValueError, TypeError) as e:
        output(cmd, "error", message=str(e))
        return
    target = {"query": do_query, "activate": do_activate, "state": do_state}[op]
    threading.Thread(target=target, args=(cmd,)).start()


def main():
    for line in sys.stdin:
        handle_line(line)


if __name__ == "__main__":
    main()
