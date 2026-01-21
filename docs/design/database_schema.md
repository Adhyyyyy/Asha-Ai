# ASHA-AI Database Design (Firestore Schema)

## 1. Overview
ASHA-AI uses a NoSQL document-oriented database (Google Firestore). The data is structured into root-level collections for scalability and role-based access control.

## 2. Collections Structure

### `users` (Collection)
Stores both Admin and ASHA Worker accounts.
*   **Document ID**: `auth_uid` (from Firebase Authentication)
*   **Fields**:
    *   `full_name` (string): Full name of the user.
    *   `email` (string, optional): Email address.
    *   `phone_number` (string): Primary contact number.
    *   `role` (string): 'ADMIN' | 'ASHA_WORKER'.
    *   `status` (string): 'ACTIVE' | 'INACTIVE' | 'SUSPENDED'.
    *   `created_at` (timestamp): Account creation time.
    *   **ASHA Specific Fields** (null for Admins):
        *   `asha_id` (string): Unique employee ID.
        *   `assigned_area` (string): Village or ward name.
        *   `district` (string): District name.
        *   `state` (string): State name.
        *   `total_patients` (number): Counter for dashbaord.
        *   `total_screenings` (number): Counter for dashboard.
        *   `rank_score` (number): For leaderboard.

### `patients` (Collection)
Stores patient profiles managed by ASHA workers.
*   **Document ID**: `patient_id` (UUID)
*   **Fields**:
    *   `full_name` (string)
    *   `age` (number)
    *   `gender` (string): 'MALE' | 'FEMALE' | 'OTHER'.
    *   `contact_number` (string, optional)
    *   `address` (string)
    *   `created_by_asha_id` (string): Reference to the ASHA worker's `auth_uid`.
    *   `created_at` (timestamp)
    *   `last_screening_date` (timestamp)
    *   `profile_photo_url` (string, optional): URL to Firebase Storage.

### `screenings` (Collection)
Stores individual health risk screening sessions.
*   **Document ID**: `screening_id` (UUID)
*   **Fields**:
    *   `patient_id` (string): Reference to `patients` doc.
    *   `asha_id` (string): Reference to `users` doc (creator).
    *   `screening_type` (string): 'ANEMIA' | 'RESPIRATORY' | 'GENERAL'.
    *   `timestamp` (timestamp): When the screening occurred.
    *   **Input Data**:
        *   `media_url` (string): Path to image/audio in Storage.
        *   `media_type` (string): 'IMAGE' | 'AUDIO'.
        *   `metadata` (map): e.g., `{ duration_sec: 15, format: 'aac' }`.
    *   **Result (Simulated AI Output)**:
        *   `risk_level` (string): 'GREEN' | 'YELLOW' | 'RED'.
        *   `indicators` (array of strings): e.g., ["Pallor Detected", "Irregular Breathing"].
        *   `confidence_score` (number): 0.0 to 1.0 (Mock value).
        *   `notes` (string): Optional manual notes by ASHA.

### `system_metrics` (Collection)
Stores aggregated data for Admin analytics (updated via Cloud Functions/Backend triggers).
*   **Document ID**: `global_stats` (Singleton)
*   **Fields**:
    *   `total_asha_workers` (number)
    *   `total_patients_registered` (number)
    *   `total_screenings_completed` (number)
    *   `risk_distribution` (map): `{ green: 120, yellow: 45, red: 10 }`.

## 3. Data Relationships & Indexing
*   **Queries Supported**:
    *   Get all patients where `created_by_asha_id` == current_user.
    *   Get all screenings where `patient_id` == X.
    *   Get leaderboard: `users` where `role` == 'ASHA_WORKER' orderBy `rank_score` desc.

## 4. Security Rules (Concept)
*   **Admins**: Read/Write all collections.
*   **ASHA Workers**:
    *   `users`: Read own profile.
    *   `patients`: Create/Read/Update where `created_by_asha_id` == auth.uid.
    *   `screenings`: Create/Read where `asha_id` == auth.uid.
    *   `system_metrics`: Read only.
