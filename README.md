# Asha-Ai
## System Overview

ASHA-AI is a full-stack, mobile-first software system designed to support frontline healthcare workers in managing patient data and performing AI-assisted health risk screening using smartphone-based multimedia inputs. The system aims to digitize community-level screening workflows by enabling structured data collection, centralized processing, and intuitive result visualization.

The platform is built around two primary user roles: Admin and ASHA Worker. The Admin is responsible for system governance, including user management and system-wide monitoring, while ASHA Workers perform field-level operations such as patient registration, screening, and result tracking. Each ASHA Worker operates within an isolated data context to ensure privacy and controlled access.

ASHA-AI follows a three-tier client–server architecture consisting of a mobile client application, a backend application server, and a data storage layer. The mobile client, developed using Flutter, provides an intuitive interface for user interaction and multimedia capture through the device’s built-in camera and microphone. The backend server processes incoming requests, applies business logic, and performs simulated AI-based analysis to identify deviations from normal patterns in captured images and audio samples. Based on this analysis, the system generates color-coded risk indicators and displays possible health condition indicators for early screening purposes.

All patient records, screening results, and user metadata are securely stored in a centralized database, allowing for historical tracking and performance analytics. The system is designed as an academic prototype and proof-of-concept, focusing on software architecture, mobile application development, client–server communication, and ethical AI integration rather than real medical diagnosis.

### ARCHITECTURE FIGURE
High-Level Three-Tier Architecture of ASHA-AI System
<img width="1240" height="700" alt="image" src="https://github.com/user-attachments/assets/db3f2cbc-21b1-483f-b036-e47b3281a76b" />



### ROLE & PERMISSION MATRIX (RBAC DESIGN)

SYSTEM ROLES (FINAL & LOCKED)

Your system has TWO CORE ROLES:

ROLE 1: ADMIN

Purpose: System governance & supervision

ROLE 2: ASHA WORKER

Purpose: Field-level patient screening & data collection

No third role for now — simplicity = strength.



### ROLE & PERMISSION MATRIX

| Feature / Operation         | Admin | ASHA Worker  |
| --------------------------- | ----- | ------------ |
| Login to system             | ✅     | ✅            |
| View own dashboard          | ✅     | ✅            |
| Create ASHA worker          | ✅     | ❌            |
| Edit ASHA worker details    | ✅     | ❌            |
| Delete ASHA worker          | ✅     | ❌            |
| View ASHA worker statistics | ✅     | ❌            |
| View leaderboard            | ✅     | ✅            |
| Add new patient             | ❌     | ✅            |
| Edit patient details        | ❌     | ✅            |
| Delete patient record       | ❌     | ✅ (own only) |
| Upload patient photos       | ❌     | ✅            |
| Record patient audio        | ❌     | ✅            |
| Perform screening           | ❌     | ✅            |
| View screening results      | ❌     | ✅            |
| Delete screening record     | ❌     | ✅ (own only) |
| Access other ASHA data      | ❌     | ❌            |


## DATA OWNERSHIP RULE
Data Ownership Policy:
Each patient record and screening result is owned by the ASHA worker who created it. ASHA workers are permitted to perform create, read, update, and delete operations only on their own data. The Admin role has supervisory access limited to user management and aggregated system statistics, ensuring privacy, ethical data handling, and controlled access.

## SCOPE & NON-SCOPE DEFINITION
In-Scope Features

The following functionalities are included within the scope of the ASHA-AI system:

User Authentication and Role Management

Secure login for Admin and ASHA Workers

Role-based access control (RBAC)

ASHA Worker Management (Admin)

Create, edit, and delete ASHA worker accounts

View ASHA worker activity statistics and leaderboard

Patient Management (ASHA Worker)

Add new patient records with basic demographic details

Edit and delete patient information created by the ASHA worker

Store patient profile images

Multimedia-Based Screening

Capture patient images using smartphone camera

Record cough audio using smartphone microphone

Upload multimedia data to backend server

AI-Assisted Risk Screening (Simulated)

Server-side analysis of image and audio inputs

Detection of deviations from predefined baseline patterns

Classification of screening results into risk levels

Risk Visualization and Indicators

Color-coded risk display (Green, Yellow, Red)

Display of possible health condition indicators based on screening

Screening History and Data Storage

Persistent storage of screening results

Retrieval of historical screening data for patients

ASHA Worker Ranking System

Ranking based on number of screenings performed

Activity-based leaderboard display

System Architecture and Documentation

Three-tier client–server architecture

Comprehensive documentation and diagrams

### OUT-OF-SCOPE FEATURES
The following functionalities are explicitly excluded from the scope of this project:

Medical Diagnosis and Clinical Validation

The system does not diagnose or confirm any medical condition

Screening results are not clinically validated

Real-Time or Production-Grade AI Models

No training or deployment of real medical AI models

No use of external paid AI APIs

Government or Hospital System Integration

No live integration with national health databases (e.g., ABDM)

No hospital information system integration

Emergency Medical Decision Support

The system does not provide emergency alerts or treatment decisions

Legal, Regulatory, or Compliance Certification

The project is not intended for real-world medical deployment

No regulatory approvals are considered

Advanced Hardware Integration

No use of external medical devices or sensors

### NON-FUNCTIONAL SCOPE
The system is designed for scalability and modularity

Focus on usability and intuitive UI

Ensures basic data privacy and access control

Optimized for low-cost deployment using free-tier tools


## HIGH-LEVEL ARCHITECTURE & COMPONENT BREAKDOWN
### ARCHITECTURE STYLE

Three-Tier Client–Server Architecture

┌────────────────────────────────────┐
│        PRESENTATION LAYER           │
│      Flutter Android Application    │
│  - Admin Dashboard                  │
│  - ASHA Worker Dashboard            │
│  - Patient Management UI            │
│  - Screening & Result UI            │
└───────────────┬────────────────────┘
                │ HTTPS (JSON)
┌───────────────▼────────────────────┐
│        APPLICATION LAYER            │
│     Node.js + Express Backend       │
│  - Authentication & RBAC            │
│  - Business Logic                   │
│  - Screening Risk Engine            │
│  - Ranking & Analytics              │
└───────────────┬────────────────────┘
                │
┌───────────────▼────────────────────┐
│            DATA LAYER               │
│  - Firestore (Users, Patients)      │
│  - Storage (Images, Audio)          │
└────────────────────────────────────┘

### COMPONENT-WISE BREAKDOWN

COMPONENT 1: MOBILE CLIENT (FLUTTER APP)

Layer: Presentation Layer

Responsibilities:

User authentication (Admin / ASHA)

Role-based UI rendering

Patient CRUD operations

Image & audio capture using device hardware

API communication with backend

Display of risk results and history

Why Flutter?

Cross-platform capability

Rich UI widgets

Strong community support

Explicitly included in syllabus

 Key design principle:

“The client contains NO business logic related to screening decisions.”

 COMPONENT 2: BACKEND APPLICATION SERVER

Layer: Application Layer

Technology: Node.js + Express

Responsibilities:

Authentication & authorization

Role-based access enforcement

Validation of incoming requests

Media handling coordination

Screening risk logic execution

Ranking & analytics computation

Response formatting

 Key design principle:

“All decision-making logic resides on the server.”

This is industry best practice.

 COMPONENT 3: SCREENING RISK ENGINE (SIMULATED AI)

Layer: Application Layer (Sub-module)

Responsibilities:

Analyze image/audio metadata

Compare against predefined baseline thresholds

Identify deviations

Generate risk level & indicators

Design Choice:

Implemented as a replaceable module

Can be swapped with real ML models later


 COMPONENT 4: DATA STORAGE LAYER

Layer: Data Layer

Technologies:

Firestore (structured data)

Cloud Storage (media files)

Responsibilities:

Persistent storage of users, patients, screenings

Secure storage of images & audio

Support historical queries

Key principle:

“Media files are stored separately; only references are stored in the database.”

### DATA FLOW
Example: Screening Workflow

ASHA logs into mobile app

Selects patient

Captures image / audio

App sends request to backend API

Backend validates request & permissions

Risk engine analyzes data

Backend generates risk response

Result sent to mobile app

Data stored for history & analytics

### NON-FUNCTIONAL ARCHITECTURAL DECISIONS
Architectural Considerations

Scalability: Stateless backend APIs

Security: Role-based access control

Maintainability: Modular components

Performance: Media size limits

Cost: Free-tier tools only


