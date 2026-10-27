# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Inhaltliche Grenze

**Nur Vegeta, nur Original-Dragon-Ball-Z: Saiyajin-Saga bis einschließlich Majin-Buu-Saga.** Kein Dragon Ball Super/GT, keine späteren Formen (Super Saiyajin God/Blue, Ultra Ego), keine Fusionen (Vegito, Gogeta). Entscheidend ist das Motiv, nicht die Quelle: Ein Spiele-Artwork (z.B. *Sparking! Zero*) ist ok, solange es eine DBZ-Szene oder -Form zeigt.

## Zwei getrennte Welten

1. **Farbige Terminal-Storys** (`vegeta_over9000.sh`, `vegeta_final_flash.sh`, `vegeta_aura.sh`, `vegeta_test.sh`, `jp2a.sh`): Bash + `jp2a --colors` (+ `bc`, `tput`), mit Animation und ANSI-Farben. `vegeta_over9000.sh`, `vegeta_aura.sh` und `vegeta_test.sh` haben absolute macOS-Pfade (`/Users/.../Vegeta/...`) fest eingebaut und laufen nur dort; `vegeta_final_flash.sh` ist reine handgezeichnete ASCII-Art ohne Bilddateien.
2. **Plain-ASCII-Export** (`ascii_export.py`): farblose `.txt` für Chat/Markdown-Code-Fences. Das ist der aktiv gepflegte Teil.

## Plain-ASCII-Export

```sh
python3 ascii_export.py --list                              # Szenen + Captions
python3 ascii_export.py <name> [<name> ...]                 # einzelne Szenen neu erzeugen
python3 ascii_export.py                                     # alle
python3 ascii_export.py --width 70 --out ascii/narrow <name>  # schmale Fassung
.venv/bin/python ascii_export.py <name>                     # Szenen mit cut=... (braucht rembg aus dem venv)
python3 fetch_images.py [--force]                           # fehlende Vorlagen (images/*/SOURCES.md) aus dem Wiki laden
```

Setup venv: `python3 -m venv .venv && .venv/bin/pip install "rembg[cpu]" pillow` (rembg lädt beim ersten Lauf das Modell `isnet-anime`, ~176 MB). Ohne rembg wird still ohne Freistellen exportiert, das Ergebnis sieht dann anders aus. Es gibt keine Tests; geprüft wird, indem man die erzeugte `.txt` ansieht.

**Pipeline:** Jede Szene ist ein Eintrag in `SCENES` (Helper `scene(...)`), über `out=` landet sie in einem Unterordner von `ascii/`. `load_gray` macht crop → `cut` (rembg, Modell `isnet-anime`) → Alpha auf Weiß → Graustufen → Autokontrast → `gamma`. `to_ascii` mappt auf `RAMP` mit `CHAR_ASPECT = 0.5`; ist ein Bild höher als `rows`, wird es schmaler statt verzerrt. Darunter steht die zentrierte Caption.

**Tuning-Erfahrung** (Details als Kommentare in `SCENES` und im `scene()`-Docstring):
- Freigestellte Renders mit flachen Farben funktionieren am besten.
- Manga-Seiten mit Schraffur, Multi-Panel-Seiten und Screenshots mit Glow-Effekten werden zu Rauschen.
- `gamma > 1` für farbige Flächen, `< 1` für helle Haare/Handschuhe.
- Hochformat braucht `rows` 60–70.
- Verworfene Motive stehen als Kommentar über dem jeweiligen Block, damit sie nicht erneut probiert werden.

## Ordner unter `ascii/` und wer sie liest

Hauptverbraucher ist der `/finish`-Skill (Game of Claude). Er liest die Dateien **direkt aus diesem Klon** und gibt sie unverändert in einem ```` ```text ````-Fence aus. Deshalb gilt: reines ASCII, keine ANSI-Codes, Zeilen ohne Trailing-Whitespace.

- `ascii/*.txt` (oberste Ebene) = Sieges-Pool. Jede neue Datei dort ist sofort im Zufallspool. `over9000` ist für Session-Score 9–10 reserviert.
- `ascii/narrow/<name>.txt` = 70-Spalten-Fassung. `/finish` nimmt sie, wenn der Chat unter 112 Spalten breit ist. Jedes Bild auf oberster Ebene, das breiter als ~57 Spalten ist, braucht eine.
- `ascii/life_of_vegeta/NN_*.txt` = chronologische Reihe (Kindheit bis Majin-Saga), von `/finish` noch nicht genutzt (im Review). `12_final_flash` verwendet `vegeta_final_flash.png` aus dem Root.

## Bildquellen und Urheberrecht

Die älteren Root-Bilder (`vegeta.webp`, `explosion.png`, …) sind eingecheckt. Neuere Vorlagen sind urheberrechtlich geschützt und git-ignoriert: `images/life_of_vegeta/*` (Life-Reihe) und `images/victory/*` (neuere Bilder des Sieges-Pools). Eingecheckt ist je Ordner nur `SOURCES.md`; `fetch_images.py` parst die Tabellenzeilen aller `images/*/SOURCES.md` (`` | `datei` | [Wiki-Datei](url) | ``) und lädt per MediaWiki-API von `dragonball.fandom.com`. Ohne Browser-User-Agent antwortet Fandom mit 403. Neue Vorlagen kommen in die Tabelle plus ein Ignore-Paar in `.gitignore`, nicht ins Repo.

## Repo-Identität

Öffentliches Repo `github.com/h0ch5tr4355/Vegeta_AttaSCII` unter OSS-Pseudonym. Keine Klarnamen oder Arbeitgeber-Bezüge in Inhalt oder Commit-Metadaten.
