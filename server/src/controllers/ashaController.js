const { db } = require('../config/firebase');

// GET /api/asha/stats
// Returns the specific ASHA's total patients, total screenings, and Gamified Leaderboard Rank
exports.getAshaStats = async (req, res) => {
    try {
        const uid = req.user.uid;

        // 1. Get their personal counts
        const patientsSnap = await db.collection('patients').where('assigned_to', '==', uid).get();
        const totalPatients = patientsSnap.size;

        const screeningsSnap = await db.collection('screenings').where('asha_id', '==', uid).get();
        const totalScreenings = screeningsSnap.size;

        // 2. Fetch all ASHA workers to calculate Rank
        // 2. Fetch all ASHA workers to calculate Rank
        // Remove .orderBy('points', 'desc') to prevent Index errors, sort in memory
        const allAshasSnap = await db.collection('users')
            .where('role', '==', 'ASHA')
            .get();

        const ashas = [];
        allAshasSnap.forEach(doc => {
            ashas.push({
                id: doc.id,
                points: doc.data().points || 0
            });
        });

        // Sort descending in memory
        ashas.sort((a, b) => b.points - a.points);

        let rank = 0;
        let found = false;

        ashas.forEach((worker, index) => {
            if (worker.id === uid) {
                rank = index + 1; // 1-indexed rank
                found = true;
            }
        });

        // If not found in the list (e.g. legacy user without points field), default to last
        if (!found) {
            rank = ashas.length + 1;
        }

        // Also fetch their total points directly
        const userDoc = await db.collection('users').doc(uid).get();
        const points = userDoc.exists ? (userDoc.data().points || 0) : 0;

        res.status(200).json({
            total_patients: totalPatients,
            total_screenings: totalScreenings,
            points: points,
            leaderboard_rank: rank
        });

    } catch (error) {
        console.error("🔥 FATAL ERROR FETCHING ASHA STATS:");
        console.error(error.message);
        console.error(error.stack);
        res.status(500).json({ message: 'Server Error fetching stats' });
    }
};
