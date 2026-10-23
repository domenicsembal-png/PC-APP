# PC-APP

Kleiner Installer für Windows: Apps per Häkchen auswählen (auch mehrere) und automatisch installieren lassen. Nutzt winget (in Windows 10/11 enthalten).

## Benutzung
1. Repo herunterladen (Code -> Download ZIP) und entpacken.
2. `Start.bat` doppelklicken und Admin-Abfrage bestätigen.
3. Apps anhaken und auf **Installieren** klicken.

## Eigene Apps hinzufügen
`apps.json` bearbeiten. ID finden mit: `winget search <name>`

```json
{"name": "Anzeigename", "id": "Hersteller.App"}
```
