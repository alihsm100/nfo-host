# nfo-host

Reine **Hosting-Kopie** des Notfallordner-Werkzeugs (eine offline lauffähige HTML-Datei).

- **Quelle ist der Vault**, nicht dieses Repo: `~/tecis/html/tecis_Notfallordner.html`
- Die Datei wird dort reproduzierbar erzeugt aus `99 Technik/patch_notfallordner.py`
  und `99 Technik/notfallordner_logik.js`.
- **Hier nichts bearbeiten.** Die 43 Druckseiten sind byte-identisch mit dem Design-Original
  verifiziert; eine Änderung an der Kopie bricht diese Zusage.
- Unterschied zur Quelle: genau **1.102 Byte**, die Suchmaschinen-Sperre aus zwei Blöcken
  (noindex-Meta-Zeile plus ein Wach-Skript, das sie wieder einhängt, weil das Bundle beim Start
  den `<head>` neu aufbaut). Die Meta-Zeile allein wirkt nicht.

**Aktualisieren nur über `aktualisieren.command`** (Doppelklick). Das Skript setzt beide Blöcke,
prüft „Kopie minus Sperren = Vault-Quelle“ und veröffentlicht erst nach Rückfrage. Nie von Hand
kopieren, sonst ist die Sperre weg.

Danach bleibt ein Schritt, den nur Ali machen kann: die Kopie in der SharePoint-Bibliothek
(`Team1844-VP3-Berater/Shared Documents/Notfallordner/tecis_Notfallordner.html`) durch die
Vault-Datei ersetzen. Sie ist der Offline-Download des Teams-Tabs und läuft sonst auseinander.
