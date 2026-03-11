# ASHA-AI: AI-Assisted Health Risk Screening & Management System 🩺📱

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![NodeJS](https://img.shields.io/badge/node.js-6DA55F?style=for-the-badge&logo=node.js&logoColor=white)
![Express.js](https://img.shields.io/badge/express.js-%23404d59.svg?style=for-the-badge&logo=express&logoColor=%2361DAFB)
![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)

ASHA-AI is a mobile-first, full-stack software system designed to support frontline healthcare workers (ASHAs) in rural and underserved communities. It digitizes workflow management and leverages a simulated AI risk assessment engine to evaluate patient multimedia inputs (images, audio, vitals) for early health risk detection.

---

## 🌟 Key Features

### 👩‍⚕️ For ASHA Workers (Field App)
*   **Patient Digitization:** Register and track demographics, trimesters, and health history centrally.
*   **Multimedia Screening:** Capture high-resolution images (e.g., conjunctiva for anemia) and audio (e.g., cough tracking) natively.
*   **AI Risk Assessment (Simulated):** Instant predictive analysis returning Risk Scores (Low/Medium/High) and condition-specific early health warnings.
*   **Gamification Leaderboard:** Workers earn points per screening, improving their ranking dynamically against peers to encourage platform adoption.

### 🛡️ For System Admins (Command Center)
*   **Role-Based Access Control (RBAC):** Secure JWT and UID-based middleware separating field workers from system administrators.
*   **Worker Provisioning:** Dashboard access to securely onboard new ASHA workers and assign territorial bounds (Villages/Wards).
*   **Central Analytics:** Macro-level view of Risk Distributions, total system screenings, and gamification metrics.
*   **Data Privacy Constraints:** Robust backend safeguards ensuring workers only query and access patients mapped securely to their own UID.

---

## 🏗️ System Architecture

ASHA-AI utilizes a standard Three-Tier Architecture:

1.  **Frontend (Client Tier):** Built with **Flutter (Dart)** for cross-platform mobile compilation. Follows Material Design 3 guidelines.
2.  **Backend (Application Tier):** A scalable **Node.js/Express.js** REST API protecting routes via `authMiddleware` JWT verification.
3.  **Data & Storage (Persistence Tier):** 
    *   **Cloud Firestore:** NoSQL document database storing `users`, `patients`, and `screenings`.
    *   **Firebase Cloud Storage:** Secure bucket (`asha-ai-30512`) for immutable storage of screening media inputs, piped directly from Node RAM via `multer`.

---

## 🚀 Getting Started

### Prerequisites
*   [Flutter SDK](https://docs.flutter.dev/get-started/install)
*   [Node.js](https://nodejs.org/) (v16+)
*   A Firebase Project with Firestore and Storage enabled.

### 1. Backend Setup
```bash
cd server
npm install
# Add your Firebase serviceAccountKey.json to the /server root
npm run dev
```
*The server will boot on `http://localhost:3000`*

### 2. Frontend Setup
```bash
cd client
flutter pub get
# Ensure your emulator is running or device is connected
flutter run
```

---

## 🔒 Security & Roles
*   **Admin Access:** Use the hardcoded superadmin (`admin` / `password123`) to boot up the system and provision your first field workers.
*   **ASHA Access:** Log in using the credentials created by the Admin to view area-restricted patient lists.

---

## 📜 Academic Disclaimer
*This system was developed as a proof-of-concept / academic project. The AI Engine predictions are heavily simulated probability logic matrices and **DO NOT** constitute professional medical advice, diagnosis, or prescription.*
