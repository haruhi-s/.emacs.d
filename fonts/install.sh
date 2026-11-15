#!/bin/sh
# Make Emacs' text grid match Konsole's (8x15 px cells at 13 px, CJK exactly 2 cells wide and as tall as Latin).
# Run once on a new machine; init.el then uses "Hack Tight" + "Noto Mono CJK SC Tight" + FreeMono.
# Needs (Debian/Ubuntu): fonts-hack fonts-noto-cjk fonts-freefont-ttf python3-fonttools
# The numbers assume a 13 px font (:height 90 at ~107 DPI); at another size CJK is no longer 2 cells wide.
set -e
cd "$(dirname "$0")"
python3 -c 'import fontTools' 2>/dev/null || { echo "missing: python3-fonttools"; exit 1; }
for f in "Hack" "Noto Sans Mono CJK SC" "FreeMono"; do
    [ "$(fc-match -f '%{family[0]}' "$f")" = "$f" ] || { echo "missing font: $f"; exit 1; }
done
python3 mkfont.py                 # -> ~/.local/share/fonts/tight
fc-cache -f ~/.local/share/fonts
# launcher: FREETYPE_PROPERTIES=cff:no-stem-darkening=0 makes CJK strokes as heavy as in Qt apps;
# it must be in the environment before Emacs starts (setenv in early-init.el is too late)
mkdir -p ~/.local/share/applications
cp emacs.desktop ~/.local/share/applications/emacs.desktop
fc-list | grep -c "fonts/tight" | xargs echo "installed tight fonts:"
