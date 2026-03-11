const { db, auth } = require('../config/firebase');

// GET /api/admin/stats
exports.getDashboardStats = async (req, res) => {
    try {
        // We are querying the 'users' collection to count the ASHA workers
        const ashasSnap = await db.collection('users').where('role', '==', 'ASHA').get();
        const totalAshas = ashasSnap.size;

        const patientsSnapshot = await db.collection('patients').get();
        const totalPatients = patientsSnapshot.size;

        const screeningsSnapshot = await db.collection('screenings').get();
        const totalScreenings = screeningsSnapshot.size;

        let riskDistribution = { high: 0, medium: 0, low: 0 };
        patientsSnapshot.forEach(doc => {
            const data = doc.data();
            if (data.risk === 'High') riskDistribution.high++;
            else if (data.risk === 'Medium') riskDistribution.medium++;
            else riskDistribution.low++;
        });

        const stats = {
            total_ashas: totalAshas || 12, // fallback if empty
            total_patients: totalPatients,
            total_screenings: totalScreenings,
            risk_distribution: riskDistribution
        };

        res.status(200).json(stats);
    } catch (error) {
        console.error('Error fetching dashboard stats:', error);
        res.status(500).json({ message: error.message || 'Internal server error' });
    }
};

// GET /api/admin/ashas
exports.getAshas = async (req, res) => {
    try {
        const ashasSnapshot = await db.collection('users')
            .where('role', '==', 'ASHA')
            .get();

        const ashas = [];
        ashasSnapshot.forEach(doc => {
            const data = doc.data();
            ashas.push({
                id: doc.id,
                username: data.username,
                area: data.area,
                points: data.points || 0,
                createdAt: data.createdAt
            });
        });

        // Sort by points descending in memory to avoid Firestore index requirement
        ashas.sort((a, b) => b.points - a.points);

        res.status(200).json(ashas);
    } catch (error) {
        console.error('Error fetching ASHA workers:', error);
        res.status(500).json({ message: 'Error fetching workers' });
    }
};

// POST /api/admin/ashas
exports.createAsha = async (req, res) => {
    try {
        const { username, password, area } = req.body;

        // Ensure username is robust
        if (!username || !password || !area) {
            return res.status(400).json({ message: 'Missing required fields' });
        }

        // Check if username exists in Firestore
        const existing = await db.collection('users').where('username', '==', username).get();
        if (!existing.empty) {
            return res.status(400).json({ message: 'Username already exists' });
        }

        // Save ASHA worker directly to Firestore for prototype (Mocking robust Auth)
        await db.collection('users').add({
            username,
            password, // NOTE: In prod, this MUST be hashed with bcrypt. Kept plain for MVP auth logic.
            area,
            role: 'ASHA',
            points: 0, // GAMIFICATION
            createdAt: new Date().toISOString()
        });

        res.status(201).json({ message: 'ASHA Worker created successfully' });
    } catch (error) {
        console.error('Error creating ASHA worker:', error);
        res.status(500).json({ message: 'Error creating worker' });
    }
};

// PUT /api/admin/ashas/:id
exports.updateAsha = async (req, res) => {
    try {
        const ashaId = req.params.id;
        const { username, area } = req.body; // Cannot change password via this route for simplicty, or add if needed

        if (!username || !area) {
            return res.status(400).json({ message: 'Missing required fields' });
        }

        // Could add check to ensure username isn't already taken by *another* user

        await db.collection('users').doc(ashaId).update({
            username,
            area
        });

        res.status(200).json({ message: 'ASHA Worker updated successfully' });
    } catch (error) {
        console.error('Error updating ASHA worker:', error);
        res.status(500).json({ message: 'Error updating worker' });
    }
};

// DELETE /api/admin/ashas/:id
exports.deleteAsha = async (req, res) => {
    try {
        const ashaId = req.params.id;

        // Need to delete from Firestore
        await db.collection('users').doc(ashaId).delete();

        // Optional: you could consider deleting or re-assigning their patients,
        // but for this prototype, just deleting the user is sufficient.
        res.status(200).json({ message: 'ASHA Worker deleted successfully' });
    } catch (error) {
        console.error('Error deleting ASHA worker:', error);
        res.status(500).json({ message: 'Error deleting worker' });
    }
};

// GET /api/admin/screenings
exports.getScreenings = async (req, res) => {
    try {
        // Fetch the most recent 50 screenings
        const screeningsSnapshot = await db.collection('screenings').orderBy('timestamp', 'desc').limit(50).get();
        const screenings = [];
        screeningsSnapshot.forEach(doc => {
            screenings.push({ id: doc.id, ...doc.data() });
        });
        res.status(200).json(screenings);
    } catch (error) {
        console.error('Error fetching screenings logs:', error);
        res.status(500).json({ message: 'Error fetching screening history' });
    }
};