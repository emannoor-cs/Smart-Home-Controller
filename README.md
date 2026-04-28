# 🏠 Smart Home Controller

A Flutter web application to control and monitor smart home devices in real-time using the MQTT protocol.

---

## 📋 Project Overview

This app acts as a smart home controller where users can:

- Connect to any MQTT broker (HiveMQ, Mosquitto, EMQX)
- Turn devices ON/OFF from the dashboard
- View real-time device states
- Publish and receive messages via MQTT topics
- See a live message log of all MQTT activity

---

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| Flutter (Web) | Frontend UI |
| Dart | Programming language |
| MQTT Protocol | IoT communication |
| Riverpod | State management |
| mqtt_client | MQTT package for Flutter |
| broker.emqx.io | Free public MQTT broker |
| MQTTX | Desktop MQTT testing tool |

---

## 📡 MQTT Topics

| Device | Topic | Payload |
|---|---|---|
| Living Room Light | `home/light` | `ON` / `OFF` |
| Ceiling Fan | `home/fan` | `ON` / `OFF` |
| Air Conditioner | `home/ac` | `ON` / `OFF` |

---

## 🔧 Broker Configuration

### Flutter Web App (WebSocket)
```
Broker:   broker.emqx.io
Port:     8084  (WebSocket SSL)
Protocol: wss://
```

### MQTTX Desktop (TCP)
```
Broker:   broker.emqx.io
Port:     1883  (TCP)
Protocol: mqtt://
```

> **Note:** Browsers cannot use raw TCP. Flutter Web uses WebSocket (wss://) while MQTTX uses standard TCP (port 1883). Both connect to the same broker so messages flow between them.

---

## 📁 Project Structure

```
lib/
├── main.dart                        # App entry point, theme setup
├── core/
│   └── services/
│       └── mqtt_service.dart        # All MQTT logic (connect, subscribe, publish)
├── models/
│   └── device_model.dart            # Device data model
├── screens/
│   ├── connection_screen.dart       # Broker login screen + providers
│   └── dashboard_screen.dart        # Main device control dashboard
└── widgets/
    ├── device_card.dart             # Individual device ON/OFF card
    └── log_panel.dart               # Real-time MQTT message log
```

---

## ⚙️ Installation & Setup

### Prerequisites

- Flutter SDK installed ([flutter.dev](https://flutter.dev))
- Chrome or Edge browser
- MQTTX desktop app ([mqttx.app](https://mqttx.app))

### Steps

**1. Clone the repository**
```bash
git clone https://github.com/YOUR_USERNAME/smart-home-controller.git
cd smart-home-controller
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Run the app**
```bash
flutter run -d chrome
```

---

## 🧪 Testing Steps

### Step 1: Run the Flutter app
```bash
flutter run -d chrome
```

### Step 2: Connect to broker
On the Connection Screen enter:
```
Broker URL:  broker.emqx.io
Port:        8084
Client ID:   flutter-home-001
```
Tap **Connect**

### Step 3: Open MQTTX and connect
```
Host:      broker.emqx.io
Port:      1883
Client ID: mqttx-test-456
```

### Step 4: Subscribe in MQTTX (to monitor)
Click **+ New Subscription** and subscribe to:
```
home/light
home/fan
home/ac
```

### Step 5: Publish from MQTTX → App receives
In MQTTX bottom bar:
```
Topic:   home/light
Payload: ON          ← plain text, not JSON
```
Click **Send** → Watch the Light card turn ON in Flutter app ✅

### Step 6: Toggle from App → MQTTX receives
Tap any device card in the Flutter app → MQTTX will receive the ON/OFF message ✅

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  mqtt_client: ^10.0.0
  flutter_riverpod: ^2.5.1
  uuid: ^4.3.3
```

---

## 🏗️ Architecture

```
┌─────────────────┐        WebSocket (wss://)       ┌──────────────────────┐
│  Flutter Web    │ ──────────────────────────────►  │                      │
│  (Chrome)       │ ◄──────────────────────────────  │  broker.emqx.io      │
│                 │        Port 8084                  │  (MQTT Broker)       │
└─────────────────┘                                  │                      │
                                                     └──────────────────────┘
┌─────────────────┐        TCP (mqtt://)                      ▲
│  MQTTX Desktop  │ ──────────────────────────────────────────┘
│  (Publisher)    │        Port 1883
└─────────────────┘
```

**Data flow:**
```
MQTTX publishes "ON" to home/light
        ↓
Broker receives and routes message
        ↓
Flutter app (subscribed to home/light) receives "ON"
        ↓
Riverpod state updates → UI rebuilds → Light card shows ON
```

---

## ✨ Features

- ✅ Real-time device control via MQTT
- ✅ Animated device cards (smooth ON/OFF transitions)
- ✅ Live MQTT message log with color coding (green = ON, red = OFF)
- ✅ Bidirectional communication (app sends AND receives)
- ✅ Connection status indicator
- ✅ Error handling with user-friendly messages
- ✅ Dark theme UI
- ✅ WebSocket support for Flutter Web

---

## 👨‍💻 Author

**EMAN NOOR**  
BSCS Student  
GitHub: [emannoor-cs](https://github.com/emannoor-cs)

---

## 📄 License

This project is for educational purposes as part of a Flutter Fellowship.
