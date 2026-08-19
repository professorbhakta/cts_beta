import re
import sys

path = sys.argv[1] if len(sys.argv) > 1 else r"d:\cts_beta\qa_lab\m3_emu_dash.xml"
filt = sys.argv[2].lower() if len(sys.argv) > 2 else ""
raw = open(path, encoding="utf-8").read()
print(f"len={len(raw)}")
for m in re.finditer(r"<node [^>]*?>", raw):
    n = m.group(0)
    desc = re.search(r'content-desc="([^"]*)"', n)
    text = re.search(r' text="([^"]*)"', n)
    bounds = re.search(r'bounds="([^"]*)"', n)
    click = 'clickable="true"' in n
    d = desc.group(1) if desc else ""
    t = text.group(1) if text else ""
    b = bounds.group(1) if bounds else ""
    line = f"{b:28} | click={str(click):5} | {d[:70]:70} | {t[:40]}"
    if filt:
        if filt in line.lower():
            print(line)
    elif d or t:
        print(line)
