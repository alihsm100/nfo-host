#!/bin/bash
# =====================================================================
#  Notfallordner auf GitHub Pages aktualisieren
#
#  Doppelklick genuegt. Das Skript holt die aktuelle Datei aus dem Vault,
#  setzt die beiden Suchmaschinen-Sperren wieder ein und veroeffentlicht.
#
#  Es aendert NICHTS im Vault - dort wird nur gelesen.
# =====================================================================
cd "$(dirname "$0")" || exit 1
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

QUELLE="${NFO_QUELLE:-$HOME/tecis/html/tecis_Notfallordner.html}"

echo ""
echo "  Notfallordner -> GitHub Pages"
echo "  ============================="
echo ""

fehler() { echo ""; echo "  ABBRUCH: $1"; echo ""; read -n1 -r -p "  Taste druecken zum Schliessen..."; echo ""; exit 1; }

[ -f "$QUELLE" ] || fehler "Quelldatei nicht gefunden: $QUELLE"
[ -s "$QUELLE" ] || fehler "Quelldatei ist leer: $QUELLE"
command -v git >/dev/null || fehler "git ist nicht installiert."

echo "  Quelle: $QUELLE"
echo "          $(wc -c < "$QUELLE" | tr -d ' ') Bytes, geaendert $(date -r "$QUELLE" '+%d.%m.%Y %H:%M')"
echo ""

python3 - "$QUELLE" <<'PY' || fehler "Die Datei konnte nicht vorbereitet werden."
import sys, hashlib
from pathlib import Path

quelle = Path(sys.argv[1])
ziel = Path("index.html")

META = b'  <meta name="robots" content="noindex, nofollow, noarchive">\n'
WACHE = (
b'  <script>/* Das Bundle baut den <head> beim Start neu auf und wirft die noindex-Zeile\n'
b'     dabei weg. Damit die Sperre auch in der gerenderten Seite steht (Suchmaschinen\n'
b'     rendern JavaScript), wird sie hier bei Bedarf wieder eingehaengt. */\n'
b'  (function () {\n'
b'    function setzen() {\n'
b'      if (document.querySelector(\'meta[name="robots"]\')) return;\n'
b'      var m = document.createElement("meta");\n'
b'      m.setAttribute("name", "robots");\n'
b'      m.setAttribute("content", "noindex, nofollow, noarchive");\n'
b'      (document.head || document.documentElement).appendChild(m);\n'
b'    }\n'
b'    setzen();\n'
b'    document.addEventListener("DOMContentLoaded", setzen);\n'
b'    window.addEventListener("load", setzen);\n'
b'    /* Nur auf den Austausch von <head>/<body> horchen, nicht auf den Seiteninhalt. */\n'
b'    if (typeof MutationObserver === "function") {\n'
b'      new MutationObserver(setzen).observe(document.documentElement, { childList: true });\n'
b'    }\n'
b'    var n = 0, t = setInterval(function () { setzen(); if (++n > 30) clearInterval(t); }, 1000);\n'
b'  })();</script>\n')

roh = quelle.read_bytes()
anker = b"<head>\n"
i = roh.find(anker)
if i == -1:
    print("  FEHLER: Im Quelltext wurde kein <head> gefunden."); sys.exit(1)
i += len(anker)
neu = roh[:i] + META + WACHE + roh[i:]

# Beweis: nur die zwei Einfuegungen unterscheiden Kopie und Quelle.
if neu.replace(META, b"", 1).replace(WACHE, b"", 1) != roh:
    print("  FEHLER: Es waere mehr veraendert worden als die zwei Zeilen-Bloecke."); sys.exit(1)

alt = ziel.read_bytes() if ziel.exists() else b""
ziel.write_bytes(neu)

print("  Suchmaschinen-Sperre eingesetzt:")
print("    - noindex-Zeile        (%d Bytes)" % len(META))
print("    - Wach-Skript          (%d Bytes)" % len(WACHE))
print("")
print("  Quelle : %9d Bytes  MD5 %s" % (len(roh), hashlib.md5(roh).hexdigest()))
print("  Kopie  : %9d Bytes  (+%d)" % (len(neu), len(neu) - len(roh)))
print("  Pruefung: Kopie minus Sperren == Quelle  -> OK")
print("  UNVERAENDERT" if neu == alt else "  GEAENDERT")
PY

if git diff --quiet -- index.html && [ -z "$(git status --porcelain -- index.html)" ]; then
  echo ""
  echo "  Die veroeffentlichte Seite ist bereits auf diesem Stand."
  echo "  Nichts zu tun."
  echo ""
  read -n1 -r -p "  Taste druecken zum Schliessen..."; echo ""
  exit 0
fi

echo ""
echo "  Es gibt eine neue Fassung zum Veroeffentlichen."
echo ""
# Veroeffentlicht wird nur nach ausdruecklicher Zustimmung.
# Ohne Rueckfragemoeglichkeit (Aufruf aus einem anderen Skript) wird NICHT
# gepusht - ausser die Zustimmung steht als --auto in der Befehlszeile.
if [ "$1" = "--auto" ]; then
  echo "  (--auto: veroeffentliche ohne Rueckfrage)"
elif [ -t 0 ]; then
  read -r -p "  Jetzt veroeffentlichen? [j/N] " antwort
  case "$antwort" in
    [jJyY]*) ;;
    *) echo ""; echo "  Abgebrochen. Die neue Datei liegt vorbereitet im Ordner,"
       echo "  veroeffentlicht wurde nichts."; echo ""
       read -n1 -r -p "  Taste druecken zum Schliessen..."; echo ""; exit 0;;
  esac
else
  echo "  Keine Rueckfrage moeglich - es wurde NICHTS veroeffentlicht."
  echo "  Die neue Datei liegt vorbereitet im Ordner."
  echo "  Zum Veroeffentlichen das Skript doppelklicken oder mit --auto aufrufen."
  echo ""
  exit 0
fi

MD5="$(md5 -q "$QUELLE" 2>/dev/null || md5sum "$QUELLE" | cut -d' ' -f1)"
git add index.html || fehler "git add fehlgeschlagen."
git commit -q -m "Notfallordner aktualisiert (Quelle MD5 $MD5)

Neue Fassung aus dem Vault uebernommen, noindex-Zeile und Wach-Skript
wieder eingesetzt. Kopie minus Sperren ist byte-identisch mit der Quelle." || fehler "git commit fehlgeschlagen."

echo ""
echo "  Committet: $(git rev-parse --short HEAD)"
echo "  Sende an GitHub ..."
git push -q origin main || fehler "git push fehlgeschlagen. Internet? Bei GitHub angemeldet?"

echo ""
echo "  Fertig. GitHub braucht jetzt ein bis zwei Minuten zum Ausliefern."
echo "  Adresse: https://alihsm100.github.io/nfo-host/"
echo ""
echo "  Tipp: Wenn du im Browser noch den alten Stand siehst,"
echo "        einmal mit Cmd+Shift+R neu laden."
echo ""
read -n1 -r -p "  Taste druecken zum Schliessen..."; echo ""
