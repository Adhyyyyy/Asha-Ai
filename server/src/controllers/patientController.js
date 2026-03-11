const { db } = require('../config/firebase');

// GET /api/patients
// Fetches all patients from the 'patients' collection in Firestore
exports.getPatients = async (req, res) => {
    try {
        let snapshot;

        // DATA PRIVACY: Admins see all, ASHAs see only their own patients
        if (req.user.role === 'ADMIN') {
            if (req.query.ashaId) { // Admin wants to see specific worker's patients
                snapshot = await db.collection('patients')
                    .where('assigned_to', '==', req.query.ashaId)
                    .get();
            } else {
                snapshot = await db.collection('patients').get();
            }
        } else {
            // ASHA workers can only pull patients uniquely assigned to their ID
            snapshot = await db.collection('patients')
                .where('assigned_to', '==', req.user.uid)
                .get();
        }

        const patients = [];

        snapshot.forEach(doc => {
            patients.push({ id: doc.id, ...doc.data() });
        });

        res.status(200).json(patients);
    } catch (error) {
        console.error("Error fetching patients:", error.message);
        res.status(500).json({ message: 'Server Error: Failed to fetch patients' });
    }
};

// POST /api/patients
// Creates a new patient document in the 'patients' collection
exports.addPatient = async (req, res) => {
    try {
        const newPatientData = {
            ...req.body,
            risk: 'Low', // Default risk for now
            last_visit: new Date().toISOString().split('T')[0],
            createdAt: new Date(),
            assigned_to: req.user.uid // SECURITY: Bind patient to the ASHA worker who added them
        };

        // Add to Firestore collection 'patients'
        const docRef = await db.collection('patients').add(newPatientData);

        const createdPatient = { id: docRef.id, ...newPatientData };
        res.status(201).json(createdPatient);
    } catch (error) {
        console.error("Error adding patient:", error.message);
        res.status(500).json({ message: 'Server Error: Failed to add patient' });
    }
};

// GET /api/patients/:id/screenings
exports.getPatientScreenings = async (req, res) => {
    try {
        const patientId = req.params.id;

        // We fetch screenings for this specific patient
        const snapshot = await db.collection('screenings')
            .where('patientId', '==', patientId)
            .get();

        const screenings = [];
        snapshot.forEach(doc => {
            screenings.push({ id: doc.id, ...doc.data() });
        });

        // Sort by timestamp descending in memory (newest first)
        screenings.sort((a, b) => {
            const timeA = a.timestamp?._seconds || 0;
            const timeB = b.timestamp?._seconds || 0;
            return timeB - timeA;
        });

        res.status(200).json(screenings);
    } catch (error) {
        console.error("Error fetching patient screenings:", error.message);
        res.status(500).json({ message: 'Server Error: Failed to fetch screenings' });
    }
};