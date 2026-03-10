const { db } = require('../config/firebase');

// GET /api/patients
// Fetches all patients from the 'patients' collection in Firestore
exports.getPatients = async (req, res) => {
    try {
        const snapshot = await db.collection('patients').get();
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
            createdAt: new Date()
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