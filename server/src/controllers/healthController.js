exports.checkHealth = (req, res) => {
    res.status(200).json({
        message: 'ASHA-AI Backend is Healthy!',
        timestamp: new Date().toISOString(),
        uptime: process.uptime()
    });
};