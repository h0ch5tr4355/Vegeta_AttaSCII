#!/usr/bin/env python3
"""Lädt die Vorlagen der Life-of-Vegeta-Reihe aus dem Dragon Ball Wiki (Fandom).

Die Bilder sind urheberrechtlich geschützt und deshalb nicht im Repo - die Liste
(lokaler Dateiname -> Wiki-Datei) steht in images/life_of_vegeta/SOURCES.md.

    python3 fetch_images.py          # nur fehlende Bilder laden
    python3 fetch_images.py --force  # alle neu laden
"""
import argparse
import json
import os
import re
import urllib.parse
import urllib.request

DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "images", "life_of_vegeta")
API = "https://dragonball.fandom.com/api.php"
# Fandom blockt Requests ohne Browser-User-Agent mit 403
UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:130.0) Gecko/20100101 Firefox/130.0"
ROW = re.compile(r"^\| `([^`]+)` \| \[([^\]]+)\]\(")


def get(url):
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=60) as r:
        return r.read()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--force", action="store_true", help="vorhandene Bilder überschreiben")
    args = ap.parse_args()

    with open(os.path.join(DIR, "SOURCES.md")) as f:
        rows = [m.groups() for m in map(ROW.match, f) if m]
    todo = [(name, title) for name, title in rows
            if args.force or not os.path.exists(os.path.join(DIR, name))]
    if not todo:
        print("alle Bilder vorhanden")
        return

    q = urllib.parse.urlencode({
        "action": "query", "format": "json", "prop": "imageinfo", "iiprop": "url",
        "titles": "|".join("File:" + t for _, t in todo),
    })
    data = json.loads(get(f"{API}?{q}"))["query"]
    norm = {n["from"]: n["to"] for n in data.get("normalized", [])}
    urls = {p["title"]: p["imageinfo"][0]["url"] for p in data["pages"].values() if "imageinfo" in p}

    for name, title in todo:
        url = urls.get(norm.get("File:" + title, "File:" + title))
        if not url:
            print(f"FEHLT  {name}  (Wiki-Datei '{title}' nicht gefunden)")
            continue
        with open(os.path.join(DIR, name), "wb") as f:
            f.write(get(url))
        print(f"OK     {name}")


if __name__ == "__main__":
    main()
