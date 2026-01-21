# ASHA-AI API Contracts (REST)

## 1. Overview
The backend server (Node.js + Express) exposes RESTful APIs.
*   **Base URL**: `/api/v1`
*   **Authentication**: Bearer Token (Firebase ID Token) in headers.
*   **Response Format**: JSON `{ success: boolean, data: any, message: string }`

## 2. Authentication APIs
*   `POST /auth/login` - (Handled via Firebase SDK on client, but backend verifies token)
*   `POST /auth/verify-role`
    *   **Header**: `Authorization: Bearer <token>`
    *   **Response**: `{ role: 'ADMIN' | 'ASHA_WORKER', user_id: '...' }`

## 3. Admin APIs (Role: ADMIN only)
### ASHA Management
*   `POST /admin/asha-workers`
    *   **Body**: `{ full_name, phone_number, assigned_area, district, state, ... }`
    *   **Description**: Creates a new ASHA worker account (Auth + DB entry).
*   `GET /admin/asha-workers`
    *   **Response**: List of all ASHA workers with summary metrics.
*   `GET /admin/stats`
    *   **Response**: Aggregated system metrics (total patients, screenings, risks).

## 4. Patient APIs (Role: ASHA_WORKER)
*   `POST /patients`
    *   **Body**: `{ full_name, age, gender, address, profile_photo_url? }`
    *   **Description**: Registers a new patient linked to the authenticated ASHA worker.
*   `GET /patients`
    *   **Query Params**: `limit`, `offset`
    *   **Description**: Returns list of patients created by the requester.
*   `GET /patients/:id`
    *   **Description**: Get single patient details.

## 5. Screening APIs (Role: ASHA_WORKER)
*   `POST /screenings/analyze`
    *   **Body**:
        ```json
        {
          "patient_id": "uuid",
          "media_url": "https://storage...",
          "media_type": "AUDIO", // or IMAGE
          "screening_type": "RESPIRATORY" // or ANEMIA
        }
        ```
    *   **Description**: Triggers the Risk Engine. Returns the analyzed result (Risk Level + Indicators) immediately.
    *   **Note**: Does NOT save to history (Preview mode).

*   `POST /screenings/save`
    *   **Body**: `{ patient_id, result_data, media_reference, ... }`
    *   **Description**: Persists the screening result to the database.

*   `GET /screenings/history/:patient_id`
    *   **Description**: Returns past screening records for a specific patient.

## 6. Leaderboard
*   `GET /leaderboard`
    *   **Description**: Returns top N ASHA workers based on `rank_score`.
