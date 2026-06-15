# Flugbuchungs-App (Flight Booking App)

Dieses Projekt ist eine mobile **Flugbuchungs-App** (Flutter-Frontend), die im Rahmen einer Case Study (MOA) entwickelt wurde. Sie ermöglicht das Suchen, Filtern und Buchen von Flügen sowie das Verwalten von Buchungen und ein Benutzer-Profil (inkl. Registrierung und Login).

---

## Inhaltsverzeichnis
1. [Voraussetzungen](#1-voraussetzungen)
2. [Lokales Setup & Installation](#2-lokales-setup--installation)
3. [Verbindung zum Backend (Wichtig!)](#3-verbindung-zum-backend-wichtig)
4. [App starten](#4-app-starten)
5. [Testing](#5-testing)

---

## 1. Voraussetzungen

Um diese App lokal auszuführen und zu entwickeln, benötigen Sie:

* **Flutter SDK**: Installiert und im Systempfad (`PATH`) hinterlegt. Empfohlen ist Flutter SDK `^3.12.2` (oder neuer).
* **Dart SDK**: Wird automatisch mit Flutter installiert.
* **IDE**: 
  * **[Android Studio](https://developer.android.com/studio)** mit den installierten Plugins **Flutter** und **Dart**.
* **Plattform-Werkzeuge**:
  * Für **Android**: Android SDK, Android SDK Command-line Tools und ein eingerichteter Android Emulator
  * Für **iOS** (erfordert macOS): Xcode muss installiert sein. Sobald Xcode eingerichtet ist, erkennt Android Studio automatisch Ihre **iOS Simulatoren**

Prüfen Sie Ihre Installation in der Konsole von Android Studio oder im Terminal mit:
```bash
flutter doctor
```
Stellen Sie sicher, dass Android Studio und die gewünschten Toolchains (Android/iOS) korrekt konfiguriert sind.

---

## 2. Lokales Setup & Installation

### Schritt 1: Repository klonen
Klonen Sie dieses Repository auf Ihren lokalen Computer:
```bash
git clone <repository-url>
cd flight_booking_app
```

### Schritt 2: Abhängigkeiten installieren
Laden Sie alle benötigten Packages (wie `provider`, `http`, `flutter_secure_storage` etc.) herunter:
```bash
flutter pub get
```

---

## 3. Verbindung zum Backend

Die Flugbuchungs-App benötigt ein laufendes Backend (REST API) für Daten wie Flüge, Benutzer-Authentifizierung und Buchungen.

### Backend-Repository & Setup
Das dazugehörige Spring-Boot-Backend befindet sich in folgendem GitHub-Repository:
👉 **[Flight API (Backend)](https://github.com/bernetlennard/fligth-api)**

Bitte befolgen Sie die dortigen Anweisungen im README, um das Backend lokal auf Port **`8080`** zu starten.

### Konfiguration der IP-Adresse in der App
Die App kommuniziert über eine Basis-URL mit dem Server. Diese ist in der Datei **`lib/utils/constants.dart`** konfiguriert:

```dart
class Constants {
  // Standard-Einstellung für den Android-Emulator
  static const String baseUrl = 'http://10.0.2.2:8080';
}
```

**Wichtige Netzwerkhinweise für verschiedene Testumgebungen:**
* **Android Emulator (Standard)**: Belassen Sie die IP auf `http://10.0.2.2:8080`. Die IP `10.0.2.2` leitet Anfragen direkt an das `localhost` Ihres Host-Rechners weiter.
* **iOS Simulator / macOS / Web**: Ändern Sie die Adresse in `constants.dart` zu:
  ```dart
  static const String baseUrl = 'http://localhost:8080';
  ```
* **Physisches Testgerät (Android/iOS)**: 
  1. Stellen Sie sicher, dass Ihr Smartphone und Ihr Host-Rechner im **selben Wi-Fi-Netzwerk** sind.
  2. Ermitteln Sie die lokale IP-Adresse Ihres Rechners (z. B. `192.168.1.15`).
  3. Passen Sie die `baseUrl` entsprechend an:
     ```dart
     static const String baseUrl = 'http://192.168.1.15:8080';
     ```

---

## 4. App starten

Nachdem das Backend läuft, die Abhängigkeiten installiert sind und ein Emulator gestartet oder ein Gerät verbunden ist, können Sie die App starten:

### Über die Kommandozeile:
```bash
flutter run
```
*(Sollten mehrere Geräte angeschlossen sein, wählen Sie das gewünschte Gerät über die ausgegebene Liste aus).*

### Über Android Studio:
1. Öffnen Sie das Projektverzeichnis in Android Studio.
2. Wählen Sie das Zielgerät (z. B. einen **Android Emulator**, ein **iPhone** oder einen **iOS Simulator**) im Dropdown-Menü in der oberen Werkzeugleiste aus.
3. Stellen Sie sicher, dass `main.dart` als Start-Konfiguration ausgewählt ist.
4. Klicken Sie auf den **grünen Play-Button** (Run) in der oberen Leiste.

---

## 5. Testing

### Manuelles UI-Testing (Endbenutzer)
Es existiert eine ausführliche, schrittweise Anleitung für manuelle UI-Tests. Diese deckt alle wichtigen Workflows ab:
* Registrierung & Login
* Flugbuchungen & Absprung-Logik
* Meine Buchungen
* Flugliste & Filterung

Die Anleitung und die Protokollvorlage finden Sie im Projekt-Root unter:
👉 **[TEST_ANLEITUNG.md](./TEST_ANLEITUNG.md)**

