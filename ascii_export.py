#!/usr/bin/env python3
"""Exportiert die Bilder des Repos als farblose ASCII-Art (.txt) nach ascii/.

Plain-Text ohne ANSI-Farben, damit die Bilder auch in Chat-/Markdown-Ausgaben
(Code-Fences) sauber rendern - im Gegensatz zu den jp2a --colors Shell-Storys.

    python3 ascii_export.py              # alle Szenen
    python3 ascii_export.py vegeta ssj1  # nur bestimmte Szenen
    python3 ascii_export.py --width 90   # schmaler
    python3 ascii_export.py --list       # Szenen auflisten

Szenen mit cut=True werden vorher per rembg (Modell isnet-anime) freigestellt,
damit unruhige Anime-Hintergründe nicht als Rauschen im ASCII landen. rembg ist
optional (siehe README); fehlt es, wird ohne Freistellen exportiert.
"""
import argparse
import os
import sys

from PIL import Image, ImageOps

RAMP = " .:-=+*#%@"
# Terminal-Zeichen sind etwa doppelt so hoch wie breit
CHAR_ASPECT = 0.5


def scene(src, caption, rows=32, crop=None, invert=False, cut=False, gamma=1.0, out=None):
    """crop = Ausschnitt als Anteil (l, t, r, b); invert = für dunkle Hintergründe;
    gamma > 1 hellt Mitteltöne auf, damit farbige Anime-Flächen (blauer Anzug) nicht
    als @-Block enden, schwarze Outlines aber dicht bleiben; gamma < 1 dunkelt ab, damit
    helle Partien (Super-Saiyajin-Haare, weiße Handschuhe) nicht zu Leerzeichen werden."""
    return dict(src=src, caption=caption, rows=rows, crop=crop, invert=invert, cut=cut, gamma=gamma, out=out)


LIFE = "images/life_of_vegeta"
LIFE_OUT = "life_of_vegeta"

# over9000_frames/frame_002..004 sind praktisch identisch mit frame_001 und
# vegeta_ssj1_attack.webp wird als ASCII nur Rauschen - beide bewusst nicht exportiert.
SCENES = {
    "over9000": scene("over9000_frames/frame_001.png", "IT'S OVER 9000!!!"),
    "vegeta": scene("vegeta.webp", "PRINCE OF ALL SAIYANS", rows=44),
    "ssj1": scene("vegeta_ssj1.webp", "SUPER SAIYAN VEGETA", rows=40, crop=(0.22, 0.08, 0.78, 0.92)),
    "final_flash": scene("vegeta_final_flash.png", "FINAL FLASH!!!", rows=36, crop=(0.58, 0.0, 1.0, 1.0), gamma=0.45),
    "explosion": scene("explosion.png", "*KABOOOM*", rows=24),

    # --- Life of Vegeta: Kindheit bis Majin-Saga. Bilder nicht im Repo -> erst python3 fetch_images.py ---
    # Hochformat-Szenen brauchen viele Zeilen (60-70), sonst werden sie zu schmal und Gesichter verschwinden.
    # Verworfen, weil als ASCII nicht erkennbar: Schwanz ab (Yajirobe), Trunks-Rage - Nappa: kein Bild im Wiki.
    "01_planet_vegeta": scene(f"{LIFE}/01_planet_vegeta.jpg", "AGE 737 - PLANET VEGETA IS DESTROYED",
                              rows=30, invert=True, crop=(0.12, 0.0, 0.88, 1.0), out=LIFE_OUT),
    "02_kid_prince": scene(f"{LIFE}/02_kid_prince.png", "THE PRINCE OF ALL SAIYANS",
                           rows=60, cut=True, crop=(0.16, 0.2, 0.53, 1.0), gamma=1.6, out=LIFE_OUT),
    "03_arrival_on_earth": scene(f"{LIFE}/03_arrival_on_earth.png", "AGE 762 - VEGETA LANDS ON EARTH",
                                 rows=36, crop=(0.4, 0.2, 1.0, 0.62), gamma=1.8, out=LIFE_OUT),
    "04_scouter": scene(f"{LIFE}/04_scouter.png", "SCOUTER CHECK", rows=28, gamma=1.8, out=LIFE_OUT),
    "05_galick_gun": scene(f"{LIFE}/05_galick_gun.jpg", "GALICK GUN!!!", rows=60, crop=(0.0, 0.0, 1.0, 0.96), invert=True,
                           out=LIFE_OUT),
    "06_great_ape": scene(f"{LIFE}/06_great_ape.png", "GREAT APE VEGETA", rows=56, cut=True, gamma=2.0,
                          out=LIFE_OUT),
    "07_namek_dragon_balls": scene(f"{LIFE}/07_namek_dragon_balls.jpg", "NAMEK - THE DRAGON BALLS ARE MINE!",
                                   rows=30, out=LIFE_OUT),
    "08_death_on_namek": scene(f"{LIFE}/08_death_on_namek.jpg", "\"KAKAROT ... DEFEAT FRIEZA.\"",
                               rows=60, crop=(0.38, 0.0, 0.72, 1.0), out=LIFE_OUT),
    "09_super_saiyan": scene(f"{LIFE}/09_super_saiyan.jpg", "SUPER SAIYAN - AT LAST", rows=70,
                             crop=(0.0, 0.0, 0.78, 1.0), out=LIFE_OUT),
    "10_big_bang_attack": scene(f"{LIFE}/10_big_bang_attack.jpg", "BIG BANG ATTACK!!!", rows=56, out=LIFE_OUT),
    "11_super_vegeta": scene(f"{LIFE}/11_super_vegeta.jpg", "SUPER VEGETA", rows=70, crop=(0.0, 0.0, 0.8, 1.0),
                             out=LIFE_OUT),
    "12_final_flash": scene("vegeta_final_flash.png", "FINAL FLASH!!!", rows=56, crop=(0.58, 0.0, 1.0, 1.0),
                            gamma=0.45, out=LIFE_OUT),
    "13_majin_vegeta": scene(f"{LIFE}/13_majin_vegeta.jpg", "MAJIN VEGETA", rows=60,
                             crop=(0.56, 0.36, 0.90, 0.665), out=LIFE_OUT),
    "14_final_explosion": scene(f"{LIFE}/14_final_explosion.png", "FINAL EXPLOSION - FOR BULMA AND TRUNKS",
                                rows=41, out=LIFE_OUT),
}

_session = None


def cut_out(im):
    """Hintergrund per rembg entfernen und auf die Figur zuschneiden."""
    global _session
    try:
        from rembg import new_session, remove
    except ImportError:
        print("  (rembg nicht installiert - exportiere ohne Freistellen)", file=sys.stderr)
        return im
    if _session is None:
        _session = new_session("isnet-anime")
    out = remove(im.convert("RGB"), session=_session)
    bbox = out.getchannel("A").point(lambda a: 255 if a > 32 else 0).getbbox()
    return out.crop(bbox) if bbox else out


def load_gray(path, sc):
    im = Image.open(path)
    if sc["crop"]:
        w, h = im.size
        l, t, r, b = sc["crop"]
        im = im.crop((int(l * w), int(t * h), int(r * w), int(b * h)))
    if sc["cut"]:
        im = cut_out(im)
    if im.mode in ("RGBA", "LA", "P"):
        im = im.convert("RGBA")
        bg = Image.new("RGBA", im.size, (255, 255, 255, 255))
        im = Image.alpha_composite(bg, im)
    im = ImageOps.autocontrast(im.convert("L"), cutoff=1)
    g = sc["gamma"]
    if g != 1.0:
        im = im.point(lambda v: int(255 - 255 * ((1 - v / 255) ** g)))
    return im


def to_ascii(im, width, invert, max_rows):
    w, h = im.size
    rows = max(1, int(h / w * width * CHAR_ASPECT))
    if max_rows and rows > max_rows:
        # zu hohe Bilder (Hochformat) schmaler rendern statt zu verzerren
        width = max(1, int(width * max_rows / rows))
        rows = max_rows
    im = im.resize((width, rows))
    px = im.load()
    n = len(RAMP) - 1
    lines = []
    for y in range(rows):
        line = ""
        for x in range(width):
            v = px[x, y] / 255
            if not invert:
                v = 1 - v  # hell = Leerzeichen, dunkel = dichtes Zeichen
            line += RAMP[round(v * n)]
        lines.append(line.rstrip())
    return lines


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--width", type=int, default=110)
    ap.add_argument("--max-rows", type=int, default=0, help="überschreibt die Zeilenzahl pro Szene")
    ap.add_argument("--out", default="ascii")
    ap.add_argument("--list", action="store_true", help="Szenen auflisten und beenden")
    ap.add_argument("names", nargs="*", help="nur diese Szenen (Default: alle)")
    args = ap.parse_args()

    if args.list:
        for name, sc in SCENES.items():
            print(f"{name:24} {sc['caption']}")
        return

    here = os.path.dirname(os.path.abspath(__file__))
    for name in args.names or SCENES:
        sc = SCENES[name]
        out = os.path.join(here, args.out, sc["out"] or "")
        os.makedirs(out, exist_ok=True)
        lines = to_ascii(load_gray(os.path.join(here, sc["src"]), sc), args.width, sc["invert"],
                         args.max_rows or sc["rows"])
        art_w = max(len(l) for l in lines)
        lines += ["", sc["caption"].center(art_w).rstrip()]
        with open(os.path.join(out, f"{name}.txt"), "w") as f:
            f.write("\n".join(lines) + "\n")
        print(f"{name:24} {art_w}x{len(lines)} <- {sc['src']}")


if __name__ == "__main__":
    main()
