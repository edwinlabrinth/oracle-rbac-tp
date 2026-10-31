#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Transforme un log texte (sortie RÉELLE de SQL*Plus) en image(s) PNG façon terminal
et génère screenshots/<nom>.tex (figures LaTeX prêtes à inclure avec \\shots{<nom>}).

Usage : python3 tools/shot.py logs/1_1.log "Exercice 1.1 -- Premier compte"

Ce ne sont PAS des captures d'écran : ce sont des rendus d'un log réel (mentionné en pied d'image).
"""
import os
import sys
import textwrap

from PIL import Image, ImageDraw, ImageFont

COLS, ROWS, SIZE = 120, 40, 15
BG, FG, ERR, DIM, BAR = (22, 22, 30), (212, 212, 212), (255, 107, 107), (130, 130, 150), (45, 45, 60)

TEX = {"\\": r"\textbackslash{}", "&": r"\&", "%": r"\%", "$": r"\$", "#": r"\#",
       "_": r"\_", "{": r"\{", "}": r"\}", "~": r"\textasciitilde{}", "^": r"\textasciicircum{}"}


def tex_escape(s):
    return "".join(TEX.get(c, c) for c in s)


def load_font():
    for p in ("/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf",
              "/usr/share/fonts/dejavu/DejaVuSansMono.ttf"):
        if os.path.exists(p):
            return ImageFont.truetype(p, SIZE)
    return ImageFont.load_default()


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    src = sys.argv[1]
    title = sys.argv[2] if len(sys.argv) > 2 else os.path.basename(src)
    name = os.path.splitext(os.path.basename(src))[0]
    os.makedirs("screenshots", exist_ok=True)

    with open(src, encoding="utf-8", errors="replace") as fh:
        raw = fh.read().expandtabs(4).splitlines()

    lines = []
    for r in raw:
        r = r.rstrip()
        lines += textwrap.wrap(r, COLS, drop_whitespace=False, replace_whitespace=False,
                               break_long_words=True) or [""]
    # nettoyage : pas de lignes vides en tête/queue, jamais plus de 2 vides de suite
    cleaned, blank = [], 0
    for ln in lines:
        blank = blank + 1 if ln.strip() == "" else 0
        if blank <= 2:
            cleaned.append(ln)
    while cleaned and cleaned[0].strip() == "":
        cleaned.pop(0)
    while cleaned and cleaned[-1].strip() == "":
        cleaned.pop()
    if not cleaned:
        cleaned = ["(log vide)"]

    pages = [cleaned[i:i + ROWS] for i in range(0, len(cleaned), ROWS)]
    font = load_font()
    cw = font.getlength("M") if hasattr(font, "getlength") else 9
    lh, pad, bar = SIZE + 5, 14, 34
    width = int(cw * COLS) + 2 * pad
    tex = []

    for n, page in enumerate(pages, 1):
        height = bar + 2 * pad + lh * len(page) + 20
        img = Image.new("RGB", (width, height), BG)
        d = ImageDraw.Draw(img)
        d.rectangle([0, 0, width, bar], fill=BAR)
        for i, c in enumerate(((255, 95, 86), (255, 189, 46), (39, 201, 63))):
            d.ellipse([pad + i * 20, 11, pad + i * 20 + 12, 23], fill=c)
        suffix = f" ({n}/{len(pages)})" if len(pages) > 1 else ""
        d.text((pad + 80, 9), f"{title}{suffix}", font=font, fill=FG)
        y = bar + pad
        for ln in page:
            is_err = any(k in ln for k in ("ORA-", "SP2-", "PLS-", "ERROR at line", "ERREUR"))
            d.text((pad, y), ln, font=font, fill=ERR if is_err else FG)
            y += lh
        pass
        out = f"screenshots/{name}_{n}.png"
        img.save(out)
        print("écrit", out)
        tex.append("\\begin{figure}[H]\\centering\n"
                   f"\\includegraphics[width=\\linewidth]{{{out}}}\n"
                   f"\\caption{{{tex_escape(title)}{tex_escape(suffix)}}}\n"
                   "\\end{figure}\n")

    with open(f"screenshots/{name}.tex", "w", encoding="utf-8") as fh:
        fh.write("\n".join(tex))
    print(f"écrit screenshots/{name}.tex  -> à inclure dans le rapport avec \\shots{{{name}}}")


if __name__ == "__main__":
    main()
