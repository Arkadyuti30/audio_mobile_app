# Farm Friend Audio App

This project is a comprehensive **Offline-First** solution for recording agricultural audio data in remote areas, managing local storage, and synchronizing with a backend for AI analysis once internet connectivity is available.

## 📂 Project Structure

- **farm_friend_audio/**: The Flutter mobile application.
- **backend/**: The Python FastAPI server.
- **architecture_proposal.pdf**: Documentation regarding the system design.

## 🚀 Prerequisites

Ensure you have the following installed on your Ubuntu machine:

- Flutter SDK (Stable Channel)
- Python 3.8+
- Git
- A Physical Android/iOS Device (Recommended for audio features)

## 🛠️ Step 1: Backend Setup (Python FastAPI)

The backend handles multi-part audio file uploads and serves analyzed results.

### Navigate to the backend directory:

```bash
cd backend
```

### Create and activate a virtual environment:

```bash
python3 -m venv venv
source venv/bin/activate
```

### Install dependencies:

```bash
pip install fastapi uvicorn python-multipart
```

### Run the Server:

You must listen on `0.0.0.0` so your physical device can communicate with your laptop over the local network.

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### Find your Laptop's Local IP:

Open a new terminal and run:

```bash
hostname -I
```

Note down the first IP address (e.g., `192.168.29.124`).

## 📱 Step 2: Mobile App Setup (Flutter)

### Navigate to the app directory:

```bash
cd ../farm_friend_audio
```

### Configure Environment Variables:

Create a `.env` file in the root of the `farm_friend_audio` folder:

```bash
touch .env
```

Add your Backend IP address to this file:

```
# Replace with the IP found in Step 1
API_URL=http://192.168.29.124:8000
```

### Install Flutter Dependencies:

```bash
flutter pub get
```

### Run the App:

Connect your phone via USB and ensure USB Debugging is enabled.

```bash
flutter run
```

## 🧪 Testing Workflow

### 1. Offline Recording

- Open the app and tap the **Mic Button**.
- Record a session.
- The audio is saved locally to the device's storage.
- Go to **History**; you will see the record with a "Cloud Off" icon.

### 2. Synchronization

- Ensure your phone is on the same WiFi network as your laptop.
- On the Home Screen, tap the **Sync Button**.
- A loading spinner will appear.
- Upon completion, a green toast will confirm the number of files synced.

### 3. Online Analysis

- Once a file is synced (Green Cloud icon), go to **History**.
- Tap **"Show Analysis"**.
- The app will fetch the transcription and AI results from the backend and display them in a popup.

## 🔧 Troubleshooting (Ubuntu Specific)

### 1. Firewall Issues

If you get a "Connection Timed Out" error, Ubuntu's firewall (UFW) might be blocking port 8000.

```bash
sudo ufw allow 8000/tcp
sudo ufw reload
```

### 2. Connection Refused

- Ensure the backend is running and bound to `0.0.0.0`.
- If you use `127.0.0.1`, the phone will not be able to connect.

### 3. AP Isolation

Some routers prevent wireless devices from talking to each other.

**Solution:**
- Turn on your Laptop's WiFi Hotspot, connect your phone to it, and update the `.env` file with the gateway IP (usually `10.42.0.1`).
```
