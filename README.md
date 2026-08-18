# nfo-host

Reine **Hosting-Kopie** des Notfallordner-Werkzeugs (eine offline lauffähige HTML-Datei).

- **Quelle ist der Vault**, nicht dieses Repo: `~/tecis/html/tecis_Notfallordner.html`
- Die Datei wird dort reproduzierbar erzeugt aus `99 Technik/patch_notfallordner.py`
  und `99 Technik/notfallordner_logik.js`.
- **Hier nichts bearbeiten.** Die 43 Druckseiten sind byte-identisch mit dem Design-Original
  verifiziert; eine Änderung an der Kopie bricht diese Zusage.
- Einziger Unterschied zur Quelle: eine `noindex`-Meta-Zeile im `<head>`.

Aktualisieren: Datei im Vault neu erzeugen, hierher als `index.html` kopieren,
die noindex-Zeile wieder einfügen, committen.
