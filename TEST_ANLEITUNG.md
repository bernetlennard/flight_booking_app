# Testanleitung & Testprotokoll (Manuelles UI-Testing)

Dieses Dokument enthält eine detaillierte, leicht verständliche Testanleitung für Endbenutzer zur manuellen Überprüfung der **Flugbuchungs-App**.

Das Testprotokoll ist in vier Hauptbereiche unterteilt:
1. **Registrierung & Login**
2. **Flugbuchung (inkl. Absprung-Logik für nicht angemeldete Benutzer)**
3. **Buchungsübersicht ("Meine Buchungen")**
4. **Flugübersicht & Filterfunktionen** (inkl. Verweis auf analoge Filterung in der Buchungsübersicht)

---

## Inhaltsverzeichnis
1. [Allgemeine Vorbereitungen](#1-allgemeine-vorbereitungen)
2. [Überblick über die Benutzeroberfläche (UI)](#2-überblick-über-die-benutzeroberfläche-ui)
3. [Testfälle (TC)](#3-testfälle-tc)
   - [Kategorie A: Registrierung & Login](#kategorie-a-registrierung--login)
     - [TC-A-01: Registrierung mit Validierungsfehlern](#tc-a-01-registrierung-mit-validierungsfehlern)
     - [TC-A-02: Erfolgreiche Registrierung](#tc-a-02-erfolgreiche-registrierung)
     - [TC-A-03: Login mit Validierungsfehlern](#tc-a-03-login-mit-validierungsfehlern)
     - [TC-A-04: Erfolgreiches Login & Profilansicht / Abmelden](#tc-a-04-erfolgreiches-login--profilansicht--abmelden)
   - [Kategorie B: Flugbuchung & Absprung-Logik](#kategorie-b-flugbuchung--absprung-logik)
     - [TC-B-01: Buchungsversuch ohne Anmeldung (Absprung zu Login)](#tc-b-01-buchungsversuch-ohne-anmeldung-absprung-zu-login)
     - [TC-B-02: Erfolgreiche Buchung eines verfügbaren Flugs (Tickets > 0)](#tc-b-02-erfolgreiche-buchung-eines-verfügbaren-flugs-tickets--0)
     - [TC-B-03: Buchungsversuch eines ausgebuchten Flugs (Tickets = 0)](#tc-b-03-buchungsversuch-eines-ausgebuchten-flugs-tickets--0)
   - [Kategorie C: Buchungsübersicht](#kategorie-c-buchungsübersicht)
     - [TC-C-01: Anzeige der eigenen Buchungen](#tc-c-01-anzeige-der-eigenen-buchungen)
     - [TC-C-02: Filter-Leiste ein- und ausblenden in der Buchungsübersicht](#tc-c-02-filter-leiste-ein--und-ausblenden-in-der-buchungsübersicht)
   - [Kategorie D: Flugübersicht & Filter](#kategorie-d-flugübersicht--filter)
     - [TC-D-01: Standard-Ladeverhalten & Anzeige der Flüge](#tc-d-01-standard-ladeverhalten--anzeige-der-flüge)
     - [TC-D-02: Filter-Leiste ein- und ausblenden (Flugliste)](#tc-d-02-filter-leiste-ein--und-ausblenden-flugliste)
     - [TC-D-03: Filter nach Abreiseort](#tc-d-03-filter-nach-abreiseort)
     - [TC-D-04: Filter nach Zielort](#tc-d-04-filter-nach-zielort)
     - [TC-D-05: Filter nach Abreisedatum (DatePicker)](#tc-d-05-filter-nach-abreisedatum-datepicker)
     - [TC-D-06: Filter nach Airline](#tc-d-06-filter-nach-airline)
     - [TC-D-07: Filter nach Maximalpreis](#tc-d-07-filter-nach-maximalpreis)
     - [TC-D-08: Filter nach Ab- und Bis-Uhrzeit (TimePicker)](#tc-d-08-filter-nach-ab--und-bis-uhrzeit-timepicker)
     - [TC-D-09: Filter "Nur verfügbare Flüge" (Checkbox - nur Flugliste)](#tc-d-09-filter-nur-verfügbare-flüge-checkbox---nur-flugliste)
     - [TC-D-10: Kombinationsfilter](#tc-d-10-kombinationsfilter)
     - [TC-D-11: Fehlerzustand & "Erneut versuchen"-Button (Retry)](#tc-d-11-fehlerzustand--erneut-versuchen-button-retry)
---

## 1. Allgemeine Vorbereitungen

Bevor Sie mit den Tests starten, stellen Sie bitte Folgendes sicher:
* Die Flutter-App ist erfolgreich auf Ihrem Testgerät (Smartphone oder Emulator) gestartet.
* Sie befinden sich auf dem Startbildschirm der App (Titel: **"Verfügbare Flüge"**).
* Eine aktive Internetverbindung besteht (bzw. der Backend-Server läuft lokal oder als Mock-Service).

---

## 2. Überblick über die Benutzeroberfläche (UI)

* **AppBar (Kopfzeile) der Flugübersicht:**
  * Titel: "Verfügbare Flüge"
  * **Filter-Symbol (Trichter):** Schaltet das Filter-Panel ein/aus.
  * **Profil-/Login-Symbol (Person/Tür):** Navigiert zur Login-Maske (wenn nicht angemeldet) oder zur Profilseite (wenn angemeldet).
* **Profilseite ("Mein Profil"):**
  * Zeigt Name, Email und einen roten "Abmelden"-Button.
  * Enthält die Navigationszeile **"Meine Buchungen"** (führt zur Buchungsliste).
* **Buchungsübersicht ("Meine Buchungen"):**
  * Titel: "Meine Buchungen"
  * **Filter-Symbol (Trichter):** Schaltet das Filter-Panel für Ihre Buchungen ein/aus.
  * Zeigt alle bisher erfolgreich gebuchten Flüge an.
* **Filter-Panel (wenn ausgeklappt):**
  * Eingabefelder für Abreiseort, Zielort, Datum, Airline, Max. Preis sowie Zeitspannen ("Ab Zeit", "Bis Zeit").
  * Checkbox "Nur verfügbare" (nur in der Hauptflugliste sichtbar).
  * Such- bzw. Filter-Button ("SUCHEN" / "FILTERN").

---

## 3. Testfälle (TC)

### Kategorie A: Registrierung & Login

#### TC-A-01: Registrierung mit Validierungsfehlern
* **Ziel:** Prüfen, ob falsche oder unvollständige Registrierungsdaten abgelehnt werden.
* **Voraussetzung:** Der Benutzer ist nicht angemeldet.
* **Testschritte:**
  1. Tippen Sie oben rechts in der AppBar auf das **Login-Symbol** (Tür/Schlüssel).
  2. Tippen Sie auf **"Noch kein Konto? Jetzt registrieren"**.
  3. Lassen Sie alle Felder leer und tippen Sie auf **"Konto erstellen"**.
  4. Geben Sie einen Namen ein, lassen Sie das Email-Feld leer und geben Sie im Passwort-Feld weniger als 6 Zeichen ein (z. B. `123`). Tippen Sie auf **"Konto erstellen"**.
  5. Geben Sie eine ungültige Email ein (z. B. `test.de` ohne `@`). Tippen Sie auf **"Konto erstellen"**.
* **Erwartetes Ergebnis:**
  * Nach Schritt 3 erscheinen Fehlermeldungen unter den Feldern: "Bitte Namen eingeben", "Bitte Email eingeben", "Bitte Passwort eingeben".
  * Nach Schritt 4 fordert die App eine gültige Email an und meldet: "Passwort muss mindestens 6 Zeichen lang sein".
  * Nach Schritt 5 meldet die App beim Email-Feld: "Bitte gültige Email eingeben".

---

#### TC-A-02: Erfolgreiche Registrierung
* **Ziel:** Prüfen, ob die Registrierung mit korrekten Daten funktioniert und zur Login-Seite zurückführt.
* **Voraussetzung:** Sie befinden sich auf dem Registrierungs-Bildschirm.
* **Testschritte:**
  1. Geben Sie einen gültigen Namen ein (z. B. `Max Mustermann`).
  2. Geben Sie eine noch nicht registrierte Email-Adresse ein (z. B. `max@mustermann.com`).
  3. Geben Sie ein sicheres Passwort ein (mind. 6 Zeichen, z. B. `passwort123`).
  4. Tippen Sie auf **"Konto erstellen"**.
* **Erwartetes Ergebnis:**
  * Es erscheint eine grüne Benachrichtigungsleiste (SnackBar) am unteren Bildschirmrand mit der Meldung: **"Registrierung erfolgreich! Bitte anmelden."**.
  * Der Bildschirm schliesst sich automatisch und Sie befinden sich wieder auf der Anmeldeseite ("Anmelden").

---

#### TC-A-03: Login mit Validierungsfehlern
* **Ziel:** Prüfen, ob das Login unvollständige Eingaben abfängt.
* **Voraussetzung:** Sie befinden sich auf der "Anmelden"-Seite und sind nicht eingeloggt.
* **Testschritte:**
  1. Lassen Sie beide Felder leer und tippen Sie auf **"Anmelden"**.
  2. Geben Sie eine Email ohne `@` ein (z. B. `max`) und ein zu kurzes Passwort (z. B. `12`). Tippen Sie auf **"Anmelden"**.
* **Erwartetes Ergebnis:**
  * Es erscheinen rote Validierungshinweise: "Bitte Email eingeben" und "Bitte Passwort eingeben" (Schritt 1).
  * Nach Schritt 2 meldet die App "Bitte gültige Email eingeben" und "Passwort muss mindestens 6 Zeichen lang sein".

---

#### TC-A-04: Erfolgreiches Login & Profilansicht / Abmelden
* **Ziel:** Erfolgreichen Login, Profilanzeige und Logout-Funktionalität prüfen.
* **Voraussetzung:** Ein gültiges Benutzerkonto existiert. Sie befinden sich auf der "Anmelden"-Seite.
* **Testschritte:**
  1. Geben Sie die Zugangsdaten aus TC-A-02 ein.
  2. Tippen Sie auf **"Anmelden"**.
  3. Tippen Sie nun auf dem Startbildschirm oben rechts auf das neue **Profil-Symbol** (Personen-Icon).
  4. Prüfen Sie, ob Ihr korrekter Name und Ihre Email-Adresse angezeigt werden.
  5. Tippen Sie auf den roten Button **"Abmelden"**.
  6. Tippen Sie erneut auf das Symbol oben rechts in der AppBar auf der Flugübersicht.
* **Erwartetes Ergebnis:**
  * Nach Schritt 2 schliesst sich das Login-Fenster. Sie sind wieder auf der Flugliste.
  * In Schritt 3 öffnet sich die Profilseite ("Mein Profil") mit den korrekten Benutzerdaten (Schritt 4).
  * Nach Schritt 5 schliesst sich das Profilfenster und Sie sind ausgeloggt.
  * In Schritt 6 öffnet sich wieder die leere Anmeldemaske ("Anmelden"), was den erfolgreichen Logout bestätigt.

---

### Kategorie B: Flugbuchung & Absprung-Logik

#### TC-B-01: Buchungsversuch ohne Anmeldung (Absprung zu Login)
* **Ziel:** Prüfen, ob nicht angemeldete Benutzer beim Buchungsversuch zum Login umgeleitet werden.
* **Voraussetzung:** Sie sind **nicht** angemeldet (im Zweifel über Profil abmelden).
* **Testschritte:**
  1. Tippen Sie auf der Hauptseite auf eine beliebige Flug-Karte in der Liste.
  2. Beobachten Sie die Benachrichtigungen und den Bildschirmwechsel.
  3. Tippen Sie auf **"Noch kein Konto? Jetzt registrieren"** und kehren Sie danach mit der Zurück-Taste des Geräts wieder zum Login zurück.
* **Erwartetes Ergebnis:**
  * Am unteren Bildschirmrand erscheint kurzzeitig eine Meldung: **"Bitte melden Sie sich an, um diesen Flug zu buchen."**.
  * Die App navigiert den Benutzer automatisch direkt auf die **"Anmelden"**-Seite.
  * Von dort aus gelangt man über den entsprechenden Link auch zur Registrierung (Schritt 3).

---

#### TC-B-02: Erfolgreiche Buchung eines verfügbaren Flugs (Tickets > 0)
* **Ziel:** Einen verfügbaren Flug buchen, wenn man angemeldet ist.
* **Voraussetzung:** Sie sind mit Ihrem Testkonto angemeldet und befinden sich auf der Flugübersicht. Es existiert mindestens ein Flug mit freien Tickets (z. B. `Tickets: 5`).
* **Testschritte:**
  1. Tippen Sie auf eine Flug-Karte, die noch verfügbare Tickets aufweist.
  2. Prüfen Sie das angezeigte Dialogfenster ("Flug buchen?").
  3. Tippen Sie auf **"Kostenpflichtig buchen"**.
  4. Beobachten Sie die Bestätigung und die Tickets-Anzahl in der Hauptliste.
* **Erwartetes Ergebnis:**
  * Es öffnet sich das Dialogfenster "Flug buchen?" mit den korrekten Details (Flugroute, Datum, Preis).
  * Nach dem Tippen auf "Kostenpflichtig buchen" erscheint eine grüne Benachrichtigung: **"Flug erfolgreich gebucht!"**.
  * Der Dialog schliesst sich selbstständig.
  * Die Anzahl der verfügbaren Tickets für diesen Flug in der Hauptliste hat sich um exakt **1 verringert** (z. B. von 5 auf 4 Tickets).

---

#### TC-B-03: Buchungsversuch eines ausgebuchten Flugs (Tickets = 0)
* **Ziel:** Verhindern, dass ausgebuchte Flüge gebucht werden können.
* **Voraussetzung:** Sie sind angemeldet. Es existiert ein Flug mit `Tickets: 0`.
* **Testschritte:**
  1. Tippen Sie auf eine Flug-Karte mit `Tickets: 0`.
  2. Prüfen Sie das angezeigte Dialogfenster.
  3. Tippen Sie auf **"OK"**, um den Dialog zu schliessen.
* **Erwartetes Ergebnis:**
  * Es erscheint der Dialog **"Flug ausgebucht"** mit dem Inhalt **"Leider sind für diesen Flug keine Tickets mehr verfügbar."**.
  * Es ist keine Buchungsschaltfläche vorhanden.
  * Nach dem Tippen auf "OK" schliesst sich das Dialogfeld ohne weitere Aktion.

---

### Kategorie C: Buchungsübersicht

#### TC-C-01: Anzeige der eigenen Buchungen
* **Ziel:** Sicherstellen, dass getätigte Buchungen in der Buchungsübersicht aufgelistet werden.
* **Voraussetzung:** Sie sind angemeldet und haben mindestens einen Flug erfolgreich gebucht (siehe TC-B-02).
* **Testschritte:**
  1. Tippen Sie oben rechts in der AppBar auf das **Profil-Symbol** (Person).
  2. Tippen Sie auf das Listenelement **"Meine Buchungen"**.
  3. Prüfen Sie die Liste der Buchungen.
* **Erwartetes Ergebnis:**
  * Es öffnet sich die Seite **"Meine Buchungen"**.
  * Die gebuchten Flüge werden als Karten angezeigt.
  * Jede Karte enthält:
    * Blaues Lesezeichen-Symbol (`Bookmark-Icon`) links.
    * Korrekte Route `[Abreiseort] -> [Zielort]`.
    * Subtitel mit `[Airline] | [Flugdatum] [Abfluguhrzeit]`.
    * Zweite Zeile im Subtitel mit dem Buchungsdatum: `Gebucht am: [Datum der Buchung]`.
    * Den Preis rechtsbündig in grün (z. B. `120.00 CHF`).

---

#### TC-C-02: Filter-Leiste ein- und ausblenden in der Buchungsübersicht
* **Ziel:** Das Ein- und Ausklappen der Filter-Leiste auf der Buchungsseite prüfen.
* **Voraussetzung:** Sie befinden sich in der Ansicht **"Meine Buchungen"**.
* **Testschritte:**
  1. Tippen Sie oben rechts in der AppBar auf das **Filter-Symbol** (Trichter).
  2. Tippen Sie erneut auf dasselbe Symbol.
* **Erwartetes Ergebnis:**
  * Nach Schritt 1 klappt sich das graue Filter-Panel direkt unter der AppBar auf.
  * Im Vergleich zur Flugliste fehlt hier die Checkbox "Nur verfügbare" (da gebuchte Flüge immer "verfügbar" für Sie waren).
  * Nach Schritt 2 schliesst sich das Panel wieder.

---

### Kategorie D: Flugübersicht & Filter
*(WICHTIG: Bis auf den Filter "Nur verfügbare" gelten alle nachfolgenden Filterkriterien **sowohl für die Flugübersicht ("Verfügbare Flüge") als auch für die Buchungsübersicht ("Meine Buchungen")**. Bitte testen Sie die Kriterien auf beiden Seiten!)*

#### TC-D-01: Standard-Ladeverhalten & Anzeige der Flüge
* **Ziel:** Korrekte Lade-Anzeige beim Öffnen der Flugübersicht.
* **Voraussetzung:** App wurde frisch gestartet.
* **Testschritte:**
  1. Starten Sie die App neu.
* **Erwartetes Ergebnis:**
  * Kurzzeitig erscheint ein Lade-Indikator (drehender Kreis).
  * Danach lädt die vollständige Liste der angebotenen Flüge.

---

#### TC-D-02: Filter-Leiste ein- und ausblenden (Flugliste)
* **Ziel:** Filterleiste auf der Startseite steuern.
* **Voraussetzung:** Sie sind auf der Hauptseite ("Verfügbare Flüge").
* **Testschritte:**
  1. Tippen Sie oben rechts auf den Filter-Trichter.
  2. Tippen Sie erneut darauf.
* **Erwartetes Ergebnis:**
  * Die Leiste klappt mit allen Optionen (inkl. Checkbox "Nur verfügbare") auf und schliesst sich wieder einwandfrei.

---

#### TC-D-03: Filter nach Abreiseort
* **Ziel:** Filterung nach Abflugort (Teilstrings & Groß-/Kleinschreibung ignorieren) prüfen.
* **Voraussetzung:** Filter-Panel ist auf der jeweiligen Seite geöffnet.
* **Testschritte (Sowohl auf "Verfügbare Flüge" als auch auf "Meine Buchungen" durchführen):**
  1. Geben Sie im Feld **"Abreiseort"** einen bekannten Ort ein (z. B. `Zürich` oder `Zür`).
  2. Tippen Sie auf den Button am Ende der Maske (**"SUCHEN"** bzw. **"FILTERN"**).
  3. Löschen Sie das Feld und geben Sie ein Fantasiewort ein (z. B. `Fantasialand`). Tippen Sie erneut auf den Button.
* **Erwartetes Ergebnis:**
  * Nach Schritt 2 werden nur noch Flüge/Buchungen mit passendem Abflugsort angezeigt.
  * Nach Schritt 3 verschwindet die Liste und es erscheint die Meldung **"Keine Flüge gefunden."** (auf der Hauptseite) bzw. **"Keine Buchungen gefunden."** (auf der Buchungsseite).

---

#### TC-D-04: Filter nach Zielort
* **Ziel:** Filterung nach Ankunftsort prüfen.
* **Voraussetzung:** Filter-Panel geöffnet. Felder sind leer.
* **Testschritte (Sowohl auf "Verfügbare Flüge" als auch auf "Meine Buchungen" durchführen):**
  1. Geben Sie im Feld **"Zielort"** ein Ziel ein (z. B. `London` oder `Lon`).
  2. Tippen Sie auf **"SUCHEN"** / **"FILTERN"**.
* **Erwartetes Ergebnis:**
  * Es verbleiben nur Flüge/Buchungen in der Liste, die das eingegebene Reiseziel anfliegen.

---

#### TC-D-05: Filter nach Abreisedatum (DatePicker)
* **Ziel:** Datumsauswahl über Kalender und Filterung prüfen.
* **Voraussetzung:** Filter-Panel geöffnet. Felder sind leer.
* **Testschritte (Sowohl auf "Verfügbare Flüge" als auch auf "Meine Buchungen" durchführen):**
  1. Tippen Sie in das Feld **"Datum (YYYY-MM-DD)"**.
  2. Wählen Sie im geöffneten Kalender-Dialog ein Datum aus, an dem Flüge stattfinden, und bestätigen Sie.
  3. Tippen Sie auf **"SUCHEN"** / **"FILTERN"**.
* **Erwartetes Ergebnis:**
  * Der Kalender öffnet sich und trägt das Datum korrekt formatiert (`YYYY-MM-DD`) ein.
  * Nach dem Filtern werden nur Flüge mit exakt diesem Abreisedatum gelistet.

---

#### TC-D-06: Filter nach Airline
* **Ziel:** Filtern nach Fluggesellschaften prüfen.
* **Voraussetzung:** Filter-Panel geöffnet. Felder sind leer.
* **Testschritte (Sowohl auf "Verfügbare Flüge" als auch auf "Meine Buchungen" durchführen):**
  1. Geben Sie im Feld **"Airline"** einen Namen ein (z. B. `Swiss` oder `Lufthansa`).
  2. Tippen Sie auf **"SUCHEN"** / **"FILTERN"**.
* **Erwartetes Ergebnis:**
  * Nur Flüge/Buchungen der entsprechenden Fluggesellschaft werden aufgelistet.

---

#### TC-D-07: Filter nach Maximalpreis
* **Ziel:** Preisgrenzen-Filter testen.
* **Voraussetzung:** Filter-Panel geöffnet. Felder sind leer.
* **Testschritte (Sowohl auf "Verfügbare Flüge" als auch auf "Meine Buchungen" durchführen):**
  1. Geben Sie im Feld **"Max. Preis"** einen Betrag ein (z. B. `300`).
  2. Tippen Sie auf **"SUCHEN"** / **"FILTERN"**.
* **Erwartetes Ergebnis:**
  * In der gefilterten Ansicht befinden sich ausschliesslich Flüge/Buchungen, deren Ticketpreis kleiner oder gleich dem eingegebenen Wert ist (z. B. `<= 300.00 CHF`).

---

#### TC-D-08: Filter nach Ab- und Bis-Uhrzeit (TimePicker)
* **Ziel:** Filterung nach einem zeitlichen Abflugsfenster prüfen.
* **Voraussetzung:** Filter-Panel geöffnet. Felder sind leer.
* **Testschritte (Sowohl auf "Verfügbare Flüge" als auch auf "Meine Buchungen" durchführen):**
  1. Tippen Sie auf das Feld **"Ab Zeit"**. Wählen Sie z. B. `06:00` Uhr im Time-Picker-Dialog aus und bestätigen Sie.
  2. Tippen Sie auf das Feld **"Bis Zeit"**. Wählen Sie z. B. `15:00` Uhr aus und bestätigen Sie.
  3. Tippen Sie auf **"SUCHEN"** / **"FILTERN"**.
* **Erwartetes Ergebnis:**
  * Beide Textfelder weisen die gewählten Zeiten im Format `HH:MM` auf.
  * Nach dem Filtern verbleiben nur Flüge, deren Abflugzeit im definierten Bereich liegt (z. B. Abflug um 08:30 Uhr bleibt, Abflug um 18:00 Uhr wird ausgeblendet).

---

#### TC-D-09: Filter "Nur verfügbare Flüge" (Checkbox - nur Flugliste)
* **Ziel:** Ausblenden ausgebuchter Flüge auf der Hauptseite.
* **Voraussetzung:** Sie befinden sich auf der Seite **"Verfügbare Flüge"** mit geöffnetem Filter-Panel. Es gibt mindestens einen ausgebuchten Flug (`Tickets: 0`) in der Liste.
* **Testschritte:**
  1. Aktivieren Sie die Checkbox **"Nur verfügbare"**.
  2. Tippen Sie auf **"SUCHEN"**.
* **Erwartetes Ergebnis:**
  * Alle Flüge mit `Tickets: 0` werden ausgeblendet. Es verbleiben nur Flüge mit mindestens 1 freien Ticket.

---

#### TC-D-10: Kombinationsfilter
* **Ziel:** Logische UND-Verknüpfung mehrerer Filter überprüfen.
* **Voraussetzung:** Filter-Panel geöffnet.
* **Testschritte (Sowohl auf "Verfügbare Flüge" als auch auf "Meine Buchungen" durchführen):**
  1. Geben Sie im Feld "Abreiseort" einen Ort ein (z. B. `Zürich`).
  2. Geben Sie im Feld "Max. Preis" einen Wert ein (z. B. `400`).
  3. (Nur auf Hauptseite): Wählen Sie zusätzlich die Option "Nur verfügbare".
  4. Tippen Sie auf **"SUCHEN"** / **"FILTERN"**.
* **Erwartetes Ergebnis:**
  * Jeder gefilterte Flug erfüllt **alle Bedingungen gleichzeitig** (Startort Zürich **UND** Preis <= 400 CHF **UND** [falls Hauptseite] freie Plätze vorhanden).

---

#### TC-D-11: Fehlerzustand & "Erneut versuchen"-Button (Retry)
* **Ziel:** Fehlerdarstellung bei Netzwerk-/Serverproblemen und Neu-Laden prüfen.
* **Voraussetzung:** Sie befinden sich in der Flug- oder Buchungsübersicht.
* **Testschritte (Sowohl auf "Verfügbare Flüge" als auch auf "Meine Buchungen" durchführen):**
  1. Trennen Sie die Internetverbindung Ihres Geräts (Flugmodus) oder stoppen Sie das lokale Backend.
  2. Lösen Sie eine Filteranfrage aus oder versuchen Sie die Ansicht neu zu laden.
  3. Beobachten Sie die Fehlermeldung.
  4. Stellen Sie die Internetverbindung wieder her / starten Sie das Backend.
  5. Tippen Sie in der Fehleranzeige auf den Button **"Erneut versuchen"** (oder "Wiederholen").
* **Erwartetes Ergebnis:**
  * In Schritt 3 erscheint eine strukturierte Fehlerbox mit einer Fehlermeldung (z. B. Verbindungsfehler/SocketException).
  * Nach Schritt 5 lädt die App kurz (Spinner) und zeigt anschliessend wieder wie gewohnt die korrekte Liste der Flüge bzw. Buchungen an.
