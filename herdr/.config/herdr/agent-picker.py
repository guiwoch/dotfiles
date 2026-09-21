#!/usr/bin/env python3
"""Turn herdr's agent/workspace/tab listings into fzf rows: label, task, pane id."""
import json, sys

docs = [json.loads(l) for l in sys.stdin.read().splitlines() if l.strip()]
agents = wss = tabs = None
for d in docs:
    r = d.get("result", {})
    if "agents" in r:
        agents = r["agents"]
    elif "workspaces" in r:
        wss = r["workspaces"]
    elif "tabs" in r:
        tabs = r["tabs"]

def label(items, key, id_):
    for i in items or []:
        if i.get(key) == id_:
            return i.get("label") or i.get("name") or id_
    return id_

MARK = {"working": "*", "blocked": "!", "done": "+", "idle": "-"}
for a in agents or []:
    ws = label(wss, "workspace_id", a.get("workspace_id"))
    tab = label(tabs, "tab_id", a.get("tab_id"))
    task = a.get("terminal_title_stripped") or ""
    mark = MARK.get(a.get("agent_status"), "?")
    pid = a.get("pane_id", "")
    print("%s %s > %s\t%s\t%s" % (mark, ws, tab, task, pid))
