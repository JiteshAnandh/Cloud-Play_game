# Cloud Arena - Multiplayer 2D Shooter

A fast-paced, 4-player top-down arena shooter built with **Pygame-CE** on the client and a high-performance **asyncio WebSocket Server** designed for cloud hosting.

---

## Architecture Overview

```
                      ┌───────────────────────────────────────────────┐
                      │          Cloud Server (e.g. Render/AWS)       │
                      │               Port 443 (WSS / TLS)            │
                      │                                               │
                      │   RoomManager:                                │
                      │   ├── Room "K9X2" [3/4 Players]               │
                      │   │   ├── 30 Hz State Broadcast               │
                      │   │   └── Shotgun / Pellet Hit Relay          │
                      │   └── Room "B4T7" [4/4 Players - Playing]     │
                      └──────────────────────▲────────────────────────┘
                                             │ Secure WebSockets (wss://)
               ┌─────────────────────────────┼─────────────────────────────┐
               │                             │                             │
      ┌────────▼────────┐           ┌────────▼────────┐           ┌────────▼────────┐
      │ Player 1 (Host) │           │    Player 2     │           │    Player 3     │
      │  Pygame Client  │           │  Pygame Client  │           │  Pygame Client  │
      │  (Slot 0: Blue) │           │ (Slot 1: Orange)│           │ (Slot 2: Green) │
      └─────────────────┘           └─────────────────┘           └─────────────────┘
```

### Key Technical Highlights:
* **Asynchronous Client-Server:** Pygame client renders at 60 FPS while network operations run non-blockingly in a background asyncio thread via thread-safe queues.
* **4-Letter Room Code Invite System:** Players can create a private lobby, select any arena (Arena 1, 2, or 3), and share a 4-letter code (e.g. `K9X2`) for up to 4 players to join.
* **Corner Spawn Allocation:** Each player slot (0 to 3) is automatically mapped to dedicated corner spawn coordinates on the arena map.
* **Player Interpolation & Visuals:** Remote players are rendered with custom slot colors, names, mini health/shield bars above their heads, and smooth linear interpolation (lerping).
* **Powerup & Combat Synchronization:** Real-time shotgun spread, freeze ammo effects, and crate spawns are synchronized across all connected peers.

---

## How to Test Locally

You can test the entire multiplayer experience on a single computer:

### 1. Start the Server
In your first terminal:
```powershell
python server/server.py
```
*You will see: `Starting Cloud Arena Game Server on 0.0.0.0:8765...`*

### 2. Launch Player 1 (Host)
In a second terminal:
```powershell
cd client
python main.py
```
1. Click **MULTIPLAYER**.
2. Click **CREATE LOBBY**.
3. Enter your nickname (e.g. `Alice`), choose an Arena, and click **CREATE LOBBY**.
4. You will see your **4-letter Room Code** (e.g. `K9X2`) and yourself in **Slot 1 (Blue)**.

### 3. Launch Player 2 (Joiner)
In a third terminal:
```powershell
cd client
python main.py
```
1. Click **MULTIPLAYER**.
2. Click **JOIN LOBBY**.
3. Enter nickname (e.g. `Bob`) and the 4-letter code from Player 1.
4. Click **JOIN LOBBY**.
5. Both windows will update instantly showing both players in the lobby!

### 4. Start the Match
* In Player 1's window, click **START MATCH**.
* Both players spawn into opposite corners of the map and can fight in real-time!

---

## Cloud Deployment (For Cloud Computing Course)

### Option 1: Deploy on Render.com (Free & Recommended)
1. Push this repository to **GitHub**.
2. Log in to [Render.com](https://render.com).
3. Click **New +** -> **Web Service**.
4. Select your GitHub repository.
5. Configure:
   * **Runtime:** Python 3 (or Docker using the provided `Dockerfile`).
   * **Build Command:** `pip install -r server/requirements.txt`
   * **Start Command:** `python server/server.py`
   * **Plan:** Free
6. Click **Create Web Service**. Render will generate an endpoint:
   ```
   wss://cloud-arena-server.onrender.com
   ```
7. In `client/config.py`, change:
   ```python
   DEFAULT_SERVER_URL = "wss://cloud-arena-server.onrender.com"
   ```
8. Commit and share the `client/` folder with anyone! Players on different Wi-Fi networks can now play together.

### Option 2: Deploy on AWS (EC2 / Docker)
1. Launch an **AWS EC2 Ubuntu t2.micro / t3.micro** instance (Free Tier).
2. Allow inbound traffic on port `8765` (or port `80`/`443`) in your **Security Group**.
3. Clone the repo and run:
   ```bash
   docker build -t cloud-arena .
   docker run -d -p 8765:8765 cloud-arena
   ```
4. Point `client/config.py` to `ws://<YOUR-EC2-PUBLIC-IP>:8765`.

---

## Cloud Computing Concepts for Course Presentation / Report

1. **PaaS vs IaaS**: Explaining why a managed platform (Render) or container orchestration was selected to handle WebSocket statefulness versus a traditional VM.
2. **Reverse Proxy & TLS/WSS Termination**: How cloud edges accept secure traffic over Port 443 (`wss://`) and terminate SSL before relaying TCP frames to the internal application port.
3. **Stateful WebSocket Services**: Comparing stateless HTTP microservices (which scale horizontally with standard round-robin load balancers) to stateful real-time game servers requiring session affinity.
4. **Containerization (Docker)**: Utilizing a lightweight `python:3.12-slim` base image to achieve platform-agnostic cloud portability.
5. **Network Bandwidth Optimization**: Leveraging 30 Hz tick delta updates and discrete packet relays to minimize cloud egress bandwidth.
