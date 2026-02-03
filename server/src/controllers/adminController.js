// GET /api/admin/stats
exports.getDashboardStats = async (req, res) => {
    try {
        // TODO: Later we will fetch real counts from Firestore
        // const snapshot = await db.collection('patients').count().get();

        // MOCK DATA for Phase 4
        const stats = {
            total_ashas: 12,
            total_patients: 145,
            total_screenings: 68,
            risk_distribution: {
                high: 15,
                medium: 45,
                low: 85
            }
        };

        res.status(200).json(stats);
    } catch (error) {
        console.error('Error fetching dashboard stats:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
};