// Mock Data (Temporary Database)
let patients = [
    { id: '1', name: 'Rina Devi', age: 24, trimester: 2, risk: 'High', last_visit: '2026-02-10' },
    { id: '2', name: 'Sita Verma', age: 28, trimester: 3, risk: 'Low', last_visit: '2026-02-05' },
    { id: '3', name: 'Anita Singh', age: 22, trimester: 1, risk: 'Medium', last_visit: '2026-02-11' }
];

// GET /api/patients
exports.getPatients = (req, res) => {
    try {
        res.status(200).json(patients);
    } catch (error) {
        res.status(500).json({ message: 'Server Error: Failed to fetch patients' });
    }
};

// POST /api/patients
exports.addPatient = (req, res) => {
    try {
        const newPatient = {
            id: (patients.length + 1).toString(),
            ...req.body,
            risk: 'Low', // Default risk for now
            last_visit: new Date().toISOString().split('T')[0]
        };
        patients.push(newPatient);
        res.status(201).json(newPatient);
    } catch (error) {
        res.status(500).json({ message: 'Server Error: Failed to add patient' });
    }
};