import os, subprocess
from fontTools.ttLib import TTFont, TTCollection
OUT = os.path.expanduser('~/.local/share/fonts/tight'); os.makedirs(OUT, exist_ok=True)
def src(family, style): # system font file, wherever the distro puts it
    return subprocess.check_output(['fc-match', '-f', '%{file}', '%s:style=%s' % (family, style)]).decode()

def rename(f, old, new):
    for n in f['name'].names:
        s = n.toUnicode()
        if n.nameID in (1, 3, 4, 16, 18, 21): n.string = s.replace(old, new)
        elif n.nameID == 6: n.string = s.replace(old.replace(' ', ''), new.replace(' ', ''))
    if 'CFF ' in f:
        c = f['CFF '].cff; ps = c.fontNames[0].replace(old.replace(' ', ''), new.replace(' ', '')); c.fontNames[0] = ps
        td = c.topDictIndex[0]
        for a in ('FullName', 'FamilyName'):
            if hasattr(td, a): setattr(td, a, getattr(td, a).replace(old, new))
def vert(f, asc, desc):
    h, o = f['hhea'], f['OS/2']
    h.ascent, h.descent, h.lineGap = asc, -desc, 0
    o.sTypoAscender, o.sTypoDescender, o.sTypoLineGap, o.usWinAscent, o.usWinDescent = asc, -desc, 0, asc, desc
# Hack, 2048 upm: 13px -> ascent 12 + descent 3 = 15 (stock rounds to 13 + 4)
for st in ('Regular', 'Bold', 'Italic', 'BoldItalic'):
    f = TTFont(src('Hack', {'BoldItalic': 'Bold Italic'}.get(st, st)))
    vert(f, 1890, 472); rename(f, 'Hack', 'Hack Tight'); f.save('%s/HackTight-%s.ttf' % (OUT, st))
# Noto Sans Mono CJK SC, 1000 upm: same 12 + 3 at 13px, full-width advance 1000 -> 16/13 em = two 8px cells
for st in ('Regular', 'Bold'):
    for f in TTCollection(src('Noto Sans Mono CJK SC', st)).fonts:
        if f['name'].getDebugName(1) == 'Noto Sans Mono CJK SC': break
    vert(f, 920, 230); m = f['hmtx'].metrics
    for g, (adv, lsb) in m.items():
        if adv == 1000: m[g] = (1231, lsb)
    f['hhea'].advanceWidthMax = 1231
    rename(f, 'Noto Sans Mono CJK SC', 'Noto Mono CJK SC Tight'); f.save('%s/NotoMonoCJKscTight-%s.otf' % (OUT, st))
