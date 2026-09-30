#!/usr/bin/env python3
"""Deterministic helpers for the obsidian-daily-note skill.

Lives at <vault>/.obsidian/scripts/daily_note.py (hidden from Obsidian's explorer).
Run on the Mac via device_bash:  python3 "$HOME/mnt/work/.obsidian/scripts/daily_note.py" <cmd> ...

Commands
  ensure [DATE]                 create 10-daily/DATE.md from the template if missing; print path
  prior-workday [DATE]          print the date of the most recent prior-workday note that exists
                                (Mon -> Fri; walks back up to 10 days)
  read DATE                     print the note
  set-section DATE HEADING PASS replace the <!-- claude:begin PASS --> ... <!-- claude:end PASS --> block
                                inside "## HEADING" with stdin; user text outside the block is kept.
                                PASS must match ^\\w+$; claude markers inside stdin are neutralized; aborts
                                without writing if the section has duplicate or unbalanced markers for PASS
  open-items DATE               print unchecked tasks (excluding ## Risks), filled "Today's three", and the
                                legacy Unspoken line
  carry-risks [DATE]            copy unticked `- [ ]` lines from the prior workday's ## Risks into DATE's ## Risks
                                (creating the heading under Today's three); runs once per note, marked by
                                `<!-- risks carried from YYYY-MM-DD -->`. `ensure` calls it automatically.
  promised [AS_OF]              scan all daily notes for unchecked `@promised YYYY-MM-DD` items due <= AS_OF
  meetings DATE                 print `- HH:MM - [[path|Title]]` for Granola + Wispr notes captured on DATE
  things-extract DATE [SECTION...]
                                JSON list of unchecked tasks in Open loops / Action items (plus legacy Carried over /
                                Promised today) not yet sent to Things: key, section, title, notes, deadline, tags
  things-mark DATE KEY...       record KEYs in the ledger (.obsidian/scripts/things-sync.json) and append ` ⇢things`
                                to the matching lines in the note
  things-url DATE               print a things:///add-json URL that creates all pending tasks (fallback when the
                                Things MCP server is unavailable)
  things-sent DATE              JSON of tasks in DATE's note already sent to Things (key, title, done_in_note)
  things-complete DATE KEY...   flip `- [ ]` -> `- [x]` on those lines (Things reported them completed)
  config                        print .obsidian/scripts/daily-note.local.json (Slack user id, EOD channels, Things
                                work area). Never committed; copy daily-note.local.example.json to create it.
                                Exits 1 with a message if the file is missing.

All dates are ISO (YYYY-MM-DD) in America/Denver. Never deletes user content.
All note and ledger writes are atomic (temp file in the same directory + os.replace).
"""
import datetime as dt
import hashlib
import json
import os
import re
import sys
import tempfile
import urllib.parse
from pathlib import Path

def _find_vault() -> Path:
    if os.environ.get("VAULT"):
        return Path(os.environ["VAULT"])
    p = Path(__file__).resolve()
    for anc in p.parents:
        if (anc / "10-daily").is_dir():
            return anc
    return p.parent.parent.parent  # <vault>/.obsidian/scripts/daily_note.py


VAULT = _find_vault()
DAILY = VAULT / "10-daily"
TEMPLATE = VAULT / "daily-note-template.md"
MEETING_DIRS = ["00-inbox/Granola", "00-inbox/Wispr"]
PLACEHOLDER = re.compile(r"^\s*<!--\s*(morning|evening) pass:.*?-->\s*$", re.M)
DATE_RX = re.compile(r"^\d{4}-\d{2}-\d{2}$")
PASS_RX = re.compile(r"^\w+$", re.A)
CLAUDE_MARKER = re.compile(r"<!--(\s*claude:(?:begin|end))", re.I)


def _die(msg: str, code: int = 2):
    print(msg, file=sys.stderr)
    sys.exit(code)


def _write(path: Path, text: str):
    """Atomic write: temp file in the same directory, then os.replace."""
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    try:
        mode = path.stat().st_mode & 0o777
    except FileNotFoundError:
        mode = 0o644
    fd, tmp = tempfile.mkstemp(dir=str(path.parent), prefix=f".{path.name}.", suffix=".tmp")
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as fh:
            fh.write(text)
            fh.flush()
            os.fsync(fh.fileno())
        os.chmod(tmp, mode)
        os.replace(tmp, path)
    except BaseException:
        try:
            os.unlink(tmp)
        except FileNotFoundError:
            pass
        raise


def today() -> dt.date:
    # Denver local date; device_bash runs in the user's local VM (its TZ may be UTC).
    try:
        from zoneinfo import ZoneInfo
        return dt.datetime.now(ZoneInfo("America/Denver")).date()
    except Exception:
        return dt.date.today()


def parse(d: str | None) -> dt.date:
    if not d:
        return today()
    if not DATE_RX.match(d):
        _die(f"invalid date {d!r}: expected YYYY-MM-DD")
    try:
        return dt.date.fromisoformat(d)
    except ValueError:
        _die(f"invalid date {d!r}: not a calendar date")


def note_path(d: dt.date) -> Path:
    return DAILY / f"{d.isoformat()}.md"


def render_template(d: dt.date) -> str:
    txt = TEMPLATE.read_text()
    fmt = {
        "YYYY-MM-DD": d.isoformat(),
        "dddd": d.strftime("%A"),
        "dddd, MMMM D": f"{d.strftime('%A, %B')} {d.day}",
        "MMMM D": f"{d.strftime('%B')} {d.day}",
    }

    def sub(m):
        spec = m.group(1)
        if spec in fmt:
            return fmt[spec]
        # generic moment-ish fallback
        out = spec
        for k, v in (("YYYY", "%Y"), ("MM", "%m"), ("DD", "%d"), ("dddd", "%A"), ("MMMM", "%B"), ("ddd", "%a"), ("MMM", "%b")):
            out = out.replace(k, d.strftime(v))
        return out.replace("D", str(d.day))

    txt = re.sub(r"\{\{date:([^}]+)\}\}", sub, txt)
    txt = txt.replace("{{date}}", d.isoformat()).replace("{{title}}", d.isoformat())
    return txt


def cmd_ensure(args):
    d = parse(args[0] if args else None)
    p = note_path(d)
    if not p.exists():
        DAILY.mkdir(parents=True, exist_ok=True)
        _write(p, render_template(d))
        print(f"created {p}")
    else:
        print(f"exists {p}")
    if d == today():
        cmd_carry_risks([d.isoformat()])


RISKS_HEAD = "## Risks"
RISK_OPEN = re.compile(r"^\s*- \[ \]\s+\S")


def _risk_lines(text: str):
    """Unticked risk lines from a note's ## Risks section."""
    for h, body in split_sections(text):
        if h and h.strip().lower() == RISKS_HEAD.lower():
            return [ln.rstrip() for ln in body if RISK_OPEN.match(ln)]
    return []


def _prior_workday(d: dt.date) -> dt.date:
    import io, contextlib
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        cmd_prior_workday([d.isoformat()])
    return dt.date.fromisoformat(buf.getvalue().strip())


def cmd_carry_risks(args):
    d = parse(args[0] if args else None)
    p = note_path(d)
    if not p.exists():
        print(f"(no note for {d})")
        return
    text = p.read_text()
    if "<!-- risks carried from " in text:
        print("risks already carried")
        return
    prior = _prior_workday(d)
    pp = note_path(prior)
    carried = _risk_lines(pp.read_text()) if pp.exists() else []
    label = f"{prior.strftime('%a')} {prior.month}/{prior.day}"
    out_lines = []
    for ln in carried:
        # stamp the first day a risk was carried so its age stays visible
        out_lines.append(ln if "(since " in ln else f"{ln} (since {label})")
    secs = split_sections(text)
    idx = next((i for i, (h, _) in enumerate(secs) if h and h.strip().lower() == RISKS_HEAD.lower()), None)
    if idx is None:
        after = next((i for i, (h, _) in enumerate(secs) if h and h[3:].lower().startswith("today's three")), None)
        if after is None:
            after = next((i for i, (h, _) in enumerate(secs) if h and h[3:].lower().startswith("action items")), len(secs)) - 1
        secs.insert(after + 1, (RISKS_HEAD, [""]))
        idx = after + 1
    h, body = secs[idx]
    have = {_norm(re.sub(r"\s*\(since [^)]*\)\s*$", "", ln)) for ln in body if RISK_OPEN.match(ln)}
    new = [ln for ln in out_lines if _norm(re.sub(r"\s*\(since [^)]*\)\s*$", "", ln)) not in have]
    kept = [ln for ln in body]
    while kept and not kept[-1].strip():
        kept.pop()
    kept = kept + new + [f"<!-- risks carried from {prior.isoformat()} -->", ""]
    if kept and kept[0].strip():
        kept = kept  # heading line is followed directly by content
    secs[idx] = (h, kept)
    rebuilt = []
    for hh, bb in secs:
        if hh is not None:
            rebuilt.append(hh)
        rebuilt.extend(bb)
    _write(p, "\n".join(rebuilt).rstrip("\n") + "\n")
    print(f"carried {len(new)} risk(s) from {prior.isoformat()} into {p.name}")


def cmd_prior_workday(args):
    d = parse(args[0] if args else None)
    cur = d
    for _ in range(10):
        cur -= dt.timedelta(days=1)
        if cur.weekday() >= 5:  # Sat/Sun
            continue
        if note_path(cur).exists():
            print(cur.isoformat())
            return
    # nothing found: still report the nominal prior workday
    cur = d - dt.timedelta(days=3 if d.weekday() == 0 else 1)
    print(cur.isoformat())


def cmd_read(args):
    print(note_path(parse(args[0] if args else None)).read_text())


def split_sections(text: str):
    """Return list of (heading_line_or_None, body_lines). Only '## ' headings split."""
    lines = text.splitlines()
    out, cur_head, cur = [], None, []
    for ln in lines:
        if ln.startswith("## "):
            out.append((cur_head, cur))
            cur_head, cur = ln, []
        else:
            cur.append(ln)
    out.append((cur_head, cur))
    return out


def cmd_set_section(args):
    if len(args) < 3:
        _die("usage: set-section DATE HEADING PASS  (content on stdin)")
    d, heading, pas = parse(args[0]), args[1].strip(), args[2].strip()
    if not PASS_RX.match(pas):
        _die(f"invalid PASS {pas!r}: must match ^\\w+$")
    content = sys.stdin.read().rstrip("\n")
    # content is data: it must never be able to open or close a claude block
    content = CLAUDE_MARKER.sub(r"&lt;!--\1", content)
    p = note_path(d)
    if not p.exists():
        cmd_ensure([d.isoformat()])
    text = p.read_text()
    begin, end = f"<!-- claude:begin {pas} -->", f"<!-- claude:end {pas} -->"
    try:
        from zoneinfo import ZoneInfo
        stamp = dt.datetime.now(ZoneInfo("America/Denver")).strftime("%H:%M")
    except Exception:
        stamp = dt.datetime.now().strftime("%H:%M")
    block = f"{begin}\n{content}\n<!-- updated {d.isoformat()} {stamp} -->\n{end}" if content else ""
    secs = split_sections(text)
    target = None
    for i, (h, body) in enumerate(secs):
        if h and re.sub(r"\s+", " ", h[3:]).strip().lower().startswith(heading.lower()):
            target = i
            break
    if target is None:
        # insert new section before "## Ledger" if present, else append
        new = (f"## {heading}", [])
        idx = next((i for i, (h, _) in enumerate(secs) if h and h[3:].lower().startswith("ledger")), None)
        if idx is None:
            secs.append(new)
            target = len(secs) - 1
        else:
            secs.insert(idx, new)
            target = idx
    h, body = secs[target]
    joined = "\n".join(body)
    n_begin, n_end = joined.count(begin), joined.count(end)
    if n_begin > 1 or n_end > 1 or n_begin != n_end:
        _die(f"refusing to write: section '{heading}' has {n_begin} begin / {n_end} end markers for PASS '{pas}'"
             " (expected one balanced pair or none); fix the note by hand", 3)
    joined = PLACEHOLDER.sub("", joined)
    pat = re.compile(re.escape(begin) + r".*?" + re.escape(end) + r"\n?", re.S)
    if pat.search(joined):
        joined = pat.sub(lambda _m: block + ("\n" if block else ""), joined, count=1)
    else:
        # place block right after the heading, keep user lines after it
        joined = (block + "\n" if block else "") + joined.lstrip("\n")
    # keep a blank line after the claude block so any user text below stays visually separate
    joined = re.sub(r"(<!-- claude:end \w+ -->)\n(?!\n)", r"\1\n\n", joined)
    joined = re.sub(r"\n{3,}", "\n\n", joined).rstrip("\n") + "\n\n"
    secs[target] = (h, joined.splitlines())
    rebuilt = []
    for hh, bb in secs:
        if hh is not None:
            rebuilt.append(hh)
        rebuilt.extend(bb)
    out = "\n".join(rebuilt).rstrip("\n") + "\n"
    _write(p, out)
    print(f"wrote section '{heading}' ({pas}) in {p.name}")


def cmd_open_items(args):
    d = parse(args[0] if args else None)
    p = note_path(d)
    if not p.exists():
        print(f"(no note for {d})")
        return
    text = p.read_text()
    print(f"# open items from {p.name}")
    in_risks = False
    for ln in text.splitlines():
        if ln.startswith("## "):
            in_risks = ln.strip().lower() == RISKS_HEAD.lower()
            continue
        s = ln.strip()
        if in_risks:
            continue  # risks carry via carry-risks, never as tasks
        if s.startswith("- [ ]") and "every \"I'll\" from today" not in s:
            print(ln)
    m = re.search(r"^## Today's three\n(.*?)(?=^## |\Z)", text, re.S | re.M)
    if m:
        for ln in m.group(1).splitlines():
            if re.match(r"^\s*\d+\.\s*\S", ln) and not re.search(r"\b(done|✓|✅)\b", ln):
                print(f"- [ ] {ln.strip()[3:].strip()}  (Today's three)")
    m = re.search(r"^- Unspoken → goes in tomorrow's post:[ \t]*(\S.*)$", text, re.M)
    if m:
        print(f"- Unspoken → tomorrow's post: {m.group(1).strip()}")


def cmd_promised(args):
    as_of = parse(args[0] if args else None)
    rx = re.compile(r"@promised\s+(\d{4}-\d{2}-\d{2})")
    for p in sorted(DAILY.glob("*.md")):
        in_risks = False
        for ln in p.read_text().splitlines():
            if ln.startswith("## "):
                in_risks = ln.strip().lower() == RISKS_HEAD.lower()
                continue
            if in_risks:
                continue
            if "- [ ]" in ln:
                m = rx.search(ln)
                if m:
                    try:
                        due = dt.date.fromisoformat(m.group(1))
                    except ValueError:
                        continue
                    if due <= as_of:
                        print(f"{p.stem}\t{ln.strip()}")


def _local_start(p: Path):
    """(local_date_iso, 'HH:MM') for a meeting note.

    Granola names files with local time; Wispr Flow Sync names them with UTC. So prefer the
    `created:` ISO timestamp in frontmatter (UTC, 'Z') converted to America/Denver, and fall
    back to the filename tokens.
    """
    head = p.read_text(errors="ignore")[:2000]
    fm = re.search(r"^created:\s*(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?)(Z|[+-]\d{2}:\d{2})?\s*$", head, re.M)
    if fm:
        try:
            from zoneinfo import ZoneInfo
            iso = fm.group(1) + ("+00:00" if fm.group(2) in (None, "Z") else fm.group(2))
            dtv = dt.datetime.fromisoformat(iso).astimezone(ZoneInfo("America/Denver"))
            return dtv.date().isoformat(), dtv.strftime("%H:%M")
        except Exception:
            pass
    m = re.search(r",(\d{4}-\d{2}-\d{2}),(\d{2})-(\d{2})-\d{2}", p.name)
    if m:
        return m.group(1), f"{m.group(2)}:{m.group(3)}"
    return None, "??:??"


def cmd_meetings(args):
    d = parse(args[0] if args else None)
    wanted = d.isoformat()
    nxt = (d + dt.timedelta(days=1)).isoformat()
    rows = []
    for rel in MEETING_DIRS:
        folder = VAULT / rel
        if not folder.exists():
            continue
        # a UTC-named file for a Denver evening meeting carries the next day's date
        cands = list(folder.glob(f"*,{wanted},*.md")) + list(folder.glob(f"*,{nxt},*.md"))
        for p in cands:
            local_date, hhmm = _local_start(p)
            if local_date != wanted:
                continue
            title = p.stem.split(",")[0]
            fm = re.search(r"^title:\s*(.+)$", p.read_text(errors="ignore")[:2000], re.M)
            if fm:
                title = fm.group(1).strip().strip('"')
            rows.append((hhmm, f"- {hhmm} - [[{rel}/{p.stem}|{title}]]"))
    for _, line in sorted(set(rows)):
        print(line)


# ---------------------------------------------------------------- Things 3 bridge

# "Open loops" is the current morning section; "Carried over"/"Promised today" are kept for notes written before 2026-09-29.
THINGS_SECTIONS = ["Open loops", "Carried over", "Promised today", "Action items"]
LEDGER = VAULT / ".obsidian" / "scripts" / "things-sync.json"
LOCAL_CONFIG = VAULT / ".obsidian" / "scripts" / "daily-note.local.json"
SENT_MARK = "⇢things"
VAULT_NAME = VAULT.name


def _load_ledger() -> dict:
    try:
        return json.loads(LEDGER.read_text())
    except Exception:
        return {}


def _save_ledger(d: dict):
    _write(LEDGER, json.dumps(d, indent=1, ensure_ascii=False) + "\n")


def _norm(s: str) -> str:
    return re.sub(r"\s+", " ", s.lower()).strip()


def parse_task_line(line: str, section: str, d: dt.date) -> dict | None:
    """Turn a `- [ ] …` line from a claude section into a Things payload."""
    m = re.match(r"^\s*- \[ \]\s+(.*)$", line)
    if not m:
        return None
    body = m.group(1).strip()
    if SENT_MARK in body:
        return None
    body = body.replace(SENT_MARK, "").strip()
    deadline = None
    dm = re.search(r"@promised\s+(\d{4}-\d{2}-\d{2})", body)
    if dm:
        deadline = dm.group(1)
    body = re.sub(r"@promised\s+\d{4}-\d{2}-\d{2}", "", body)
    flags = re.findall(r"\((overdue from [^)]+|date assumed|undated)\)", body)
    body = re.sub(r"\((overdue from [^)]+|date assumed|undated)\)", "", body)
    body = re.sub(r"\s{2,}", " ", body).strip(" ,")
    parts = [p.strip() for p in re.split(r"\s+[—–]\s+", body) if p.strip()]
    item = parts[0] if parts else body
    person, meeting, carried_from = None, None, None
    for tail in parts[1:]:
        t = tail
        pm = re.match(r"^to\s+(.+?)(?:,\s*said\b.*)?$", t)
        if pm:
            person = pm.group(1).strip()
            continue
        fm = re.match(r"^from\s+\[\[([^\]|]+)(?:\|([^\]]+))?\]\]", t)
        if fm:
            carried_from = fm.group(2) or fm.group(1)
            continue
        lm = re.match(r"^\[\[([^\]|]+)(?:\|([^\]]+))?\]\]", t)
        if lm:
            meeting = (lm.group(2) or lm.group(1)).strip()
            continue
    item = re.sub(r"\[\[([^\]|]+)\|([^\]]+)\]\]", r"\2", item)
    item = re.sub(r"\[\[([^\]]+)\]\]", r"\1", item)
    item = item.strip().rstrip(".")
    if not item:
        return None
    # The key is derived from the *raw* title (pre-2026-09-29 parsing) so ledger entries stay stable.
    raw_title = item if not person else f"{item} — {person}"
    key = hashlib.sha1(_norm(raw_title).encode()).hexdigest()[:12]
    # Clean what Things sees: move markdown links out of the title, drop trailing clock times.
    links = re.findall(r"\[[^\]]*\]\((https?://[^)\s]+)\)", raw_title)
    clean_person = None
    if person:
        clean_person = re.sub(r"\[[^\]]*\]\([^)]*\)", "", person)
        clean_person = re.split(r",\s*|\s+(?=#)", clean_person)[0]          # "Alex, #team …" -> "Alex"
        clean_person = re.sub(r"\s*\b\d{1,2}:\d{2}(?:[–-]\d{1,2}:\d{2})?\b", "", clean_person).strip(" ,")
    clean_item = re.sub(r"\[[^\]]*\]\([^)]*\)", "", item).strip()
    title = clean_item if not clean_person else f"{clean_item} — {clean_person}"
    obsidian = f"obsidian://open?vault={urllib.parse.quote(VAULT_NAME)}&file={urllib.parse.quote('10-daily/' + d.isoformat())}"
    notes = [f"From {section} · daily note {d.isoformat()}"]
    if person and person != clean_person:
        ctx = re.sub(r"\[[^\]]*\]\([^)]*\)", "", person).strip()
        notes.append("Context: " + ctx)
    if meeting:
        notes.append(f"Meeting: {meeting}")
    if carried_from:
        notes.append(f"Carried from {carried_from}")
    if flags:
        notes.append("Flags: " + ", ".join(flags))
    for u in links:
        notes.append(f"Source: {u}")
    notes.append(obsidian)
    # Stable reference that survives renaming the to-do in Things; the evening pass searches for it.
    notes.append(f"ref: dn-{key}")
    tags = ["@promised"] if (deadline or person) else []
    return {
        "key": key,
        "section": section,
        "title": title,
        "notes": "\n".join(notes),
        "deadline": deadline,
        "tags": tags,
        "line": line.rstrip("\n"),
    }


def _claude_task_lines(text: str, sections):
    """Yield (section, line) for task lines inside the chosen ## sections (claude block or not)."""
    for h, body in split_sections(text):
        if not h:
            continue
        name = h[3:].strip()
        sec = next((s for s in sections if name.lower().startswith(s.lower())), None)
        if not sec:
            continue
        for ln in body:
            if ln.lstrip().startswith("- [ ]"):
                yield sec, ln


def cmd_things_extract(args):
    d = parse(args[0] if args else None)
    sections = args[1:] or THINGS_SECTIONS
    p = note_path(d)
    if not p.exists():
        print("[]")
        return
    ledger = _load_ledger()
    out, seen = [], set()
    for sec, ln in _claude_task_lines(p.read_text(), sections):
        t = parse_task_line(ln, sec, d)
        if not t or t["key"] in ledger or t["key"] in seen:
            continue
        seen.add(t["key"])
        out.append(t)
    print(json.dumps(out, indent=1, ensure_ascii=False))


def cmd_things_mark(args):
    d = parse(args[0] if args else None)
    keys = set(args[1:])
    if not keys:
        print("no keys given")
        return
    p = note_path(d)
    text = p.read_text()
    ledger = _load_ledger()
    now = dt.datetime.now().isoformat(timespec="seconds")
    lines = text.splitlines()
    marked = 0
    for sec, ln in _claude_task_lines(text, THINGS_SECTIONS):
        t = parse_task_line(ln, sec, d)
        if t and t["key"] in keys:
            ledger[t["key"]] = {"title": t["title"], "date": d.isoformat(), "sent_at": now}
            for i, cur in enumerate(lines):
                if cur == ln and SENT_MARK not in cur:
                    lines[i] = cur.rstrip() + f" {SENT_MARK}"
                    marked += 1
                    break
    _save_ledger(ledger)
    _write(p, "\n".join(lines).rstrip("\n") + "\n")
    print(f"marked {marked} line(s); ledger now {len(ledger)} entries")


def cmd_things_sent(args):
    """List tasks from DATE's note that were already sent to Things (ledger), with current checkbox state."""
    d = parse(args[0] if args else None)
    p = note_path(d)
    if not p.exists():
        print("[]")
        return
    ledger = _load_ledger()
    out = []
    for h, body in split_sections(p.read_text()):
        if not h:
            continue
        name = h[3:].strip()
        sec = next((s for s in THINGS_SECTIONS if name.lower().startswith(s.lower())), None)
        if not sec:
            continue
        for ln in body:
            m = re.match(r"^\s*- \[( |x|X)\]\s+(.*)$", ln)
            if not m:
                continue
            probe = "- [ ] " + m.group(2).replace(SENT_MARK, "").strip()
            t = parse_task_line(probe, sec, d)
            if t and t["key"] in ledger:
                out.append({"key": t["key"], "ref": f"dn-{t['key']}", "title": t["title"], "section": sec,
                            "done_in_note": m.group(1).lower() == "x", "line": ln.rstrip("\n")})
    print(json.dumps(out, indent=1, ensure_ascii=False))


def cmd_things_complete(args):
    """Flip `- [ ]` to `- [x]` for the given KEYs in DATE's note (Things reported them completed)."""
    d = parse(args[0] if args else None)
    keys = set(args[1:])
    p = note_path(d)
    text = p.read_text()
    lines = text.splitlines()
    flipped = 0
    for i, ln in enumerate(lines):
        m = re.match(r"^(\s*)- \[ \]\s+(.*)$", ln)
        if not m:
            continue
        probe = "- [ ] " + m.group(2).replace(SENT_MARK, "").strip()
        t = parse_task_line(probe, "x", d)
        if t and t["key"] in keys:
            lines[i] = ln.replace("- [ ]", "- [x]", 1)
            flipped += 1
    _write(p, "\n".join(lines).rstrip("\n") + "\n")
    print(f"marked {flipped} line(s) done")


def cmd_things_url(args):
    d = parse(args[0] if args else None)
    import io, contextlib
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        cmd_things_extract([d.isoformat()])
    tasks = json.loads(buf.getvalue() or "[]")
    items = []
    for t in tasks:
        it = {"type": "to-do", "attributes": {"title": t["title"], "notes": t["notes"], "tags": t["tags"]}}
        if t["deadline"]:
            it["attributes"]["deadline"] = t["deadline"]
        items.append(it)
    if not items:
        print("")
        return
    data = urllib.parse.quote(json.dumps(items, ensure_ascii=False), safe="")
    print(f"things:///add-json?data={data}")


def cmd_config(args):
    """Print the vault-local, never-committed engagement config."""
    try:
        cfg = json.loads(LOCAL_CONFIG.read_text())
    except FileNotFoundError:
        _die(f"missing {LOCAL_CONFIG}\n"
             "copy daily-note.local.example.json to daily-note.local.json in that folder and fill in the values "
             "(or run `task daily-note:vault`, which seeds the example copy)", 1)
    except ValueError as e:
        _die(f"{LOCAL_CONFIG} is not valid JSON: {e}", 1)
    print(json.dumps(cfg, indent=2, ensure_ascii=False))


CMDS = {
    "things-extract": cmd_things_extract,
    "things-mark": cmd_things_mark,
    "things-url": cmd_things_url,
    "things-sent": cmd_things_sent,
    "things-complete": cmd_things_complete,
    "ensure": cmd_ensure,
    "prior-workday": cmd_prior_workday,
    "read": cmd_read,
    "set-section": cmd_set_section,
    "open-items": cmd_open_items,
    "carry-risks": cmd_carry_risks,
    "promised": cmd_promised,
    "meetings": cmd_meetings,
    "config": cmd_config,
}

if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] not in CMDS:
        print(__doc__)
        sys.exit(2)
    CMDS[sys.argv[1]](sys.argv[2:])
